module async_fifo_2_tb ();

    parameter DATESIZE = 8;
    parameter ADDRSIZE = 3;
    
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
        #70; rinc = 1;
        #10; winc = 0;
        #100; rinc = 0;
        #10;  rinc = 1; winc = 1;
    
        #100;
        $finish();

    end
    integer i;
    initial begin
        wait(winc==1);
        //#11;       
        for(i=0;i<=100;i=i+1) begin
            wdata = i;
            @(posedge wclk);
        end 
    end

    always #1   wclk = ~wclk;
    always #4   rclk = ~rclk;


    async_fifo_2 #(
    .DATESIZE                       ( DATESIZE     ),
    .ADDRSIZE                       ( ADDRSIZE     ) )
    u_async_fifo_2(
    .wdata                          ( wdata ),
    .winc                           ( winc  ),
    .wclk                           ( wclk  ),
    .w_rstn                         ( w_rstn),
    .rinc                           ( rinc  ),
    .rclk                           ( rclk  ),
    .r_rstn                         ( r_rstn),
    .rdata                          ( rdata ),
    .wfull                          ( wfull ),
    .rempty                         ( rempty)
    
    );




endmodule //async_fifo_2_tb