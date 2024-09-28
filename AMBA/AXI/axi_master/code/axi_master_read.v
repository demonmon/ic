//`default_nettype none

module axi_master_read #( 
    parameter	ADDR_WD = 32,
	parameter	DATA_WD = 32,
	parameter   STRB_WD = DATA_WD / 8
)(
    input  wire                 clk,
    input  wire                 reset,
    
    input  wire                 cmd_valid,
    input  wire [ADDR_WD-1 : 0] cmd_addr,
    input  wire [1:0]           cmd_burst,
    input  wire [ADDR_WD-1 : 0] cmd_len,
    input  wire [7:0]           cmd_size,
    output wire                 cmd_ready,
    //AR channel
    output wire                 M_AXI_ARVALID,
    output wire [ADDR_WD-1 : 0] M_AXI_ARADDR,
    output wire [7 : 0]         M_AXI_ARLEN,
    output wire [2 : 0]         M_AXI_ARSIZE,
    output wire [1 : 0]         M_AXI_ARBURST,
    input  wire                 M_AXI_ARREADY,
    //R channel
    input  wire                 M_AXI_RVALID,
    input  wire [DATA_WD-1 : 0] M_AXI_RDATA,
    input  wire [1:0]           M_AXI_RRESP,
    input  wire                 M_AXI_RLAST,
    output wire                 M_AXI_RREADY
);

localparam OPT_UNALIGNED = 1'b0;
localparam [1:0] FIXED = 2'b00;
localparam [1:0] INCR  = 2'b01;
localparam [1:0] WRAP  = 2'b10;

localparam integer ADDRLSB = $clog2(DATA_WD) - 3;
localparam integer TMP_LGMAXBURST = $clog2(4096/(DATA_WD/8));//考虑传输4K需要多少拍，看看会不会超过256拍
localparam integer LGMAXBURST = (TMP_LGMAXBURST > 8) ? 8 : TMP_LGMAXBURST;//INCR
localparam integer LGMAX_FIXED_BURST = (LGMAXBURST > 4) ? 4 : LGMAXBURST;//FIXED,WRAP
localparam integer LGLEN = ADDR_WD - 1;// 31：0  //-1？
localparam integer LGLENT = LGLEN - ADDRLSB;//31-2=29

//cmd_fire
reg [ADDR_WD-1 : 0] ar_addr;
reg [LGLENT-1 : 0] ar_len_t;
reg [1:0] ar_burst;
reg [2:0] ar_size;
reg ar_incr_burst;

//fix
reg ar_zero_len;
reg ar_multiple_fixed_bursts;
reg ar_multiple_full_bursts;
reg ar_needs_alignment;

//update when phantom_start
reg [LGLENT-1 : 0] ar_requests_remaining;
reg [LGLENT-1 : 0] next_ar_remaining_combo;
reg [LGLENT-1 : 0] ar_bursts_outstanding;
reg ar_multi_full_bursts_remaining;
reg next_ar_multi_full_bursts_remaining_combo;
reg ar_none_full_bursts_remaining;
reg ar_multi_fixed_bursts_remaining;
reg next_ar_multi_fixed_remaining_combo;
reg ar_none_fixed_bursts_remaining;

//first 3 beat
reg [LGMAXBURST : 0] initial_burstlen_combo;
reg [LGMAXBURST-1 : 0] addr_align_combo;

//
reg [LGMAXBURST : 0] rd_max_burst;

//
reg ar_none_outstanding;
reg ar_last_outstanding;

reg axi_abort_pending;

//pipeline
wire  cmd_fire;
reg  r_complete;
reg  start_burst;
reg  phantom_start;
reg  r_busy;
reg  r_pre_start;

//output
reg  axi_arvalid;
reg  axi_rready;
reg  [7:0] axi_arlen;
reg  [1:0] axi_arburst;
reg  [ADDR_WD-1 : 0] axi_araddr;
reg  [2:0] axi_arsize;

assign M_AXI_ARADDR = axi_araddr;
assign M_AXI_ARVALID = axi_arvalid;
assign M_AXI_ARBURST = axi_arburst;
assign M_AXI_ARLEN = axi_arlen;
assign M_AXI_ARSIZE = axi_arsize;
assign M_AXI_RREADY = axi_rready;

