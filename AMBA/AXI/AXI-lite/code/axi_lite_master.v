module axi_lite_master #(
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
    output                          tready,

    //address write channel
    output  [ADDR_WD-1 : 0]         awaddr,
    output                          awvalid,
    input                           awready,
    //data write channel
    output  [DATA_WD-1 : 0]         wdata,
    output                          wvalid,
    input                           wready,
    //write response channnel
    input   [1:0]                   bresp,
    input                           bvalid,   
    output                          bready,
    //read address channel
    output  [ADDR_WD-1 : 0]         araddr,
    output                          arvalid,
    input                           arready,
    //read data channel
    input                           rvalid,
    input   [DATA_WD-1 : 0]         rdata,
    input   [1:0]                   rresp,
    output                          rready
);

wire                tvalid_r;
wire [ADDR_WD-1:0]  taddr_r;
wire                tready_r;
wire                tvalid_w;
wire [ADDR_WD-1:0]  taddr_w;
wire                tready_w;
wire [DATA_WD-1:0]  tdata_w;

//dream demux
assign taddr_r = tdata[ADDR_WD-1:0];
assign taddr_w = tdata[ADDR_WD-1:0];
assign tdata_w = tdata[(DATA_WD + ADDR_WD-1):ADDR_WD];
wire wr_flag = &tkeep;
assign {tvalid_r,tvalid_w} = wr_flag ? {1'b0,tvalid} : {tvalid,1'b0};


assign tready = wr_flag ? tready_w : tready_r;


axi_lite_read_master #(
    .DATA_WD ( DATA_WD ),
    .ADDR_WD ( ADDR_WD ))
 u_axi_lite_read_master (
    .clk                     ( clk      ),
    .rstn                    ( rstn     ),
    .tvalid                  ( tvalid_r   ),
    .taddr                   ( taddr_r    ),
    .arready                 ( arready  ),
    .rvalid                  ( rvalid   ),
    .rdata                   ( rdata    ),
    .rresp                   ( rresp    ),

    .tready                  ( tready_r ),
    .araddr                  ( araddr   ),
    .arvalid                 ( arvalid  ),
    .rready                  ( rready   )
);



axi_lite_write_master #(
    .DATA_WD ( DATA_WD ),
    .ADDR_WD ( ADDR_WD ))
 u_axi_lite_write_master (
    .clk                     ( clk      ),
    .rstn                    ( rstn     ),
    .tvalid                  ( tvalid_w ),
    .taddr                   ( taddr_w  ),
    .tdata                   ( tdata_w  ),
    .awready                 ( awready  ),
    .wready                  ( wready   ),
    .bresp                   ( bresp    ),
    .bvalid                  ( bvalid   ),


    .tready                  ( tready_w ),
    .awaddr                  ( awaddr   ),
    .awvalid                 ( awvalid  ),
    .wdata                   ( wdata    ),
    .wvalid                  ( wvalid   ),
    .bready                  ( bready   )
);





endmodule //axi_lite_master



module axi_lite_read_master #(
    parameter DATA_WD = 8,
    parameter ADDR_WD = 8
)(
    input                   clk,
    input                   rstn,

    input                   tvalid,
    input   [ADDR_WD-1 : 0] taddr,
    output                  tready,
    
    //read address channel
    output  [ADDR_WD-1 : 0] araddr,
    output                  arvalid,
    input                   arready,
    //read data channel
    input                   rvalid,
    input   [DATA_WD-1 : 0] rdata,
    input   [1:0]           rresp,
    output                  rready
    
);

//handshake
wire                tfire,arfire,rfire;
wire                has_pending;
reg                 t_valid_r;
assign tfire = tready && tvalid;
assign arfire = arvalid && arready;
assign rfire = rready && rvalid;

assign has_pending = rvalid && !rready;//block
assign tready = !has_pending;

