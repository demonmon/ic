module dma_src_ctrl #(
    parameter DATA_WD = 32,
    parameter ADDR_WD = 32,
    parameter LEN_WD  = 12,
    parameter BE_WD   = DATA_WD / 8
) (
   //GLOBAL
    input                  clk_i,
    input                  rstn_i,

    // to or from dma_buff
    output [DATA_WD-1 : 0] buf_wdata_o,
    output                 buf_wvalid_o,
    output [BE_WD-1 : 0]   buf_wbe_o,
    input                  buf_wready_i,

    //to or from dma_rf
    input                  start_ch_req_i,  //transfer start signal from rf
    output                 start_ch_ack_o,  //start transfer response signal (pulse signal)

    input  [LEN_WD-1 : 0]  data_length_i,   //the length of each transfer,from bd_ctrl
    input  [ADDR_WD-1 : 0] src_addr_i,      //the address of each transfer,form bd_s_addr

    input  [ADDR_WD-1 : 0] bd_addr_i,       //first_bd_address,next_bd_address
    output [DATA_WD-1 : 0] bd_info_o,       //bd_contrl,src_address,dst_address,next_bd_address
    output [BE_WD-1 : 0]   bd_cs_o,         //which word of bd_info_i
    output                 bd_updata_o,     //Used in the RF updata register
    input                  bd_last_i,       //means current bd is the last opertion

    //to or from dst
    output                 src_done_o,      //tell DST that this SRC transmission has been completed
    input                  dst_idle_i,      //tell SRC thar this DST state is IDLE

    //core bus interface
    output                 core_ld_req_o,   // request
    input                  core_ld_gnt_i,   // response

    output                 core_ld_we_o,    // 1 ? write : read
    output [BE_WD-1 : 0]   core_ld_be_o,
    output [DATA_WD-1 : 0] core_ld_wdata_o,

    output [ADDR_WD-1 : 0] core_ld_addr_o, 
    input  [DATA_WD-1 : 0] core_ld_rdata_i,
    input                  core_ld_rvalid_i 

);


//......................FSM signal.......................
localparam LD_IDLE      = 4'b0000;
localparam LD_BD_CTRL   = 4'b0001;
localparam LD_S_ADDR    = 4'b0010;
localparam LD_D_ADDR    = 4'b0011;
localparam LD_BD_NEXT   = 4'b0100;
localparam LD_SRC_FIRST = 4'b0101;
localparam LD_SRC_SEQ   = 4'b0110;
localparam LD_SRC_LAST  = 4'b0111;
localparam LD_DONE      = 4'b1000;

reg [3:0] ld_cs;
reg [3:0] ld_ns;
localparam SRC_CNT_WD = $clog2(LEN_WD);  // 4
reg  start_ld;       //used to indicate the start of the transfer
wire has_one_beat;   //the transmission is only beat
wire has_extra_beat; //the transmission is extra than a beat
wire only_last_beat; //indicata that there if only one last beat left in the transfer
reg  pre_next_bd;    //indicata that there is a next BD to transfer

reg  [SRC_CNT_WD-1 : 0] src_data_cnt;   //used to record how much byte data has been read
reg  [SRC_CNT_WD-1 : 0] src_data_incr;  //used to record how much byte is read per deat(combo singal)

reg [BE_WD-1 : 0] be_cs;
reg [BE_WD-1 : 0] be_ns;

//.............output intermediate signals...............
reg                  start_ch_ack;
wire                 start_ch_fire; //indicate that request signal has been received
reg                  core_ld_req;
reg  [ADDR_WD-1 : 0] core_ld_addr;
reg                  next_req;//Used to indicate the next request signal

assign start_ch_fire  = start_ch_req_i && start_ch_ack_o;

//start_ld

always @(posedge clk_i or negedge rstn_i) begin
    if (!rstn_i) begin
        start_ld <= 'b0;
    end else if (start_ld) begin
        start_ld <= 1'b0;
    end else if (ld_cs == LD_IDLE && pre_next_bd && dst_idle_i) begin //next bd
        start_ld <= 1'b1;
    end else if (ld_cs == LD_IDLE && start_ch_req_i) begin //frist bd
        start_ld <= 1'b1;
    end
