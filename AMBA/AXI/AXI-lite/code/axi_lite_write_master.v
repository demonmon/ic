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