assign cmd_fire = cmd_valid && cmd_ready;
assign cmd_ready = !r_busy && !axi_abort_pending;
always @(posedge clk) begin
    if (reset) begin
        r_busy <= 1'b0;
    end else if (cmd_fire) begin
        r_busy <= 1'b1;
    end else if (r_complete) begin
        r_busy <= 1'b0;
    end
end
  
always@(*) begin
    if (reset) begin
        r_complete = 0;
    end
    r_complete = r_busy && ar_last_outstanding 
                && (M_AXI_RVALID && M_AXI_RREADY && M_AXI_RLAST);
end

always@(*) begin
    start_burst = !(ar_incr_burst ? ar_none_full_bursts_remaining 
        : ar_none_fixed_bursts_remaining);
    if (phantom_start || r_pre_start) begin
        start_burst = 1'b0;
    end

    if (!r_busy) begin
        start_burst = 1'b0;
    end

end

always@(posedge clk) begin
    if (!r_busy) begin//r_busy是寄存器 时序更好
        r_pre_start <= 1'b1;
    end else begin
        r_pre_start <= 1'b0;
    end
end

always@(posedge clk) begin
    if (reset) begin
        phantom_start <= 0;
    end else begin
        phantom_start <= start_burst;
    end
end

//第一拍-----对齐1k为单位---busy的第一拍就得判断*****
always@(posedge clk) begin
    if (!r_busy) begin
        ar_needs_alignment <= 0;
        //[9:2]=burstlen [1:0]=LSB 
        //
        if (|cmd_addr[LGMAXBURST+ADDRLSB-1 : ADDRLSB]) begin//判断有没有1k对齐
            // |cmd_len[31:0] != 0 >1k  if len 1024 + 124  而 addr=1024-124 则依然需要对齐
            if (|cmd_len[LGLEN-1 : (LGMAXBURST+ADDRLSB)]) begin // > 1k?//>4k?
                ar_needs_alignment <= 1;
            end
            // addr =4096 - 512 cmd_len = 1023 
            //其实地址加长度=0 就不需要对齐
            //（4096-512）+ 1023 ！= 0 就需要对齐
            //4096-512 + 512 则不需要对齐 ---> (addr + len)[9:2] == 0
            //len 是否大于 ~addr(~addr指的是4k-1-addr)
            if (cmd_len[(LGMAXBURST+ADDRLSB-1) : ADDRLSB] 
                > ~cmd_addr[(LGMAXBURST+ADDRLSB-1) : ADDRLSB] + 1) begin
                ar_needs_alignment <= 1;
            end
        end
    end
end

