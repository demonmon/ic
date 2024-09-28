`timescale  1ns / 1ps

module tb_axi_lite_master;

// axi_lite_master Parameters
parameter PERIOD   = 10                ;
parameter DATA_WD  = 8                 ;
parameter ADDR_WD  = 8                 ;
parameter BYTE_WD  = (ADDR_WD + DATA_WD)>>3;

// axi_lite_master Inputs
reg   clk                           ;
reg   rstn                          ;
reg   [BYTE_WD-1:0]  tkeep          ;
wire   [DATA_WD + ADDR_WD-1:0]  tdata;
reg   tvalid                        ;
wire   awready                       ;
wire  wready                        ;
reg   [1:0]  bresp                  ;
reg   bvalid                        ;
wire  arready                       ;
reg   rvalid                        ;
reg   [DATA_WD-1 : 0]  rdata        ;
reg   [1:0]  rresp                  ;

// axi_lite_master Outputs
wire  tready                               ;
wire  [ADDR_WD-1 : 0]  awaddr              ;
wire  awvalid                              ;
wire  [DATA_WD-1 : 0]  wdata               ;
wire  wvalid                               ;
wire  bready                               ;
wire  [ADDR_WD-1 : 0]  araddr              ;
wire  arvalid                              ;
wire  rready                               ;

reg                 aw_valid_r;
reg                 w_valid_r;

//handshake
wire   tfire,awfire,wfire,bfire,rfire,arfire;
assign tfire = tready && tvalid;
assign awfire = awvalid && awready;
assign wfire  = wvalid && wready;
assign bfire  = bvalid && bready;
assign arfire = arvalid && arready;
assign rfire  = rvalid && rready;

assign awready = !(wresp_pending || aw_valid_r);
assign wready =  !(wresp_pending || w_valid_r);
assign arready = !rresp_pending;
wire wresp_pending = bvalid && !bready;
wire rresp_pending = rvalid && !rready;

always@(posedge clk or negedge rstn)begin
    if (!rstn) begin
        //awaddr_r <= 'b0;
        aw_valid_r <= 1'b0;
    end else begin

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

always@(posedge clk or negedge rstn) begin
    if (!rstn) begin
        w_valid_r <= 1'b0;
    end else begin
        if (awfire && wfire) begin
            w_valid_r <= 1'b0;
            //mem[awaddr] <= wdata;
        end else if (wfire && aw_valid_r) begin
            w_valid_r <= 1'b0;
            //mem[awaddr_r] <= wdata;
        end else if (w_valid_r && awfire) begin
            w_valid_r <= 1'b0;
            //mem[awaddr] <= wdata_r;
        end else if (wfire) begin
            w_valid_r <= 1'b1;
        end
      end
end

always@(posedge clk or negedge rstn) begin
    if (!rstn) begin
        bvalid <= 1'b0;
    end else begin
        if (bfire) begin
            bvalid <= 1'b0;
        end
        if (awfire && wfire) begin
            bvalid <= 1'b1;
        end else if (wfire && aw_valid_r) begin
            bvalid <= 1'b1;
        end else if (awfire && w_valid_r ) begin
            bvalid <= 1'b1;
        end
      end
end


always@(posedge clk or negedge rstn) begin
    if (!rstn) begin
        rvalid <= 1'b0;
        rdata <= 'b0;
        //araddr_r <= 'b0;
    end else begin
        if (arfire && rfire) begin
            //rdata_r <= mem[araddr];
            rvalid <= 1'b1;
        end else if (rfire) begin
            rvalid <= 1'b0;
        end else if (arfire) begin
            rvalid <= 1'b1;
        end
        
        if (arfire) begin
            rdata <= rdata + 1;
        end


      end
end



//计数器
reg  [ADDR_WD : 0]  cnt;
reg  [DATA_WD-1: 0] data; 

wire mode;
assign mode = cnt[ADDR_WD];
assign tdata = {data,cnt[ADDR_WD-1:0]};

always@(posedge clk or negedge rstn) begin
    if (!rstn) begin
        tvalid <= 0;
        cnt <='b0;
        rdata <= 'b0;
    end else begin
        if(!mode) begin
            tkeep <= 2'b11;
            if (!tvalid) begin
                tvalid <= $random; 
            end
            if (tfire) begin
                cnt <= cnt+1;
                data <= data + 1;
                tvalid <= $random;
            end
        end else begin
            tkeep <= 2'b01;
            if (!tvalid) begin
                tvalid <= $random; 
            end
            if (tfire) begin
                cnt <= cnt+1;
                tvalid <= $random;
            end
            
        end
            
    end
end




initial
begin
    clk = 0;
    forever #(PERIOD/2)  clk=~clk;
end

initial
begin
    rstn = 0;
    #(PERIOD*2) rstn  =  1;
    rresp = 2'b00;
end
initial begin
    $dumpfile("test.vcd");
    $dumpvars;
end

axi_lite_master #(
    .DATA_WD ( DATA_WD ),
    .ADDR_WD ( ADDR_WD ),
    .BYTE_WD ( BYTE_WD ))
 u_axi_lite_master (
    .clk                     ( clk                              ),
    .rstn                    ( rstn                             ),
    .tkeep                   ( tkeep    [BYTE_WD-1:0]           ),
    .tdata                   ( tdata    [DATA_WD + ADDR_WD-1:0] ),
    .tvalid                  ( tvalid                           ),
    .awready                 ( awready                          ),
    .wready                  ( wready                           ),
    .bresp                   ( bresp    [1:0]                   ),
    .bvalid                  ( bvalid                           ),
    .arready                 ( arready                          ),
    .rvalid                  ( rvalid                           ),
    .rdata                   ( rdata    [DATA_WD-1 : 0]         ),
    .rresp                   ( rresp    [1:0]                   ),

    .tready                  ( tready                           ),
    .awaddr                  ( awaddr   [ADDR_WD-1 : 0]         ),
    .awvalid                 ( awvalid                          ),
    .wdata                   ( wdata    [DATA_WD-1 : 0]         ),
    .wvalid                  ( wvalid                           ),
    .bready                  ( bready                           ),
    .araddr                  ( araddr   [ADDR_WD-1 : 0]         ),
    .arvalid                 ( arvalid                          ),
    .rready                  ( rready                           )
);

initial
begin

    $finish;
end

endmodule