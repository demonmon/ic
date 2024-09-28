module dma_dst_ctrl #(
    parameter DATA_WD = 32,
    parameter ADDR_WD = 32,
    parameter LEN_WD  = 12,
    parameter BE_WD   = DATA_WD / 8
) (
    input  clk_i,
    input  rstn_i,

    //from dma_ch_rf
    input [LEN_WD-1 : 0] data_length_i,//byte
    input [ADDR_WD-1 : 0] dst_addr_i,

    //from src_ctrl
    input src_done_i,
    input dst_idle_o,

    //from dma_buff
    input  [DATA_WD-1 : 0] buf_rdata_i,   
    input                  buf_rvalid_i,
    output [BE_WD-1 : 0]   buf_rbe_o,
    output                 buf_rready_o,  

    //from or to core bus
    output                 core_st_req_o,  //request
    input                  core_st_gnt_i,  //response

    output [BE_WD-1 : 0]   core_st_be_o,
    output [DATA_WD-1 : 0] core_st_wdata_o,
    output [ADDR_WD-1 : 0] core_st_waddr_o, 
    output                 core_st_we_o, 
    input  [DATA_WD-1 : 0] core_st_rdata_i,
    input                  core_st_rvalid_i                                               
);


//-------------------FSM signal------------------------
localparam ST_IDLE  = 3'b000;
localparam ST_FRIST = 3'b001;
localparam ST_SEQ   = 3'b010;
localparam ST_LAST  = 3'b011;
localparam ST_DONE  = 3'b100;

reg [2:0] st_cs;
reg [2:0] st_ns;


//----------------------control signa-------------------
localparam DST_CNT_WD = $clog2(LEN_WD);
reg start_st;
wire has_one_beat;
wire has_extra_beat;// 1: 至少3拍 0：少于三拍
wire only_last_beat;

reg [BE_WD-1 : 0] be_cs;
reg [BE_WD-1 : 0] be_ns;

reg  [DST_CNT_WD-1 : 0] dst_data_cnt;   //used to record how much byte data has been read
reg  [DST_CNT_WD-1 : 0] dst_data_incr;  //used to record how much byte is read per deat(combo singal)

//output
reg                  buf_rready;
reg                  core_st_req;
reg  [ADDR_WD-1 : 0] core_st_waddr;

wire core_st_fire;
assign core_st_fire = core_st_req_o && core_st_gnt_i;
wire buf_fire;
assign buf_fire = buf_rready_o && buf_rvalid_i;//读取一个32bit


//--------------------------FSM------------------------------------------//
always @(posedge clk_i or negedge rstn_i) begin
    if (!rstn_i) begin
        st_cs <= ST_IDLE;
    end
    else begin
        st_cs <= st_ns;
    end
end

always @(*) begin
    st_ns = ST_IDLE;
    case(st_cs)
        ST_IDLE : 
            begin
               if (start_st) begin
                    st_ns = ST_FRIST;
               end else begin
                    st_ns = ST_IDLE;
               end
            end
        ST_FRIST:
            begin
                if (core_st_gnt_i) begin
                    st_ns = has_one_beat ? ST_DONE : (has_extra_beat ? 
                            ST_SEQ : ST_LAST); 
                end 
            end 
        ST_SEQ:
            begin
                if(core_st_gnt_i && only_last_beat) begin
                    st_ns = ST_LAST;
                end else begin
                    st_ns = ST_SEQ;
                end
            end 
        ST_LAST:
            begin
               if (core_st_gnt_i) begin
                    st_ns = ST_DONE;
               end else begin
                    st_ns = ST_LAST;
               end
            end      
        ST_DONE:
            begin
                st_ns = ST_IDLE;
            end
    endcase
end


//start_st src done-->dst start
always @(posedge clk_i or negedge rstn_i) begin
    if (!rstn_i) begin
        start_st <= 1'b0;
    end else if (start_st) begin
        start_st <= 1'b0;
    end else if (src_done_i && st_cs == ST_IDLE) begin
        start_st <= 1'b1;
    end
end

//has_one_beat
assign has_one_beat = (data_length_i <= 4-dst_addr_i[1:0]) ? 1'b1 : 1'b0;

