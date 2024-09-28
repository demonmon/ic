module apb_protocol #(
    parameter DATA_WIDTH = 8,
              ADDR_WIDTH = 8,
              CMD_WIDTH = DATA_WIDTH + ADDR_WIDTH + 1
)(
    input [CMD_WIDTH-1:0] cmd_in,
    input cmd_vld,
    input clk,rstn,transfer,
    //input [ADDR_WIDTH-1:0] paddr,
    //input [DATA_WIDTH-1:0] pwdata,
    output [DATA_WIDTH-1:0] apb_rdata,
    output cmd_rdy
);


    wire PSEL_1,PSEL_2,pready_1,pready_2,pready,penable,pwrite;
    wire [DATA_WIDTH-1:0] pwdata,prdata_1,prdata_2,prdata;
    wire [ADDR_WIDTH-1:0] paddr;
    wire read_vld;

    assign pready = pready_1;
    assign prdata = prdata_1;

    apb_master #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH)) dut_master (
        .clk(clk),
        .rstn(rstn),
        .cmd_in(cmd_in),
        .cmd_vld(cmd_vld),
        .cmd_rdy(cmd_rdy),
        .read_vld(read_vld),
        .read_data(apb_rdata),
        .pready(pready),
        .transfer(transfer),
        .prdata(prdata),        
        .pwdata(pwdata),
        .paddr(paddr),
        .psel(PSEL_1),
        .penable(penable),
        .pwrite(pwrite)
    ); 

    apb_slave #(.DATA_WIDTH(DATA_WIDTH),.ADDR_WIDTH(ADDR_WIDTH)) slave1 (
        .clk(clk),
        .rstn(rstn),
        .psel(PSEL_1),
        .penable(penable),
        .pwrite(pwrite),
        .paddr(paddr),
        .pwdata(pwdata),
        .prdata(prdata_1),
        .pready(pready_1)
    );




endmodule //apb_protocol