end

//pre_next_bd
always @(posedge clk_i or negedge rstn_i) begin
    if (!rstn_i) begin
        pre_next_bd <= 1'b0;
    end
    else if (ld_cs == LD_DONE && !bd_last_i) begin
        pre_next_bd <= 1'b1;
    end
    else begin
        pre_next_bd <= 1'b0;
    end
end
//has one beat
assign has_one_beat = (data_length_i <= 4-src_addr_i[1:0]) ? 1'b1 : 1'b0;
//has 2+
assign has_extra_beat =(data_length_i >  4-src_addr_i[1:0] + 4);

assign only_last_beat = ((data_length_i-(src_data_cnt+src_data_incr)) <= 4);

//........................FSM............................
always @(posedge clk_i or negedge rstn_i) begin
    if (!rstn_i) begin
        ld_cs <= LD_IDLE;
    end
    else begin
        ld_cs <= ld_ns;
    end
end


always @(*) begin
    ld_ns = LD_IDLE;
    case (ld_cs)
        LD_IDLE:
                begin
                    if (start_ld) begin
                        ld_ns = LD_BD_CTRL;
                    end else  begin
                        ld_ns = LD_IDLE;
                    end
                end 
        LD_BD_CTRL: 
                begin
                    if (core_ld_rvalid_i) begin
                        ld_ns = LD_S_ADDR;
                    end else begin
                        ld_ns = LD_BD_CTRL;
                    end
                end 
        LD_S_ADDR:
                begin
                    if (core_ld_rvalid_i) begin
                        ld_ns = LD_D_ADDR;
                    end else begin
                        ld_ns = LD_S_ADDR;
                    end
                end
        LD_D_ADDR:
                begin
                    if (core_ld_rvalid_i) begin
                        ld_ns = LD_BD_NEXT;
                    end else begin
                        ld_ns = LD_D_ADDR;
                    end
                end
        LD_BD_NEXT:       
                begin
                    if (core_ld_rvalid_i) begin
                        ld_ns = LD_SRC_FIRST;
                    end else begin
                        ld_ns = LD_BD_NEXT;
                    end
                end
        LD_SRC_FIRST:
                begin
                    if (core_ld_rvalid_i) begin
                        //TODO
                        ld_ns = has_one_beat ? LD_DONE : (has_extra_beat ?
                                 LD_SRC_SEQ : LD_SRC_LAST);
                    end else begin
                        ld_ns = LD_SRC_FIRST;
                    end
                end
        LD_SRC_SEQ:
                begin
                    if (core_ld_rvalid_i&&only_last_beat) begin
                        ld_ns = LD_SRC_LAST;
                    end else begin
                        ld_ns = LD_SRC_SEQ;
                    end
                end
        LD_SRC_LAST:
                begin
                    if (core_ld_rvalid_i) begin
                        ld_ns = LD_DONE;
                    end else begin
                        ld_ns = LD_SRC_LAST;
                    end
                end
        LD_DONE:
                begin
                   ld_ns = LD_IDLE; 
                end        
        default: ld_ns = LD_IDLE;
    endcase
end


// be chuli
wire [1:0] trg;
assign trg = has_one_beat ? src_addr_i[1:0] + data_length_i-1 : 2'd3;
always @(posedge clk_i or negedge rstn_i) begin
    if (!rstn_i) begin
        be_cs <= 'b0;
    end else begin
        be_cs <= be_ns;
    end
end
integer i,j;
always @(*) begin
    be_ns = be_cs;
    if ((ld_ns == LD_BD_CTRL) | (ld_ns == LD_SRC_SEQ)) begin
        be_ns = 4'b1111;
    end

    if (ld_ns == LD_SRC_FIRST) begin
        for (i=0; i<4; i=i+1) begin//4‘b0110
            if ((i<src_addr_i[1:0]) | (i > trg)) begin
                be_ns[i] = 0;
            end else begin
                be_ns[i] = 1;
            end
        end
    end
    
    if (ld_ns == LD_SRC_LAST && (ld_cs == LD_SRC_SEQ | ld_cs == LD_SRC_FIRST)) begin
        for (j=0; j<4; j=j+1) begin
            be_ns[j] = (j < (data_length_i-(src_data_cnt + src_data_incr)));
        end
    end