// has_extra_beat 3，4.。。。
assign has_extra_beat = ( data_length_i > 4+4-dst_addr_i[1:0]) ? 1'b1 : 1'b0;

assign only_last_beat = ((data_length_i - (dst_data_cnt+dst_data_incr)) <= 4);


always @(posedge clk_i or negedge rstn_i) begin
    if (!rstn_i) begin
        be_cs <= 'b0;
    end
    else begin
        be_cs <= be_ns;
    end
end


integer i;
integer j;
wire [1:0] trg = has_one_beat ? dst_addr_i[1:0] + data_length_i-1 : 2'd3;
always @(*) begin
    be_ns = be_cs;
    if (st_ns == ST_SEQ) begin
        be_ns = 4'b1111;
    end

    if (st_ns == ST_FRIST) begin
        for (i=0; i<4; i=i+1) begin
            if ((i<dst_addr_i[1:0] | (i>trg))) begin
                be_ns[i] = 0;
            end else begin
                be_ns[i] = 1;
            end
        end
    end



    if (st_ns == ST_LAST && ((st_cs == ST_SEQ)|(st_cs == ST_FRIST))) begin
        for (j=0; j<4; j=j+1) begin
            be_ns[j] = (data_length_i - (dst_data_cnt + dst_data_incr)) > j;
        end
    end
end


//dst_data_incr
integer n;
always @(*) begin
    dst_data_incr = 'b0;

    if (st_cs == ST_FRIST | st_cs == ST_SEQ | st_cs == ST_LAST) begin
        for (n=0; n<4; n=n+1) begin
            if (be_cs[n] == 1) begin
                dst_data_incr = dst_data_incr + 1;
            end
        end
    end
end


//dst_data_cnt
always @(posedge clk_i or negedge rstn_i) begin
    if (!rstn_i) begin
        dst_data_cnt <= 'b0;
    end
    else if (st_cs == ST_DONE) begin
        dst_data_cnt <= 'b0;
    end
    else if ((st_cs == ST_FRIST | st_cs == ST_SEQ | st_cs == ST_LAST) && core_st_gnt_i) begin
        dst_data_cnt <= dst_data_cnt + dst_data_incr;
    end
end

//dst_idle_o
assign dst_idle_o = (st_cs == ST_IDLE);

//buf_rbe_o
assign buf_rbe_o = be_cs;


//buf_rready_o
always @(posedge clk_i or negedge rstn_i) begin
    if (!rstn_i) begin
        buf_rready <= 1'b0;
    end else if (buf_fire) begin
        buf_rready <= 1'b0;
    end else if (st_ns == ST_FRIST && st_cs == ST_IDLE) begin
        buf_rready <= 1'b1;
    end else if (((st_cs == ST_FRIST) | (st_cs == ST_SEQ) | (st_cs == ST_LAST)) && core_st_gnt_i) begin
        buf_rready <= 1'b1;
    end
end
assign buf_rready_o = buf_rready;
//core_st_req_o
always @(posedge clk_i or negedge rstn_i) begin
    if (!rstn_i) begin
        core_st_req <= 1'b0;
    end
    else if (core_st_fire) begin
        core_st_req <= 1'b0;
    end
    else if (((st_cs == ST_FRIST) | (st_cs == ST_SEQ) | (st_cs == ST_LAST)) && buf_rvalid_i) begin
        core_st_req <= 1'b1;
    end
end

assign core_st_req_o = core_st_req;

//core_st_wdata_o,core_st_be_o,core_st_we_o
assign core_st_wdata_o = buf_rdata_i;
assign core_st_be_o    = be_cs;
assign core_st_we_o    = 1'b1;


//core_st_waddr_o
always @(posedge clk_i or negedge rstn_i) begin
    if (!rstn_i) begin
        core_st_waddr <= 'b0;
    end
    else if (st_ns == ST_FRIST) begin
        core_st_waddr <= {dst_addr_i[ADDR_WD-1 : 2] , 2'b00};
    end
    else if (core_st_gnt_i) begin
        core_st_waddr <= core_st_waddr + 4;
    end
end

assign core_st_waddr_o = core_st_waddr;

endmodule //dma_dst_ctrl