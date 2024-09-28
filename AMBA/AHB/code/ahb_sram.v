module ahb_sram (
    input                   clk,
    input                   rstn,
    input                   hsel,
    input  [mem_abit+2-1:0] haddr,
    input  [2:0]            hburst,
    input  [1:0]            htrans,
    input  [2:0]            hsize,
    input  [3:0]            hprot,
    input                   hwrite,
    input  [mem_dw-1:0]     hwdata,
    input                   hready,
    output                  hreadyout,
    output [31:0]           hrdata,
    output [1:0]            hresp 
);

parameter mem_depth = 1024;
parameter mem_abit = 10;
parameter mem_dw = 32;


parameter [1:0] T_IDLE = 2'd0, T_BUSY = 2'd1,T_NONS = 2'd2, T_SEQ = 2'd3;
parameter [1:0] R_OK = 2'd0;

wire bus_trans;
wire bus_idle;
wire bus_busy;

reg bus_wr_dph;
reg hready_idle;
reg hready_read;
wire hready_rd_w;
wire trans_fir;

reg [2:0] addr_step;
reg [2:0] addr_wrap_bloc;

reg  [mem_abit+2-1:0] addr_wrap;
wire [mem_abit+2-1:0] nxt_addr;
reg  [mem_abit+2-1:0] reg_addr;

wire bus_addr_inc;
wire bus_addr_inc_w;
reg  wrap_flag;

assign bus_idle = hsel & hready & (htrans == T_IDLE);
assign bus_busy = hsel & hready & (htrans == T_BUSY);
assign bus_trans = hsel && hready && htrans[1];
assign trans_fir = ;








endmodule //ahb_sram