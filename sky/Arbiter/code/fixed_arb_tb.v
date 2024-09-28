`timescale 1ns/1ps
module arb_tb ();
    reg clk;
    reg rstn;
    reg  [3:0] req;
    wire [3:0] gnt;
    integer i;
    initial begin
        req = 4'b0000;
        rstn = 0;
        clk = 0;
        #2rstn = 1;
        
        @(posedge clk) req = 4'b1101;
        for ( i = 0 ; i<=15 ; i=i+1 ) begin
            @(posedge clk);
            req  = i;
        end
        for ( i= 0;i<=50 ; i=i+1) begin
            @(posedge clk);
            req = {$random} % 16;
        end
        #200 $finish();
    end
    always #5 clk = ~clk;
    round_arb u(
        .req(req),
        .clk(clk),
        .rstn(rstn),
        .gnt(gnt)

    );




endmodule //fixed_arb_tb