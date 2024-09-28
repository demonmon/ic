//`include "../code/axi_lite_slave.v"
`timescale 1ns / 1ps

module tb_axi_lite_slave;

//axi_lite_slave Parameters
parameter PERIOD = 10;
parameter DATA_WD = 8;
parameter ADDR_WD = 8;
parameter MODE = 1'b1;

//axi_lite_slave Inputs
reg                  clk;
reg                  rstn;
wire [ADDR_WD-1 : 0] awaddr;
reg                  awvalid;
wire [DATA_WD-1 : 0] wdata;
reg                  wvalid;
reg                  bready;
wire  [ADDR_WD-1 : 0] araddr;
reg                  arvalid;
reg                  rready;

//axi_lite_slave Outputs
wire                 awready;
wire                 wready;
wire [1:0]           bresp;
wire                 bvalid;
wire                 arready;
wire                 rvalid;
wire [DATA_WD-1 : 0] rdata;
wire [1:0]           rresp;

//handshake
wire   awfire,wfire,bfire,rfire,arfire;
assign awfire = awvalid && awready;
assign wfire  = wvalid && wready;
assign bfire  = bvalid && bready;
assign arfire = arvalid && arready;
assign rfire  = rvalid && rready;

//计数器
reg  [ADDR_WD : 0]  cnt;
reg  [DATA_WD-1: 0] data;   
assign awaddr = cnt[ADDR_WD-1:0];
assign araddr = cnt[ADDR_WD-1:0];
assign wdata  = data[DATA_WD-1:0];

wire mode;
assign mode = cnt[ADDR_WD];
generate if (MODE) begin
  always@(posedge clk or negedge rstn) begin
    if (!rstn) begin
        awvalid <= 0;
        wvalid  <= 0;
        bready  <= 1;
        cnt     <= 'b0;
        data    <= 'b0;
    end else if (!mode) begin
      if (!awvalid) begin
          awvalid <= $random; 
      end
      if (awfire) begin
          cnt=cnt+1;
          awvalid <= $random;
      end
  
      if (!wvalid) begin
        wvalid <= $random; 
      end
      if (wfire) begin
          data <= data+1;
          awvalid <= $random;
      end
      bready <= $random;
  
    end else begin
        awvalid <= 0;
        wvalid  <= 0;
        bready  <= 1;
    end
  end
  
  always@(posedge clk or negedge rstn) begin
      if (!rstn) begin
          arvalid <= 0;
          rready <= 1;
          cnt     <= 'b0;
      end else if (mode)begin
        if (!arvalid) begin
          arvalid <= $random; 
        end
        if (arfire) begin
          cnt=cnt+1;
          arvalid <= $random;
        end
        rready <= $random;
      end else begin
        arvalid <= 0;
        rready <= 1;
      end
          
  end	
end else begin
  //always fire 

always@(posedge clk or negedge rstn) begin
  if (!rstn) begin
      awvalid <= 0;
      wvalid  <= 0;
      bready  <= 1;
      cnt     <= 'b0;
      data    <= 'b0;
  end else if (!mode) begin
    awvalid <= 1;
    wvalid <= 1;
    bready <= 1;
    if (awfire) begin
        cnt=cnt+1;
        //awvalid <= $random;
    end
    if (wfire) begin
        data <= data+1;
        //awvalid <= $random;
    end
  end else begin
      awvalid <= 0;
      wvalid  <= 0;
      bready  <= 1;
  end
end

//read
always@(posedge clk or negedge rstn) begin
  if (!rstn) begin
    arvalid <= 0;
    rready <= 1;
    cnt    <= 'b0;
  end else if (mode)begin
    rready <= 1;
    arvalid <= 1; 
    
    if (arfire) begin
      cnt=cnt+1;
    end
    
  end else begin
    arvalid <= 0;
    rready <= 1;
  end
      
end	
end
  
endgenerate

initial begin
    clk = 0;
    forever #(PERIOD / 2) clk = ~clk;
end

initial begin
    rstn = 0;
    #(PERIOD * 2) rstn = 1;
end
initial begin
    $dumpfile("test.vcd");
    $dumpvars;
end

axi_lite_slave #(
    .DATA_WD(DATA_WD),
    .ADDR_WD(ADDR_WD)
) u_axi_lite_slave (
    .clk    (  clk      ),
    .rstn   (  rstn     ),
    .awaddr (  awaddr   ),
    .awvalid(  awvalid  ),
    .wdata  (  wdata    ),
    .wvalid (  wvalid   ),
    .bready (  bready   ),
    .araddr (  araddr   ),
    .arvalid(  arvalid  ),
    .rready (  rready   ),

    .awready(  awready  ),
    .wready (  wready   ),
    .bresp  (  bresp    ),
    .bvalid (  bvalid   ),
    .arready(  arready  ),
    .rvalid (  rvalid   ),
    .rdata  (  rdata    ),
    .rresp  (  rresp    )
);

initial begin
    #10000
    $finish;
end

endmodule
