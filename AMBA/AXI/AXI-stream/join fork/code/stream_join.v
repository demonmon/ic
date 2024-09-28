module stream_join #(
    parameter DATA_WD = 4,
    parameter HAS_LAST = 1'b0
)(
    input  clk,
    input  rstn,

    input [DATA_WD-1:0]     a_data,
    input                   a_valid,
    input                   a_last,
    output                  a_ready,

    input [DATA_WD-1:0]     b_data,
    input                   b_valid,
    output                  b_ready,

    output [2*DATA_WD-1:0]  c_data,
    output                  c_valid,
    input                   c_ready
);

wire c_fire;
wire a_fire;
wire b_fire;

assign c_data = {b_data,a_data};
assign c_valid = a_valid && b_valid;
assign c_fire = c_valid && c_ready;

assign a_fire = a_valid && a_ready;
assign b_fire = b_valid  && b_ready;

generate if (HAS_LAST) begin
    assign a_ready = c_fire;
    assign b_ready = c_fire && a_last;
end else begin
    assign a_ready = c_fire;
    assign b_ready = c_fire;
end
    
endgenerate






endmodule //stream_join