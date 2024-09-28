`timescale 1ns/1ps
module async_fifo_tb();

    parameter DATESIZE = 8;
    parameter ADDRSIZE = 3;
    parameter ALMOST = 2; 
    reg [DATESIZE-1:0]wdata;
    reg w_rstn;
    reg winc;
    reg rinc;
    reg wclk;
    reg rclk;
    reg r_rstn;
    wire [DATESIZE-1:0]rdata;
    wire wfull;
    wire rempty;
    wire almost_empty;
    wire almost_full;

    reg [3:0]a;
    reg [3:0]b;
    reg [4:0]c;
    reg x;
    initial begin
        $dumpfile("sync_fifo_tb.vcd");
        $dumpvars;
        wdata = 0;
        w_rstn = 0;
        rinc = 0;
        rclk = 0;
        r_rstn = 0;
        wclk = 0;
        winc = 0;
    

        #2;w_rstn = 0; r_rstn = 0;
        #4;w_rstn = 1; r_rstn = 1;

        #5;  winc = 1;
        #35; rinc = 1;
        #10; winc = 0;
        #60; rinc = 0;
        #5;  rinc = 1; winc = 1;
      
        #100;
        $finish();

    end
integer i;
    initial begin
        wait(winc==1);
        //#11;       
        for(i=0;i<=100;i=i+1) begin
            wdata = i;
            @(negedge wclk);
        end 
    end
 
    always #1   wclk = ~wclk;
    always #4   rclk = ~rclk;


    async_fifo #(
    .DATESIZE                       ( DATESIZE     ),
    .ADDRSIZE                       ( ADDRSIZE     ) )
 u_async_fifo(
    .wdata                          ( wdata ),
    .winc                           ( winc  ),
    .wclk                           ( wclk  ),
    .w_rstn                         ( w_rstn),
    .rinc                           ( rinc  ),
    .rclk                           ( rclk  ),
    .r_rstn                         ( r_rstn),
    .rdata                          ( rdata ),
    .rempty                         (rempty),
    .wfull                           (wfull),

    .almost_empty                   (almost_empty),
    .almost_full                     (almost_full)
    
);


endmodule





