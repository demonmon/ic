module axil_top #(
    parameter DATA_WD = 8,
    parameter ADDR_WD = 8,
    parameter BYTE_WD = (ADDR_WD + DATA_WD) >> 3
)(
    input                           clk,
    input                           rstn,
    //stream
    input   [BYTE_WD-1:0]           tkeep,
    input   [DATA_WD + ADDR_WD-1:0] tdata,
    input                           tvalid,
    output                          tready
   
);

//address write channel
wire  [ADDR_WD-1 : 0]   awaddr;
wire                    awvalid;
wire                    awready;
//data write channel
wire  [DATA_WD-1 : 0]   wdata;
wire                    wvalid;
wire                    wready;
//write response channnel
wire   [1:0]            bresp;
wire                    bvalid;  
wire                    bready;
//read address channel
wire  [ADDR_WD-1 : 0]   araddr;
wire                    arvalid;
wire                    arready;
//read data channel
wire                    rvalid;
wire   [DATA_WD-1 : 0]  rdata;
wire   [1:0]            rresp;
wire                    rready;

axi_lite_master #(
    .DATA_WD ( DATA_WD ),
    .ADDR_WD ( ADDR_WD ),
    .BYTE_WD ( BYTE_WD ))
 u_axi_lite_master (
    .clk                     ( clk      ),
    .rstn                    ( rstn     ),
    .tkeep                   ( tkeep    ),
    .tdata                   ( tdata    ),
    .tvalid                  ( tvalid   ),
    .awready                 ( awready  ),
    .wready                  ( wready   ),
    .bresp                   ( bresp    ),
    .bvalid                  ( bvalid   ),
    .arready                 ( arready  ),
    .rvalid                  ( rvalid   ),
    .rdata                   ( rdata    ),
    .rresp                   ( rresp    ),

    .tready                  ( tready   ),
    .awaddr                  ( awaddr   ),
    .awvalid                 ( awvalid  ),
    .wdata                   ( wdata    ),
    .wvalid                  ( wvalid   ),
    .bready                  ( bready   ),
    .araddr                  ( araddr   ),
    .arvalid                 ( arvalid  ),
    .rready                  ( rready   )
);

axi_lite_slave #(
    .DATA_WD(DATA_WD),
    .ADDR_WD(ADDR_WD)
) u_axi_lite_slave (
    .clk          (  clk      ),
    .rstn         (  rstn     ),
    .awaddr       (  awaddr   ),
    .awvalid      (  awvalid  ),
    .wdata        (  wdata    ),
    .wvalid       (  wvalid   ),
    .bready       (  bready   ),
    .araddr       (  araddr   ),
    .arvalid      (  arvalid  ),
    .rready       (  rready   ),

    .awready      (  awready  ),
    .wready       (  wready   ),
    .bresp        (  bresp    ),
    .bvalid       (  bvalid   ),
    .arready      (  arready  ),
    .rvalid       (  rvalid   ),
    .rdata        (  rdata    ),
    .rresp        (  rresp    )
);



endmodule //axil_top