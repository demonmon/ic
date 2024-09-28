module cdc_syncfifo_tb ();

    parameter DWIDTH = 8;
    reg wclk,w_rstn;
    reg w_en;
    reg [DWIDTH-1:0] wdata;
    wire wrdy;

    reg rclk,r_rstn;
    reg r_en;
    wire rrdy;
    wire [DWIDTH-1:0] rdata;

    integer i;

    always #1 wclk = ~wclk;
    always #4 rclk = ~rclk;
    initial begin
        wclk = 0;
        rclk = 0;
        w_rstn = 0;
        r_rstn = 0;
        w_en = 0;
        r_en = 0;
        wdata = 0;

        #1; w_rstn = 1; r_rstn = 1;
        #1; w_en = 1; r_en = 1; 

        #100;
        $finish();

    end
    always begin
        for ( i = 1 ; i <= 50  ; i = i+1 ) begin
            wdata = i;
            @(posedge wclk);
        end
    end
    cdc_syncfifo  #(.DWIDTH(DWIDTH)) u_cdc_syncfifo (
        .wclk(wclk),
        .w_rstn(w_rstn),
        .w_en (w_en),
        .wdata(wdata),
        .wrdy (wrdy),

        .rclk(rclk),
        .r_rstn(r_rstn),
        .r_en  (r_en),
        .rrdy  (rrdy),
        .rdata (rdata)
    );

endmodule //cdc_syncfifo_tb