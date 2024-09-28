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
reg [ADDR_WD-1:0]   araddr_r;
reg                 arvalid_r;
reg                 rready_r; 

assign tfire = tready && tvalid;
assign arfire = arvalid && arready;
assign rfire = rready && rvalid;

assign has_pending = rvalid && !rready;//block
assign tready = !has_pending;

 
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