// register file
`define CH_CTRL  'd0 //0x00
`define BD_ADDR  'd1 //0x04
`define BD_CTRL  'd2 //0x08
`define SRC_ADDR 'd3 //0x0c
`define DST_ADDR 'd4 //0x10

//bit define
//CH_CTRL
`define START_CH 'd0
//BD_CTRL
`define BD_LAST  'd20

module dma_ch_rf #(
    parameter DATA_WD = 32,
    parameter ADDR_WD = 32,
    parameter LEN_WD  = 12,
    parameter BE_WD   = DATA_WD / 8
) (
    //GLOBAL
    input                  clk_i,
    input                  rstn_i,

    //to or from CPU (core BUS)
    input                  core_req_i,
    input                  core_we_i,  //1 ? write : read
    output                 core_gnt_o, 

    input  [ADDR_WD-1 : 0] core_addr_i,
    input  [DATA_WD-1 : 0] core_wdata_i,
    output [DATA_WD-1 : 0] core_rdata_o,
    output                 core_rvalid_o,

    //to or from dma_src_ctrl
    output [LEN_WD-1 : 0]  bd_length_o,
    output [ADDR_WD-1 : 0] bd_addr_o,
    output [ADDR_WD-1 : 0] src_addr_o,
    output                 start_ch_req_o,
    output                 bd_last_o,
    input                  start_ch_ack_i,
    input  [DATA_WD-1 : 0] bd_info_i,
    input  [BE_WD-1 : 0]   bd_cs_i, //cnt of bd from 1 to 4  ctrl,src_addr,dst_addr,BD_addr 
    input                  bd_updata_i,

    //to dma_dst_ctrl
    output [ADDR_WD-1 : 0] dst_addr_o 
);

reg [DATA_WD-1 : 0] reg_cs [4:0];//reg list
reg [DATA_WD-1 : 0] reg_ns [4:0];
reg [DATA_WD-1 : 0] core_rdata;
reg                 core_rvalid;


//---------------------------reg updata----------------------------
integer i;
integer j;
always @(posedge clk_i or negedge rstn_i) begin
    if (!rstn_i) begin
        for (i=0; i<6; i=i+1) begin
            reg_cs[i] <= 'b0;     
        end
    end
    else begin
        for (j=0; j<6; j=j+1) begin
            reg_cs[j] <= reg_ns[j];
        end
    end
end


always @(*) begin
    if(core_req_i && core_we_i) begin //wdata 写进去 第一个关于BD信息写进去
        case (core_addr_i[ADDR_WD-1 : 2])
            'b0: reg_ns[`CH_CTRL] = core_wdata_i;
            'd1: reg_ns[`BD_ADDR] = core_wdata_i; 
        endcase
    end

    if (start_ch_ack_i) begin
        reg_ns[`CH_CTRL][`START_CH] = 1'b0;
    end//start only 1T

    if (bd_updata_i) begin
        case (bd_cs_i)
            'd1:
                begin
                  reg_ns[`BD_CTRL] = bd_info_i;
                end
            'd2:
                begin
                   reg_ns[`SRC_ADDR] = bd_info_i; 
                end
            'd3:
                begin
                   reg_ns[`DST_ADDR] = bd_info_i; 
                end
            'd4: 
                begin
                    reg_ns[`BD_ADDR] = bd_info_i;
                end
        endcase
    end


end


//------------------------read------------------------------

always @(*) begin
    core_rdata = 'b0;
    case (core_addr_i[ADDR_WD-1:2])
        'd0 : 
            begin
                core_rdata = reg_cs[`CH_CTRL];
            end 
        'd1 : 
            begin
                core_rdata = reg_cs[`BD_ADDR];
            end
        'd2 : 
            begin
                core_rdata = reg_cs[`BD_CTRL];
            end
        'd3 : 
            begin
                core_rdata = reg_cs[`SRC_ADDR];
            end
        'd4 :
            begin
                core_rdata = reg_cs[`DST_ADDR];
            end 
        default: core_rdata = 'b0;
    endcase
end

assign core_rdata_o = core_rdata;

//core_rvalid_o
always @(posedge clk_i or negedge rstn_i) begin
    if (!rstn_i) begin
        core_rvalid <= 'b0;
    end
    else if (core_req_i && !core_we_i) begin
        core_rvalid <= 1'b1;
    end
    else begin
        core_rvalid <= 1'b0;
    end
end
assign core_rvalid_o = core_rvalid;


//------------------- dma output------------------//

assign core_gnt_o = 1'b1;

assign bd_length_o = reg_cs[`BD_CTRL][11:0];
assign bd_last_o      = reg_cs[`BD_CTRL][`BD_LAST];//0??
assign start_ch_req_o = reg_cs[`CH_CTRL][`START_CH];//一开始需要配置
assign bd_addr_o      = reg_cs[`BD_ADDR];//一开始需要配置
assign src_addr_o     = reg_cs[`SRC_ADDR];
assign dst_addr_o     = reg_cs[`DST_ADDR];

endmodule