always@(posedge clk) begin
    if (reset) begin
        ar_addr <= 'b0;
        ar_len_t <= 'b0;
        ar_burst <= FIXED;
        ar_size <='b0;
        ar_incr_burst <= 1'b1;

        ar_zero_len <= 1'b0;
        ar_multiple_full_bursts <= 1'b0;
        ar_multiple_fixed_bursts <= 1'b0;
    end else if (!r_busy) begin
        ar_addr <= cmd_addr;
        ar_len_t <= cmd_len[ADDRLSB +: LGLENT];//cmd_len[31:2]转换成拍数
        ar_burst <= cmd_burst;
        ar_size <= cmd_size;
        ar_incr_burst <= (cmd_burst == INCR);
        ar_zero_len <= (cmd_len[ADDRLSB +: LGLENT] == 'b0);//[31:2]
        ar_multiple_full_bursts <= |cmd_len[LGLEN-1 : (ADDRLSB+LGMAXBURST)];//10 : 31
        ar_multiple_fixed_bursts <= |cmd_len[LGLEN-1 : (ADDRLSB+LGMAX_FIXED_BURST)];
    end else if (!axi_abort_pending && (M_AXI_RVALID && M_AXI_RRESP[1])) begin
        ar_len_t <= ar_requests_remaining;
        ar_zero_len <= (ar_requests_remaining == 'b0);
        ar_multiple_full_bursts <= |ar_requests_remaining[LGLENT-1 : LGMAXBURST];
        ar_multiple_fixed_bursts <= |ar_requests_remaining[LGLENT-1 : LGMAX_FIXED_BURST];
    end
end


//outstanding
always@(posedge clk) begin
    if (reset) begin
        ar_bursts_outstanding <= 0;
        ar_none_outstanding <= 1'b0;
        ar_last_outstanding <= 1'b0;
    end else begin // M_AXI_ARVALID && M_AXI_ARREADY 需要考虑11
        case ({phantom_start, (M_AXI_RVALID && M_AXI_RREADY && M_AXI_RLAST)})
            2'b01 :
                begin
                    ar_bursts_outstanding <= ar_bursts_outstanding - 1;
                    ar_none_outstanding <= (ar_bursts_outstanding == 'b1);
                    ar_last_outstanding <= (ar_bursts_outstanding == 'd2);
                end
            2'b10 : 
                begin
                    ar_bursts_outstanding <= ar_bursts_outstanding + 1;
                    ar_none_outstanding <= 0;
                    ar_last_outstanding <= (ar_bursts_outstanding == 'd0);
                end
                //phantom start 第一拍不需要考虑 11，
            2'b11 :
                begin
                    ar_bursts_outstanding <= ar_bursts_outstanding;
                    ar_none_outstanding <= 0;
                    ar_last_outstanding <= (ar_bursts_outstanding == 'd1);
                end    
            default: 
                begin
                
                end
        endcase
    end
end



always@(posedge clk) begin
    if (!r_busy || r_pre_start) begin
        ar_requests_remaining <= ar_len_t;
        ar_none_full_bursts_remaining <= ar_zero_len;
        ar_multi_full_bursts_remaining <= |ar_len_t[LGLENT-1 : LGMAXBURST];
        ar_none_fixed_bursts_remaining <= ar_zero_len;
        ar_multi_fixed_bursts_remaining <= |ar_len_t[LGLENT-1 : LGMAX_FIXED_BURST];
    end else if (axi_abort_pending) begin
        ar_requests_remaining <= 0;
        ar_none_full_bursts_remaining <= 1;
        ar_multi_full_bursts_remaining <= 0;
        ar_none_fixed_bursts_remaining <= 1;
        ar_multi_fixed_bursts_remaining <= 0;
    end else if (phantom_start) begin
        //256*2+124 beat
        // first phantom_start :  len = 256*2+124  arlen = 256;
        //ar_requests_remaining = 1  next_ar_remaining_combo = 1; 
        //ar_multi_full_bursts_remaining = 1 next = 1

        // secode phantom_start : len = 256 + 124 arlen = 256  
        // ar_requests_remaining = 1  next_ar_remaining_combo = 0;
        // ar_multi_full_bursts_remaining = 1 next = 0

        // third phantom_start : len = + 124  arlen = 124;
        // ar_requests_remaining = 1  next_ar_remaining_combo = 0;
        // ar_multi_full_bursts_remaining = 0 next = 0
        ar_requests_remaining <= next_ar_remaining_combo;
        ar_none_full_bursts_remaining <= !next_ar_multi_full_bursts_remaining_combo &&//next？？？
            (next_ar_remaining_combo[LGMAXBURST-1:0] == 'b0);
        ar_multi_full_bursts_remaining <= next_ar_multi_full_bursts_remaining_combo;
        ar_none_fixed_bursts_remaining <= !next_ar_multi_fixed_remaining_combo && 
            (next_ar_remaining_combo[LGMAX_FIXED_BURST:0] == 'b0);
        ar_multi_fixed_bursts_remaining <= next_ar_multi_fixed_remaining_combo;
    end
end

always@(*) begin
    //request-(ARLEN+1) 
    //request + ~ARLEN (-ARLEN = ~ARLEN + 1)
    //ARLEN还需要自动补全 bit number 
    //~ARLEN=~{LGLENT{1'b0}, M_AXI_ARLEN};
    //only on the phantom_start valid
    next_ar_remaining_combo = ar_requests_remaining + 
        {{(LGLENT-8){phantom_start}}, (phantom_start) ? ~M_AXI_ARLEN : 8'h00}; 

    next_ar_multi_fixed_remaining_combo = |next_ar_remaining_combo[LGLENT-1 : LGMAX_FIXED_BURST];
    next_ar_multi_full_bursts_remaining_combo = |next_ar_remaining_combo[LGLENT-1 : LGMAXBURST];

end

//第二拍：组合逻辑
//addr aligned
always@(*) begin
    // cmd_addr  = 3k - 124 距离3k对齐还差124
    // 由： bin + ~bin + 1 = 0 (k) ({1'b1，000....000},)
    //so length from addr to 3k = ~addr + 1
    addr_align_combo = 1 + ~ar_addr[ADDRLSB +: LGMAXBURST];
    initial_burstlen_combo = 1 << LGMAXBURST;
    if (!ar_incr_burst) begin
        initial_burstlen_combo = 1 << LGMAX_FIXED_BURST;
        if(!ar_multiple_fixed_bursts) begin
            initial_burstlen_combo = {1'b0, ar_len_t[LGMAXBURST-1:0]};
        end
    end else if (ar_needs_alignment) begin
        initial_burstlen_combo <= {1'b0, addr_align_combo};
    end else if (!ar_multiple_full_bursts) begin
        initial_burstlen_combo <= {1'b0, ar_len_t[LGMAXBURST-1:0]};
    end
end

always@(posedge clk) begin
    if (!r_busy || r_pre_start) begin
        rd_max_burst <= initial_burstlen_combo;
    end else if (phantom_start) begin
        if (ar_incr_burst) begin
            if (!next_ar_multi_full_bursts_remaining_combo && 
                (next_ar_remaining_combo[LGMAXBURST:0] <= (1 << LGMAXBURST))) begin
                rd_max_burst <= {1'b0, next_ar_remaining_combo[LGMAXBURST-1:0]};
            end else begin
                rd_max_burst <= (1 << LGMAXBURST);
            end
        end else begin
            if (!ar_multiple_fixed_bursts && 
            (next_ar_remaining_combo[LGMAX_FIXED_BURST:0] <= (1 << LGMAX_FIXED_BURST))) begin
                rd_max_burst <= {1'b0, next_ar_remaining_combo[LGMAXBURST-1:0]};
            end else begin
                rd_max_burst <= (1 << LGMAX_FIXED_BURST);
            end
        end
    end
end

always@(posedge clk) begin
    if (reset) begin
        axi_abort_pending <= 1'b0;
    end else begin
        if (M_AXI_RREADY && M_AXI_RVALID && M_AXI_RRESP[1]) begin
            axi_abort_pending <= 1'b1;
        end 
        if (!r_busy) begin
            axi_abort_pending <= 1'b0;
        end
    end
end

//ARLEN
always@(posedge clk) begin
    if (!M_AXI_ARVALID || M_AXI_ARREADY) begin
        axi_arlen <= rd_max_burst - 1;
    end
end

//ARADDR
always@(posedge clk) begin
    if (M_AXI_ARVALID && M_AXI_ARREADY) begin
        axi_araddr[ADDRLSB-1:0] <= 0;
        if (ar_incr_burst) begin
            axi_araddr[ADDR_WD-1:ADDRLSB] <= 
                axi_araddr[ADDR_WD-1:ADDRLSB] + M_AXI_ARLEN + 1;
        end
    end  

    if (!r_busy || r_pre_start) begin
        axi_araddr <= ar_addr;
        //if(!rbusy) --> ar_addr <= amd_addr
    end

end

//ARVALID
always@(posedge clk ) begin
    if (reset) begin
        axi_arvalid <= 1'b0;
    end else if (!M_AXI_ARVALID || M_AXI_ARREADY) begin
        axi_arvalid <= start_burst;
    end
end
//ARBURST
always@(posedge clk ) begin
    if (reset) begin
        axi_arburst <= 'b0;
    end else if (!M_AXI_ARVALID || M_AXI_ARREADY) begin
        axi_arburst <= ar_burst;
    end
end
//ARSIZE
always@(posedge clk ) begin
    if (reset) begin
        axi_arsize <= 'b0;
    end else if (!M_AXI_ARVALID || M_AXI_ARREADY) begin
        axi_arsize <= ar_size;
    end
end
//RREADY-->准备接收
always@(posedge clk ) begin
    if (reset) begin
        axi_rready <= 'b0;
    end else begin 
        if (r_complete) begin
            axi_rready <= 1'b0;
        end
        if (M_AXI_ARVALID && M_AXI_ARREADY) begin
            axi_rready <= 1'b1;
        end
    
    end
end












endmodule //axi_master_read