end

//

integer n;
always @(*) begin
    src_data_incr = 'b0;
    if (ld_cs == LD_SRC_FIRST | ld_cs == LD_SRC_SEQ | ld_cs == LD_SRC_LAST) begin
        for (n=0; n<4; n=n+1) begin
            if (be_cs[n]) begin
                src_data_incr = src_data_incr + 'b1;
            end
        end
    end
end

always @(posedge clk_i or negedge rstn_i) begin
     if (!rstn_i) begin
        src_data_cnt <= 'b0;
     end else if (ld_cs==LD_DONE) begin
        src_data_cnt <= 'b0;
     end else if (((ld_cs == LD_SRC_FIRST)|(ld_cs == LD_SRC_SEQ)|(ld_cs == LD_SRC_LAST)) && core_ld_rvalid_i) begin
        src_data_cnt <= src_data_cnt + src_data_incr;
     end
end


//----------------------------------output-----------------------------------//

always @(posedge clk_i or negedge rstn_i) begin
    if (!rstn_i) begin
        start_ch_ack <= 1'b0;
    end else if (start_ch_fire) begin
        start_ch_ack <= 1'b0;
    end else if (start_ch_req_i && (ld_cs==LD_IDLE)) begin
        start_ch_ack <= 1'b1;
    end
end

assign start_ch_ack_o = start_ch_ack;

//dma_rf
assign bd_info_o = core_ld_rdata_i;
assign bd_updata_o = core_ld_rvalid_i;
assign bd_cs_o = ld_cs;

//buffer
assign buf_wdata_o = core_ld_rdata_i;
assign buf_wbe_o = be_cs;
assign buf_wvalid_o = ((ld_cs == LD_SRC_FIRST) | (ld_cs == LD_SRC_SEQ) | (ld_cs == LD_SRC_LAST)) 
                        && core_ld_rvalid_i;
//bus
assign core_ld_we_o = 1'b0;
assign core_ld_be_o = be_cs;
assign core_ld_wdata_o = 'b0;

//core_ld_req_o
always @(posedge clk_i or negedge rstn_i) begin
    if (!rstn_i) begin
        core_ld_req <= 'b0;
    end else if (core_ld_gnt_i) begin
        core_ld_req <= 'b0;
    end else if (ld_ns == LD_BD_CTRL) begin
        core_ld_req <= 'b1;
    end else if (((ld_cs == LD_BD_CTRL) | (ld_cs == LD_S_ADDR) | (ld_cs == LD_D_ADDR)
                     | (ld_cs == LD_BD_NEXT)) && core_ld_rvalid_i) begin
        core_ld_req <= 'b1;
    end else if (next_req && buf_wready_i) begin
        core_ld_req <= 1'b1;
    end
end
assign core_ld_req_o = core_ld_req;

//next_req，辅助信号，
always @(posedge clk_i or negedge rstn_i) begin
    if (!rstn_i) begin
        next_req <= 1'b0;
    end else if (core_ld_req) begin
        next_req <= 1'b0;
    end else if (((ld_cs == LD_SRC_FIRST) | (ld_cs == LD_SRC_SEQ)) && core_ld_rvalid_i) begin
        next_req <= 1'b1;
    end
end

always @(posedge clk_i or negedge rstn_i) begin
    if (!rstn_i) begin
        core_ld_addr <= 'b0;
    end else if (ld_ns == LD_BD_CTRL) begin
        core_ld_addr <= bd_addr_i;
    end else if (ld_ns == LD_SRC_FIRST) begin
        core_ld_addr <= {src_addr_i[ADDR_WD-1:2],2'b00};
    end else if (core_ld_rvalid_i) begin
        core_ld_addr <= core_ld_addr + 4;
    end

end
assign core_ld_addr_o = core_ld_addr;
//src_done_o
assign src_done_o = (ld_cs == LD_DONE);




endmodule


