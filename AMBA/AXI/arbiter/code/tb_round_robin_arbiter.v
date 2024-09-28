`timescale  1ns / 1ps

module tb_round_robin_arbiter;

// round_robin_arbiter Parameters
parameter PERIOD   = 10;
parameter REQ_NUM  = 4;

// round_robin_arbiter Inputs
reg   clk               ;
reg   rstn              ;
reg   [REQ_NUM-1:0]  req;
// round_robin_arbiter Outputs
wire  [REQ_NUM-1:0]  grant                 ;


initial
begin
    clk = 0;
    forever #(PERIOD/2)  clk=~clk;
end

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        req <= 'b0;
    end else begin
        req <= req + 1;
    end
end
initial begin
    $dumpfile("test.vcd");
    $dumpvars(0,tb_round_robin_arbiter);
end

initial
begin
    rstn = 0;
    #(PERIOD*2) rstn  =  1;
end

weight_round_robin_arbiter #(
    .REQ_NUM ( REQ_NUM ))
 u_round_robin_arbiter (
    .clk                     ( clk                  ),
    .rstn                    ( rstn                 ),
    .req                     ( req    [REQ_NUM-1:0] ),

    .grant                   ( grant  [REQ_NUM-1:0] )
);

initial
begin
    #5000;
    $finish;
end

endmodule