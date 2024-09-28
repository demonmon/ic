`timescale 1ns / 1ps
//
//
module glitch_free_tb();
    reg clk0, clk1;
    reg select;
    wire clkout;
    
    initial begin
    clk0 = 0;
    forever
    #2 clk0 = ~clk0;
    end
    
    initial begin
    clk1 = 0;
    forever
    #5 clk1 = ~clk1;
    end
    
    
    reg rst_n;
    reg in;
    initial begin
        select = 0;
        rst_n = 0;
        #5
        rst_n = 1;
        #30
        select = 1;
        #40
        select = 0;
        #10
    $finish();
    
    
    end
    
    initial begin
        $dumpfile("test.vcd");
        $dumpvars;
    end
    
    
   	glitch_free inst_glitch_free (.clk0(clk0), .clk1(clk1), .select(select), .rst_n(rst_n), .clkout(clkout));
 
      
    
endmodule