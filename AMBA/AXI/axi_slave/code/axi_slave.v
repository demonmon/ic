module axi_slave #(
    parameter integer C_S_AXI_ID_WIDTH	  = 2,
    parameter integer C_S_AXI_DATA_WIDTH  = 32,
    parameter integer C_S_AXI_ADDR_WIDTH  = 6,
    parameter	[0:0]	OPT_LOWPOWER      = 1'b0
)(
    input  S_AXI_ACLK,
    input  S_AXI_ARESETN,
    // Write address channel
    input   [C_S_AXI_ID_WIDTH-1 : 0]        S_AXI_AWID,
    input   [C_S_AXI_ADDR_WIDTH-1 : 0]      S_AXI_AWADDR,
    input   [7 : 0]                         S_AXI_AWLEN,
    input   [2 : 0]                         S_AXI_AWSIZE,
    input   [1 : 0]                         S_AXI_AWBURST,
    input                                   S_AXI_AWVALID,
    output                                  S_AXI_AWREADY,
    // Write data channel
    input   [C_S_AXI_DATA_WIDTH-1 : 0]      S_AXI_WDATA,
    input   [(C_S_AXI_DATA_WIDTH/8)-1 : 0]  S_AXI_WSTRB,
    input                                   S_AXI_WLAST,
    input                                   S_AXI_WVALID,
    output                                  S_AXI_WREADY,
	// Write response channel
    input                                   S_AXI_BREADY,
    output                                  S_AXI_BVALID,
    output   [1 : 0]                        S_AXI_BRESP,
    output   [C_S_AXI_ID_WIDTH-1 : 0]       S_AXI_BID,

    // Read address channel
    input   [C_S_AXI_ID_WIDTH-1 : 0]        S_AXI_ARID,
    input   [C_S_AXI_ADDR_WIDTH-1 : 0]      S_AXI_ARADDR,
    input   [7 : 0]                         S_AXI_ARLEN,
    input   [2 : 0]                         S_AXI_ARSIZE,
    input   [1 : 0]                         S_AXI_ARBURST,
    input                                   S_AXI_ARVALID,
    output                                  S_AXI_ARREADY,

    // Read data (return) channel
    output   [C_S_AXI_ID_WIDTH-1 : 0]       S_AXI_RID,
    output   [C_S_AXI_DATA_WIDTH-1 : 0]     S_AXI_RDATA,
    output   [1 : 0]                        S_AXI_RRESP,
    output                                  S_AXI_RLAST,
    output                                  S_AXI_RVALID,
    input                                   S_AXI_RREADY
);
localparam	AW = C_S_AXI_ADDR_WIDTH;
localparam	DW = C_S_AXI_DATA_WIDTH;
localparam	IW = C_S_AXI_ID_WIDTH;
localparam  DEPTH =  1 << AW;
localparam  DW_BYTE = DW / 8;
reg [7:0] mem [DEPTH-1:0];


reg  [IW-1 : 0]     r_bid;
reg                 r_bvalid;
reg  [IW-1 : 0]     axi_bid;
reg                 axi_bvalid;

reg                 axi_awready;
reg                 axi_wready;
reg  [AW-1 : 0]     waddr;
wire [AW-1 : 0]     next_wr_addr;

reg  [7:0]          wlen;
reg  [2:0]          wsize;
reg  [1:0]          wburst;


wire [AW-1:0]	    next_rd_addr;

reg	 [7:0]		    rlen;
reg	 [2:0]		    rsize;
reg	 [1:0]		    rburst;
reg	 [IW-1:0]	    axi_rid;

reg			        axi_arready;
reg                 axi_rvalid;
reg	 [7:0]		    axi_rlen;
reg	 [AW-1:0]	    raddr;
reg                 axi_rlast;

assign S_AXI_AWREADY = axi_awready;
assign S_AXI_WREADY = axi_wready;
assign	S_AXI_BVALID  = axi_bvalid;
assign	S_AXI_BID     = axi_bid;
assign	S_AXI_BRESP  = 2'b00;

always @(posedge S_AXI_ACLK) begin
    if (!S_AXI_ARESETN) begin
        axi_awready <= 1'b1;
        axi_wready <= 1'b0;
    end else if (S_AXI_AWREADY && S_AXI_AWVALID) begin
        axi_awready <= 1'b0;
        axi_wready <= 1'b1;
    end else if (S_AXI_WREADY && S_AXI_WVALID) begin
        axi_awready <= S_AXI_WLAST && (!S_AXI_BVALID || S_AXI_BREADY);
        axi_wready <= !S_AXI_WLAST;
    end else if (!axi_awready) begin
        if (S_AXI_WREADY) begin
            axi_awready <= 1'b0;
        end else if (r_bvalid && !S_AXI_BREADY ) begin
            axi_awready <= 1'b0;
        end else begin
            axi_awready <= 1'b1;
        end
    end
end

always@(posedge S_AXI_ACLK) begin
    if (!S_AXI_ARESETN) begin
        r_bvalid <= 1'b0;
    end else if (S_AXI_WREADY && S_AXI_WVALID && S_AXI_WLAST && (S_AXI_BVALID && !S_AXI_BREADY)) begin
        r_bvalid <= 1'b1;
    end else if (S_AXI_BREADY) begin
        r_bvalid <= 1'b0;
    end
end

