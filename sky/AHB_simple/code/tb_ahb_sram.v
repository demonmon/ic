module tb_ahb_sram;

// ahb_sram Parameters
parameter PERIOD     = 10  ;
parameter mem_depth  = 1024;
parameter mem_abit   = 10  ;
parameter mem_dw     = 32  ;

// ahb_sram Inputs
reg   clk                                  = 0 ;
reg   rstn                                 = 0 ;
reg   hsel                                 = 0 ;
reg   [mem_abit+2-1:0]  haddr              = 0 ;
reg   [2:0]  hburst                        = 0 ;
reg   [1:0]  htrans                        = 0 ;
reg   [2:0]  hsize                         = 0 ;
reg   [3:0]  hprot                         = 0 ;
reg   hwrite                               = 0 ;
reg   [mem_dw-1:0]  hwdata                 = 0 ;
wire   hready;
assign hready = hreadyout;               

// ahb_sram Outputs
wire  hreadyout                            ;
wire  [31:0]  hrdata                       ;
wire  [1:0]  hresp                         ;


initial
begin
    forever #(PERIOD/2)  clk=~clk;
end

initial
begin
    #(PERIOD*2) rstn  =  1;
    #2;
    hsel = 1;
    htrans = 2'b10;
    
   

end
reg [5:0] cnt;
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        hwdata <= 'd0;
    end else if (hwrite) begin
        hwdata <= hwdata + 1;
    end
end

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        hwrite <= 0;
        cnt <= 'd0;
    end else begin
        cnt <= cnt + 1;
        hsize <= 2'd3;
        if (cnt == 5'd31) begin
            hwrite <= 1'd0;
        end else if (cnt == 'd63) begin
            hwrite <= 1'b1;
        end        
    end
end

reg addr_flag;
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        addr_flag <= 0;
    end else begin
        if (cnt == 'd32) begin
            addr_flag <= 1'b1;
        end else begin
            addr_flag <= 1'b0;
        end
    end
end

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        haddr <= 'd0;
    end else begin
        
        if (cnt == 'd31) begin
            haddr <= 0;
        end else if (cnt == 'd63) begin
            haddr <= 0;
        end else if (addr_flag) begin
            haddr <= haddr;
        end else begin
            haddr <= haddr + 4;
        end
    end
end

integer i;
initial begin
    $dumpfile("test.vcd");
    $dumpvars;
    for (i = 0; i < 32; i = i + 1) begin
        $dumpvars(0,u_ahb_sram.u_mem.mem[i]);
    end
end

ahb_sram #(
    .mem_depth ( mem_depth ),
    .mem_abit  ( mem_abit  ),
    .mem_dw    ( mem_dw    ))
 u_ahb_sram (
    .clk                     ( clk                         ),
    .rstn                    ( rstn                        ),
    .hsel                    ( hsel                        ),
    .haddr                   ( haddr      [mem_abit+2-1:0] ),
    .hburst                  ( hburst     [2:0]            ),
    .htrans                  ( htrans     [1:0]            ),
    .hsize                   ( hsize      [2:0]            ),
    .hprot                   ( hprot      [3:0]            ),
    .hwrite                  ( hwrite                      ),
    .hwdata                  ( hwdata     [mem_dw-1:0]     ),
    .hready                  ( hready                      ),

    .hreadyout               ( hreadyout                   ),
    .hrdata                  ( hrdata     [31:0]           ),
    .hresp                   ( hresp      [1:0]            )
);

initial
begin
    #50000;
    $finish;
end

endmodule