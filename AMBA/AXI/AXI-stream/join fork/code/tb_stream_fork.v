`timescale  1ns / 1ps

module tb_tb_axi_lite_slave;   

// tb_axi_lite_slave Parameters
      
parameter PERIOD   = 10;       
parameter DATA_WD  = 32;       
parameter ADDR_WD  = 8 ;       

// tb_axi_lite_slave Inputs    


// tb_axi_lite_slave Outputs



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

tb_axi_lite_slave #(
    .PERIOD  ( PERIOD  ),
    .DATA_WD ( DATA_WD ),
    .ADDR_WD ( ADDR_WD ))
 u_tb_axi_lite_slave (

);

initial
begin

    $finish;
end

endmodule