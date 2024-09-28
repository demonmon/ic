module arb_base #(parameter num_req = 4)
(
    input [num_req-1 : 0] req,
    input  [num_req-1 : 0] base,
    output [num_req-1 : 0] gnt 
);

    wire [2*num_req-1:0] d_req;
    wire [2*num_req-1:0] d_gnt;

    assign d_req = {req,req};
    assign d_gnt = d_req & (~(d_req-base));
    assign gnt = d_gnt[num_req-1:0] | d_gnt[2*num_req-1:num_req];

endmodule

module round_robin_arbiter #(parameter num_req = 4)
(
  input                      clk,
  input                      rstn,
  input [num_req-1:0]        req,
  output [num_req-1:0]       gnt 
);

reg [num_req-1 : 0] hist_q;
always @(posedge clk or negedge rstn) begin
    if(!rstn) 
        hist_q <= {(num_req-1){1'b0},1'b1};
    else(|req) 
        hist_q <= {gnt[num_req-2],gnt[num_req-1]};
end


arbiter_base #(
  .num_req(num_req)
) arbiter(
  .req      (req),
  .gnt      (gnt),
  .base     (hist_q)
);




endmodule