always@(posedge S_AXI_ACLK) begin
    if (!S_AXI_ARESETN) begin
        axi_bvalid <= 1'b0;
    end else if (S_AXI_WREADY && S_AXI_WVALID && S_AXI_WLAST) begin
        axi_bvalid <= 1'b1;
    end else if (S_AXI_BREADY) begin
        axi_bvalid <= r_bvalid; /// <=0?
    end
end

always@(posedge S_AXI_ACLK) begin
    if (S_AXI_AWREADY && (!OPT_LOWPOWER || S_AXI_AWVALID)) begin
        r_bid <= S_AXI_AWID;
    end
    if (!S_AXI_BVALID || S_AXI_BREADY) begin
        axi_bid <= r_bid;
    end
    if (OPT_LOWPOWER && !S_AXI_ARESETN) begin
        axi_bid <= 0;
        r_bid <= 0;
    end
end

always@(posedge S_AXI_ACLK) begin
    if (S_AXI_AWREADY) begin
        waddr <= S_AXI_AWADDR;
        wburst <= S_AXI_AWBURST;
        wsize <= S_AXI_AWSIZE;
        wlen  <= S_AXI_AWLEN;
    end else if (S_AXI_WVALID && S_AXI_WREADY) begin
        waddr <= next_wr_addr;///？？？第一拍写的是起始地址 不是处理过的
    end
end

axi_addr #(
    .AW ( AW ),
    .DW ( DW ))
 wr_axi_addr (
    .i_last_addr             ( waddr   ),
    .i_size                  ( wsize   ),
    .i_burst                 ( wburst  ),
    .i_len                   ( wlen    ),

    .o_next_addr             ( next_wr_addr )
);

integer i = 0;
always@(posedge S_AXI_ACLK) begin
    if (S_AXI_WREADY && S_AXI_WVALID) begin
        for ( i =0 ; i < DW_BYTE ; i = i + 1) begin
            //mem[waddr+i] <= S_AXI_WDATA[i*8+7:i*8]; //BYTE 写入
            mem[waddr+i] <= S_AXI_WDATA[(i*8) +: 8];
        end
    end
end






//read
assign S_AXI_ARREADY = axi_arready;

assign S_AXI_RID = axi_rid;
assign S_AXI_RLAST = axi_rlast;
assign S_AXI_RRESP = 2'b00;
assign S_AXI_RVALID = axi_rvalid;
//assign S_AXI_RREADY =;
always @(posedge S_AXI_ACLK) begin
	if (!S_AXI_ARESETN)
		axi_arready <= 1;
	else if (S_AXI_ARVALID && S_AXI_ARREADY) 
		axi_arready <= (S_AXI_ARLEN==0);
	else if (!S_AXI_RVALID || S_AXI_RREADY)
		axi_arready <= (axi_rlen <= 1);//==1？
end

always @(posedge S_AXI_ACLK) begin
	if (!S_AXI_ARESETN)
        axi_rlen <= 0;
	else if (S_AXI_ARVALID && S_AXI_ARREADY)
		axi_rlen <= S_AXI_ARLEN;
	else if (S_AXI_RREADY && S_AXI_RVALID)
		axi_rlen <= (axi_rlen - 1);  
end



always @(posedge S_AXI_ACLK) begin
	if (!S_AXI_ARESETN)
        axi_rlast <= 0;
	else if (S_AXI_ARVALID && S_AXI_ARREADY)
		axi_rlast <= (S_AXI_ARLEN == 0);
	else if (S_AXI_RREADY && S_AXI_RVALID)
		axi_rlast <= (axi_rlen == 1);  
end

//next addr
always @(posedge S_AXI_ACLK) begin
    if (S_AXI_ARREADY && S_AXI_ARVALID) begin
        raddr <= S_AXI_ARADDR;
        if (OPT_LOWPOWER && !S_AXI_ARVALID) begin
            raddr <= 0;
        end
    end else if (S_AXI_RREADY && S_AXI_RVALID) begin
        raddr <= next_rd_addr;
    end
end


axi_addr #(
    .AW ( AW ),
    .DW ( DW ))
 rd_axi_addr (
    .i_last_addr ( S_AXI_ARREADY ? S_AXI_ARADDR : raddr ),
    .i_size      ( S_AXI_ARREADY ? S_AXI_ARSIZE : rsize ),
    .i_burst     ( S_AXI_ARREADY ? S_AXI_ARBURST : rburst ),
    .i_len       ( S_AXI_ARREADY ? S_AXI_ARLEN : rlen ),

    .o_next_addr ( next_rd_addr )
);


always @(posedge S_AXI_ACLK) begin
    if (!S_AXI_ARESETN) begin
        axi_rvalid <= 0;
    end else if (S_AXI_ARREADY && S_AXI_ARVALID) begin
        axi_rvalid <= 1'b1;
    end else if (S_AXI_RREADY && S_AXI_RVALID) begin
        axi_rvalid <= !(axi_rlen == 0);
    end    
end

always @(posedge S_AXI_ACLK) begin
    if (S_AXI_ARREADY) begin
        rburst <= S_AXI_ARBURST;
        rlen <= S_AXI_ARLEN;
        rsize <= S_AXI_ARSIZE;
        axi_rid <= S_AXI_ARID;
        if (OPT_LOWPOWER && !S_AXI_ARVALID) begin
            rburst <= 0;
            rlen <= 0;
            rsize <= 0;
            axi_rid <= 0;
        end 
    end
end

generate
    genvar j;
    
    for (j = 0; j < DW_BYTE; j = j + 1) begin
        assign S_AXI_RDATA[(j*8) +: 8] = mem[raddr+j];
    end
endgenerate









endmodule //axi_slave