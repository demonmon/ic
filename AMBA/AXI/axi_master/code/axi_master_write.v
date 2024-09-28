`default_nettype none

module axi_master_write #( 
    parameter	ADDR_WD = 32,
	parameter	DATA_WD = 32,
	parameter   STRB_WD = DATA_WD / 8
)(
    input  wire                 clk,
    input  wire                 reset,
    
    input  wire                 cmd_valid,
    input  wire [ADDR_WD-1 : 0] cmd_addr,//aligned
    input  wire [1:0]           cmd_burst,
    input  wire [ADDR_WD-1 : 0] cmd_len,//byte
    input  wire [7:0]           cmd_size,
    output wire                 cmd_ready,
    //AW channel
    output wire                 M_AXI_AWVALID,
    output wire [ADDR_WD-1 : 0] M_AXI_AWADDR,
    output wire [7 : 0]         M_AXI_AWLEN,
    output wire [2 : 0]         M_AXI_AWSIZE,
    output wire [1 : 0]         M_AXI_AWBURST,
    input  wire                 M_AXI_AWREADY,

    //W channel
    output wire                 M_AXI_WVALID,
    output wire [DATA_WD-1 : 0] M_AXI_WDATA,
    output wire [STRB_WD-1 : 0] M_AXI_WSTRB,    
    output wire                 M_AXI_WLAST,
    input  wire                 M_AXI_WREADY,

    // Write response channel
    output wire                 M_AXI_BREADY,
    input  wire                 M_AXI_BVALID,
    input  wire  [1 : 0]        M_AXI_BRESP
    //input   [2 : 0]       M_AXI_BID

);


localparam OPT_UNALIGNED = 1'b0;
localparam [1:0] FIXED = 2'b00;
localparam [1:0] INCR  = 2'b01;
localparam [1:0] WRAP  = 2'b10;

localparam integer ADDRLSB = $clog2(DATA_WD) - 3;//5-3
localparam integer TMP_LGMAXBURST = $clog2(4096/(DATA_WD/8));
localparam integer LGMAXBURST = (TMP_LGMAXBURST > 8) ? 8 : TMP_LGMAXBURST;//INCR
localparam integer LGMAX_FIXED_BURST = (LGMAXBURST > 4) ? 4 : LGMAXBURST;//FIXED,WRAP
localparam integer LGLEN = ADDR_WD; //
localparam integer LGLENT = LGLEN - ADDRLSB;//32-2=30-->[29:0]


//cmd_fire update
reg [ADDR_WD-1 : 0] aw_addr;
reg [LGLENT-1 : 0] aw_len_t;
reg [1:0] aw_burst;
reg [2:0] aw_size;
reg aw_incr_burst;
reg aw_zero_len;
reg aw_multiple_fixed_bursts;
reg aw_multiple_full_bursts;
reg aw_needs_alignment;

//phantom start to update the requests
reg [LGLENT-1 : 0] aw_requests_remaining;//[29:0]
reg [LGLENT-1 : 0] next_aw_remaining_combo;
//reg [LGLENT-1 : 0] aw_bursts_outstanding;

reg aw_multi_full_bursts_remaining;
reg next_aw_multi_full_bursts_remaining_combo;
reg aw_none_full_bursts_remaining;
reg next_aw_none_full_bursts_remaining_combo;
reg aw_multi_fixed_bursts_remaining;
reg next_aw_multi_fixed_remaining_combo;
reg aw_none_fixed_bursts_remaining;
reg next_aw_none_fixed_bursts_remaining_combo;



reg [LGMAXBURST : 0] initial_burstlen_combo;//256 extra bit
reg [LGMAXBURST-1 : 0] addr_align_combo;

reg [LGMAXBURST : 0] wr_max_burst;
//写数据多少拍
reg [LGMAXBURST : 0] wr_beat_pending;
reg wr_none_pending;

//reg ar_none_outstanding;
//reg ar_last_outstanding;

reg axi_abort_pending;


//pipeline
wire  cmd_fire;
reg  w_complete;
reg  start_burst;
reg  phantom_start;
reg  w_busy;
reg  w_pre_start;

//output
reg  axi_awvalid;
reg  axi_wready;
reg  axi_wlast;
reg  [7:0] axi_awlen;
reg  [1:0] axi_awburst;
reg  [ADDR_WD-1 : 0] axi_awaddr;
reg  [2:0] axi_awsize;
reg  axi_bready;
reg [STRB_WD-1 : 0] axi_wstrb;
reg [DATA_WD-1 : 0] axi_wdata;

assign M_AXI_AWADDR = axi_awaddr;
assign M_AXI_AWVALID = axi_awvalid;
assign M_AXI_AWBURST = axi_awburst;
assign M_AXI_AWLEN = axi_awlen;
assign M_AXI_AWSIZE = axi_awsize;
assign M_AXI_WREADY = axi_wready;

assign cmd_fire = cmd_valid && cmd_ready;
assign cmd_ready = !w_busy && !axi_abort_pending;


always @(posedge clk) begin
    if (reset) begin
        w_busy <= 1'b0;
    end else if (cmd_fire) begin
        w_busy <= 1'b1;
    end else if (w_complete) begin
        w_busy <= 1'b0;
    end
end

always @(*) begin
    if (reset) begin
        w_complete = 1'b0;
    end
    w_complete = M_AXI_WVALID && M_AXI_WREADY && M_AXI_WLAST &&//是否还有额外burst
        (aw_incr_burst ? aw_none_full_bursts_remaining : aw_none_fixed_bursts_remaining);
end

always@(*) begin
    start_burst = ! (aw_incr_burst ? aw_none_full_bursts_remaining
       : aw_none_fixed_bursts_remaining);
    if (!w_busy || w_pre_start) begin
        start_burst = 1'b0;
    end   
    if (phantom_start) begin
        start_burst = 1'b0;
    end
    if (M_AXI_AWVALID && !M_AXI_AWREADY) begin//block
        start_burst = 1'b0;
    end
    if (M_AXI_WVALID && !(M_AXI_WREADY && M_AXI_WLAST)) begin  ///？？？？
        start_burst = 1'b0;
    end
    if (axi_abort_pending) begin
        start_burst = 1'b0;
    end

end

always@(posedge clk ) begin
    if (!w_busy) begin
        w_pre_start <= 1'b1;
    end else begin
        w_pre_start <= 1'b0;
    end
end

//phantom start
always@(posedge clk) begin
    if (reset) begin
        phantom_start <= 1'b0;
    end else begin
        phantom_start <= start_burst;
    end
end

always@(posedge clk) begin
    if (reset) begin
        aw_needs_alignment <= 1'b0;
    end else if (!w_busy) begin
        aw_needs_alignment <= 1'b0;
        if (|cmd_addr[ADDRLSB +: LGMAXBURST]) begin
            if (|cmd_len[ADDR_WD-1 : LGMAXBURST]) begin
                aw_needs_alignment <= 1'b1;
            end
            //len[]+1 > (~addr + 1)---> len[] > ~addr
            if (cmd_len[ADDRLSB +: LGMAXBURST] > 
                ~cmd_addr[ADDRLSB +: LGMAXBURST]) begin
                    aw_needs_alignment <= 1'b1;
            end
        end
    end
end



always@(posedge clk) begin
    if (reset) begin
        aw_addr <= 'b0;
        aw_len_t <= 'b0;
        aw_burst <= FIXED;
        aw_size <='b0;
        aw_incr_burst <= 1'b1;

        aw_zero_len <= 1'b0;
        aw_multiple_full_bursts <= 1'b0;
        aw_multiple_fixed_bursts <= 1'b0;
    end else if (!w_busy) begin
        aw_addr <= cmd_addr;
        aw_len_t <= cmd_len[ADDRLSB +: LGLENT];//cmd_len[31:2]转换成拍数
        aw_burst <= cmd_burst;
        aw_size <= cmd_burst;
        aw_incr_burst <= (cmd_burst == INCR);

        aw_zero_len <= (cmd_len[ADDRLSB +: LGLENT] == 'b0);
        aw_multiple_full_bursts <= |cmd_len[LGLEN-1 : (ADDRLSB+LGMAXBURST)]; 
        aw_multiple_fixed_bursts <= |cmd_len[LGLEN-1 : (ADDRLSB+LGMAX_FIXED_BURST)];
    end else if (!axi_abort_pending && (M_AXI_BVALID && M_AXI_BRESP[1])) begin
        aw_len_t <= aw_requests_remaining;
        aw_zero_len <= (aw_requests_remaining == 'b0);
        aw_multiple_full_bursts <= |aw_requests_remaining[LGLENT-1 : LGMAXBURST];
        aw_multiple_fixed_bursts <= |aw_requests_remaining[LGLENT-1 : LGMAX_FIXED_BURST];
    end
end



always@(posedge clk) begin
    if (!w_busy || w_pre_start) begin
        aw_requests_remaining <= aw_len_t;
        aw_none_full_bursts_remaining <= aw_zero_len;
        aw_multi_full_bursts_remaining <= |aw_len_t[LGLENT-1 : LGMAXBURST];
        aw_none_fixed_bursts_remaining <= aw_zero_len;
        aw_multi_fixed_bursts_remaining <= |aw_len_t[LGLENT-1 : LGMAX_FIXED_BURST];
    end else if (axi_abort_pending) begin
        aw_requests_remaining <= 0;
        aw_none_full_bursts_remaining <= 1;
        aw_multi_full_bursts_remaining <= 0;
        aw_none_fixed_bursts_remaining <= 1;
        aw_multi_fixed_bursts_remaining <= 0;
    end else if (phantom_start) begin
        aw_requests_remaining <= next_aw_remaining_combo;

        aw_multi_full_bursts_remaining <= next_aw_multi_full_bursts_remaining_combo;
        aw_none_full_bursts_remaining <= next_aw_none_full_bursts_remaining_combo;
        
        aw_multi_fixed_bursts_remaining <= next_aw_multi_fixed_remaining_combo;
        aw_none_fixed_bursts_remaining <= next_aw_none_fixed_bursts_remaining_combo;
    end

end

always@(*) begin
    next_aw_remaining_combo = aw_requests_remaining + 
        {{(LGLENT-8){phantom_start}}, ~M_AXI_AWLEN};
    next_aw_multi_full_bursts_remaining_combo = |next_aw_remaining_combo[LGLENT-1 : LGMAXBURST];
    next_aw_none_full_bursts_remaining_combo = !(|next_aw_remaining_combo);
    next_aw_multi_fixed_remaining_combo = |next_aw_remaining_combo[LGLENT-1 : LGMAX_FIXED_BURST]; 
    next_aw_none_fixed_bursts_remaining_combo = !(|next_aw_remaining_combo);
end


always@(posedge clk) begin
    if (reset) begin
        wr_beat_pending <= 'b0;
        wr_none_pending <= 1'b1;
    end else begin
        case ({phantom_start, M_AXI_WVALID && M_AXI_WREADY})
            2'b01 :
                begin
                    wr_beat_pending <= wr_beat_pending - 1;
                    wr_none_pending <= (wr_beat_pending == 'd1);
                end
            2'b10 :
                begin
                    wr_beat_pending <= wr_beat_pending + (M_AXI_AWLEN + 1);
                    wr_none_pending <= 1'b0;
                end
            2'b11 : 
                begin
                    wr_beat_pending <= wr_beat_pending + (M_AXI_AWLEN);
                    wr_none_pending <= M_AXI_WLAST;
                    //wr_none_pending <= (M_AXI_AWLEN == 'd0);
                end
            default: 
                begin
                    wr_beat_pending <= 'b0;
                    wr_none_pending <= 1'b1;
                end
        endcase
    end
end


//addr aligned
// addr=3k-124
// len = 124，起始长度
always@(*) begin
    addr_align_combo = ~cmd_addr[ADDRLSB +: LGMAXBURST] + 1;
    initial_burstlen_combo = (1 << LGMAXBURST);
    if (aw_incr_burst) begin
        if (aw_needs_alignment) begin
            initial_burstlen_combo = {1'b0, addr_align_combo};
        end else if (!aw_multi_full_bursts_remaining) begin
            initial_burstlen_combo = {1'b0, aw_len_t[LGMAXBURST-1:0]};
            //aw_len_t??aw_requests_remaining??
        end else begin 
            initial_burstlen_combo = (1 << LGMAXBURST);
        end

    end else begin
        if (!aw_multi_fixed_bursts_remaining) begin
            initial_burstlen_combo = {1'b0, aw_len_t[LGMAXBURST-1 : 0]};
        end
    end
end


always@(posedge clk) begin
    if (!w_busy || w_pre_start) begin
        wr_max_burst <= initial_burstlen_combo;//first beat
    end else if (phantom_start) begin
        if (aw_incr_burst) begin
            wr_max_burst <= (1 << LGMAXBURST);
            if (!aw_multi_full_bursts_remaining) begin 
                wr_max_burst <= {1'b0, next_aw_remaining_combo[LGMAXBURST-1:0]};
            end
        end else begin
            wr_max_burst <= (1 << LGMAX_FIXED_BURST);
            if (!next_aw_none_fixed_bursts_remaining_combo) begin
                wr_max_burst <= {1'b0, next_aw_remaining_combo[LGMAXBURST-1:0]};
            end
        end
    end
end



always@(posedge clk) begin
    if (reset) begin
        axi_abort_pending <= 1'b0;
    end else begin
        if (M_AXI_WVALID && M_AXI_WREADY && M_AXI_BRESP[1]) begin
            axi_abort_pending <= 1'b1;
        end
        if (!w_busy) begin
            axi_abort_pending <= 1'b0;
        end 
    end
end
//每一个burst的起始地址计算
reg [ADDR_WD-1:0] wr_beat_addr;
always @(posedge clk) begin
    if(!w_busy || w_pre_start) begin
        wr_beat_addr <= aw_addr;
    end else if (axi_abort_pending || !aw_incr_burst) begin
        wr_beat_addr <= wr_beat_addr;
    end else if (M_AXI_WVALID && M_AXI_WREADY) begin
        wr_beat_addr <= wr_beat_addr + (1 << ADDRLSB);
    end
    if (!OPT_UNALIGNED) begin
        wr_beat_addr[ADDRLSB-1:0] <= 'b0;
    end
end


//WLAST
always @(posedge clk) begin
    if (!w_busy||w_pre_start) begin
        axi_wlast <= (aw_len_t == 'b1);
    end else if (!M_AXI_WVALID || M_AXI_WREADY) begin
        if (start_burst) begin
            axi_wlast <= (wr_max_burst == 'd1);//len=1 beat
        end else if (phantom_start) begin//phantom_start ==> belong to M_AXI_WVALID && M_AXI_WREADY
            axi_wlast <= (M_AXI_AWLEN == 'd1);//len = 2 beat
        end else begin
            axi_wlast <= (M_AXI_WVALID ? (wr_beat_pending == 'd2) : (wr_beat_pending == 'd1));
            //axi_wlast <= wr_beat_pending == ('d1 + M_AXI_WVALID);
        end
    end
end

//AWLEN
always@(posedge clk) begin
    if (!M_AXI_AWVALID || M_AXI_AWREADY) begin
        axi_awlen <= wr_max_burst - 1;
    end 
end

//AWADDR

always@(posedge clk) begin
    if (M_AXI_AWVALID && M_AXI_AWREADY) begin
        axi_awaddr[ADDRLSB-1:0] <= 'd0;
        if (aw_incr_burst) begin
            axi_awaddr[ADDR_WD-1:ADDRLSB] <= 
                axi_awaddr[ADDR_WD-1:ADDRLSB] + (M_AXI_AWLEN + 'd1);
             
        end 
    end 
    if (!w_busy||w_pre_start) begin
        axi_awaddr <= aw_addr;
    end

    if (!OPT_UNALIGNED) begin
        axi_awaddr[ADDRLSB-1:0] <= 'b0;
    end
end



always@(posedge clk) begin
    if (reset) begin
        axi_awvalid <= 1'b0;
    end else if (!M_AXI_AWVALID || M_AXI_AWREADY) begin
        axi_awvalid <= start_burst;
    end 
end


//AWBURST
always@(posedge clk) begin
    if (!M_AXI_AWVALID || M_AXI_AWREADY) begin
        axi_awburst <= aw_burst;
    end 
end
//AWSIZE
always@(posedge clk) begin
    if (!M_AXI_AWVALID || M_AXI_AWREADY) begin
        axi_awsize <= aw_size;
    end 
end
//WDATA

always@(posedge clk) begin
    if (reset) begin
        axi_wdata <= 'd0;
    end else if (M_AXI_WVALID && M_AXI_WREADY) begin
        axi_wdata <= axi_wdata + 1;
        if (axi_wlast) begin
            axi_wdata <= 'd0;
        end
    end
end

//WSTROB
always@(posedge clk) begin
    if (!M_AXI_AWVALID || M_AXI_AWREADY) begin
        axi_wstrb <= (axi_abort_pending ? 'b0 : {(STRB_WD){1'b1}});
    end 
end

//BREADY

always@(posedge clk) begin
    if (reset) begin
        axi_bready <= 1'b0;
    end else begin
         
        if (M_AXI_BREADY && M_AXI_BVALID) begin
            axi_bready <= 1'b0;
        end
        if (M_AXI_WVALID && M_AXI_WREADY) begin
            axi_bready <= M_AXI_WLAST;
        end//b_fire 之后 aw_fire  w_fire
    end
end


endmodule //axi_master_write