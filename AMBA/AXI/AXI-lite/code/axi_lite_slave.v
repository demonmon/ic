module axi_lite_slave #(
    parameter DATA_WD = 32,
    parameter ADDR_WD = 8
)(
    input                   clk,
    input                   rstn,
    //address write channel
    input   [ADDR_WD-1 : 0] awaddr,
    input                   awvalid,
    output                  awready,
    //data write channel
    input   [DATA_WD-1 : 0] wdata,
    input                   wvalid,
    output                  wready,
    //write response channnel
    output  [1:0]           bresp,
    output                  bvalid,
    input                   bready,
    //read address channel
    input   [ADDR_WD-1 : 0] araddr,
    input                   arvalid,
    output                  arready,
    //read data channel
    output                  rvalid,
    output  [DATA_WD-1 : 0] rdata,
    output  [1:0]           rresp,
    input                   rready
);

localparam DEPTH = 1 << ADDR_WD;

reg [DATA_WD-1 : 0] mem [DEPTH-1 : 0];

//handshake
wire   awfire,wfire,bfire,rfire,arfire;
assign awfire = awvalid && awready;
assign wfire  = wvalid && wready;
assign bfire  = bvalid && bready;
assign arfire = arvalid && arready;
assign rfire  = rvalid && rready;

wire wresp_pending = bvalid && !bready;
wire rresp_pending = rvalid && !rready;


//assign awready = !aw_valid_r && (!bvalid || bready);//写回复通道不阻塞并且aw标志位显示没有buffer数据
assign awready = !(wresp_pending || aw_valid_r);
assign wready =  !(wresp_pending || w_valid_r);
assign arready = !rresp_pending;

//write channel
assign bresp = 2'b0;//okey
reg [ADDR_WD-1 : 0] awaddr_r;//buffer
reg                 aw_valid_r;
reg [DATA_WD-1 : 0] wdata_r;//buffer
reg                 w_valid_r;
reg                 bvalid_r;

assign bvalid = bvalid_r;
    //addr channel
always@(posedge clk or negedge rstn)begin
    if (!rstn) begin
        awaddr_r <= 'b0;
        aw_valid_r <= 1'b0;
    end else begin
        if (awfire) begin
            awaddr_r <= awaddr;
            //aw_valid_r  <= 1'b1; 
        end
        /*if (bfire) begin
            aw_valid_r <= 1'b0;
        end*/  

        
        if (awfire && wfire) begin
            aw_valid_r <= 1'b0;
        end else if (awfire && w_valid_r) begin
            aw_valid_r <= 1'b0;
        end else if (aw_valid_r && wfire) begin
            aw_valid_r <= 1'b0;
        end else if (awfire) begin
            aw_valid_r <= 1'b1;
        end
      end
end
    //data channel
always@(posedge clk or negedge rstn) begin
    if (!rstn) begin
        w_valid_r <= 1'b0;
        wdata_r <= 'b0;
    end else begin
        if (wfire) begin
            wdata_r <= wdata;
        end 

        if (awfire && wfire) begin
            w_valid_r <= 1'b0;
            mem[awaddr] <= wdata;
        end else if (wfire && aw_valid_r) begin
            w_valid_r <= 1'b0;
            mem[awaddr_r] <= wdata;
        end else if (w_valid_r && awfire) begin
            w_valid_r <= 1'b0;
            mem[awaddr] <= wdata_r;
        end else if (wfire) begin
            w_valid_r <= 1'b1;
        end
      end
end
    //response channel
always@(posedge clk or negedge rstn) begin
    if (!rstn) begin
        bvalid_r <= 1'b0;
    end else begin
        if (bfire) begin
            bvalid_r <= 1'b0;
        end
        if (awfire && wfire) begin
            bvalid_r <= 1'b1;
        end else if (wfire && aw_valid_r) begin
            bvalid_r <= 1'b1;
        end else if (awfire && w_valid_r ) begin
            bvalid_r <= 1'b1;
        end
        //两种实现方法
        /*if (awfire && wfire && bfire) begin
            bvalid_r <= 1'b1;
        end else if (awfire && wfire) begin
            bvalid_r <= 1'b1;
        end else if (wfire && aw_valid_r) begin
            bvalid_r <= 1'b1;
        end else if (awfire && w_valid_r ) begin
            bvalid_r <= 1'b1;
        end else if (bfire) begin
            bvalid_r <= 1'b0;
        end*/
      end
end
assign rresp = 2'b0;
//read channel
reg [DATA_WD-1 : 0] rdata_r;
reg                 rvalid_r; 
reg [ADDR_WD-1 : 0] araddr_r;
assign rvalid = rvalid_r;
assign rdata = rdata_r;
always@(posedge clk or negedge rstn) begin
    if (!rstn) begin
        rvalid_r <= 1'b0;
        rdata_r <= 'b0;
        araddr_r <= 'b0;
    end else begin
        
        /*if (rfire) begin
            rvalid_r <= 1'b0;
            
        end

        if (arfire) begin
            rdata_r <= mem[araddr];
            rvalid_r <= 1'b1;
            araddr_r <= araddr;
        end*/
        //arfire rfire同时fire rvalid_r=1
        if (arfire && rfire) begin
            //rdata_r <= mem[araddr];
            rvalid_r <= 1'b1;
        end else if (rfire) begin
            rvalid_r <= 1'b0;
        end else if (arfire) begin
            rvalid_r <= 1'b1;
        end
        
        if (arfire) begin
            rdata_r <= mem[araddr];
        end


      end
end




endmodule //axi_lite_slave