reg [ADDR_WD-1:0]   araddr_r;
reg                 arvalid_r;
reg                 rready_r;  
assign arvalid = arvalid_r;
assign araddr = araddr_r;
assign rready = rready_r;
always@(posedge clk or negedge rstn) begin
    if (!rstn) begin
        araddr_r <= 'b0;
        arvalid_r <= 0;
        rready_r <= 1'b0;
        t_valid_r <= 1'b0;
    end else begin
        
        if (rfire) begin
            rready_r <= 1'b0;
        end

        if (arfire) begin
            arvalid_r <= 1'b0;
            rready_r  <=1'b1;
        end

        if (tfire) begin
            araddr_r <= taddr;
            arvalid_r <= 1'b1;
        end
    end
end



endmodule //axi_lite_read_master


module axi_lite_write_master #(
    parameter DATA_WD = 8,
    parameter ADDR_WD = 8
) (
    input                   clk,
    input                   rstn,

    input                   tvalid,
    input   [ADDR_WD-1 : 0] taddr,
    input   [DATA_WD-1 : 0] tdata,
    output                  tready,

    //address write channel
    output  [ADDR_WD-1 : 0] awaddr,
    output                  awvalid,
    input                   awready,
    //data write channel
    output  [DATA_WD-1 : 0] wdata,
    output                  wvalid,
    input                   wready,
    //write response channnel
    input   [1:0]           bresp,
    input                   bvalid,   
    output                  bready
);

//handshake
wire                tfire,awfire,wfire,bfire;
assign awfire = awvalid && awready;
assign wfire  = wvalid && wready;
assign bfire  = bvalid && bready;        
assign tfire  = tvalid && tready;

reg [DATA_WD-1 : 0] wdata_r;
reg [ADDR_WD-1 : 0] awaddr_r;
reg                 awvalid_r;
reg                 wvalid_r;
reg                 bready_r;

reg                 aw_valid_r;
reg                 w_valid_r;
reg                 t_valid_r;
assign wdata   = wdata_r;
assign awaddr  = awaddr_r;
assign awvalid = awvalid_r;
assign wvalid  = wvalid_r;
assign bready  = bready_r;/*同样需要等addr channel 和
    data channel 都完成握手之后才能发送bready*/
wire has_pending = bvalid && !bready;//block
assign tready = !(has_pending || t_valid_r);

always@(posedge clk or negedge rstn) begin
    if (!rstn) begin
        wdata_r <= 'b0;
        awaddr_r <= 'b0;
        awvalid_r <= 1'b0;//
        wvalid_r <= 1'b0;//
        bready_r <= 1'b0;

        aw_valid_r <= 1'b0;
        wvalid_r <= 1'b0;
        t_valid_r <= 1'b0;
    end else begin
        
        if (awfire) begin
            awvalid_r <= 1'b0;
            aw_valid_r <= 1'b1;
        end
        if (wfire) begin
            wvalid_r <= 1'b0;
            w_valid_r <= 1'b1;
        end
        
        if (tfire) begin
            awaddr_r <= taddr;
            awvalid_r <= 1'b1;
            wdata_r <= tdata;
            wvalid_r <= 1'b1;
            t_valid_r <= 1'b1;
        end

        if (bfire) begin
            bready_r <= 1'b0;
            //w_valid_r<= 1'b0; 
            //aw_valid_r <= 1'b0;
        end

        if (awfire && wfire) begin
            t_valid_r <= 0;
            bready_r <= 1'b1;
            aw_valid_r <= 1'b0;//连续fire 覆盖前面的1
            w_valid_r<= 1'b0;
        end else if (wfire && aw_valid_r) begin
            t_valid_r <= 0;
            bready_r <= 1'b1;
            aw_valid_r <= 1'b0;
            w_valid_r<= 1'b0;
        end else if (awfire && w_valid_r ) begin
            t_valid_r <= 0;
            bready_r <= 1'b1;
            aw_valid_r <= 1'b0;
            w_valid_r<= 1'b0;
        end 

    end
end


endmodule //axi_lite_master







