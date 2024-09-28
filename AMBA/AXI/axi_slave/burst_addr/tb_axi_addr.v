`timescale  1ns / 1ps 

module tb_axi_addr;   

// axi_addr Parameters
parameter PERIOD = 10;
parameter AW  = 12;   
parameter DW  = 32;   

// axi_addr Inputs
reg   [AW-1:0]  i_last_addr                = 0 ;
reg   [2:0]  i_size                        = 0 ;
reg   [1:0]  i_burst                       = 0 ;
reg   [7:0]  i_len                         = 0 ;
reg          clk;
reg         rstn;
// axi_addr Outputs
wire  [7:0]  o_incr                        ;
wire  [AW-1 : 0]  o_next_addr              ;


initial
begin
    clk = 0;
    forever #(PERIOD/2)  clk=~clk;
end

initial
begin
    rstn = 0;
    #(PERIOD*2) rstn  =  1;
end
initial begin
    $dumpfile("test.vcd");
    $dumpvars;
end
/*initial begin
    $fsdbDumpfile("test.fsdb");
    $fsdbDumpvars;
end*/
always@(posedge clk or negedge rstn) begin
    if (!rstn) begin
        i_burst <= 0;
        i_size <= 0;
        i_len <= 0;
        i_last_addr<='d120;
    end else begin
        i_burst <= 2'b10;
        i_len <= 3'b111;
        i_size <= 3'd3;
        i_last_addr <= i_last_addr + 4;
    end
end

axi_addr #(
    .AW ( AW ))
    //.DW ( DW ))
 u_axi_addr (
    .i_last_addr             ( i_last_addr  [AW-1:0]   ),
    .i_size                  ( i_size       [2:0]      ),
    .i_burst                 ( i_burst      [1:0]      ),
    .i_len                   ( i_len        [7:0]      ),

    //.o_incr                  ( o_incr       [7:0]      ),
    .o_next_addr             ( o_next_addr  [AW-1 : 0] )
);

initial
begin
    #5000
    $finish;
end

endmodule