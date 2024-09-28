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
     
        #200;
        $finish();

    end
 always @(posedge wclk or w_rstn)begin
    if( w_rstn == 1'b0 )begin 
        winc = 1'b0;
    end 
    else if( wfull )
        winc = 1'b0;
    else 
        winc = 1'b1 ;
end 
    
// rinc generate    
always @(posedge rclk or r_rstn)begin
    if( r_rstn == 1'b0 )begin
        rinc = 1'b0 ;
    end 
    else if( rempty )
        rinc = 1'b0;
    else 
        rinc = 1'b1 ;
end 

// wdata 
always @(posedge wclk or negedge w_rstn)begin
    if( w_rstn == 1'b0 )begin
        wdata = 0 ;
    end  
    else if( winc )begin 
        wdata = wdata + 1'b1;
    end 
end 

    always #0.5 wclk = ~wclk;
    always #4   rclk = ~rclk;


    async_fifo #(
    .DATESIZE                       ( DATESIZE     ),
    .ADDRSIZE                       ( ADDRSIZE     ),
    .ALMOST                           (ALMOST   ) )
 u_async_fifo(
    .wdata                          ( wdata ),
    .winc                           ( winc  ),
    .wclk                           ( wclk  ),
    .w_rstn                         ( w_rstn),
    .rinc                           ( rinc  ),
    .rclk                           ( rclk  ),
    .r_rstn                         ( r_rstn),
    .rdata                          ( rdata ),
    .wfull                          ( wfull ),
    .rempty                         ( rempty),
    .almost_empty              (almost_empty),
    .almost_full                (almost_full)
);


endmodule





