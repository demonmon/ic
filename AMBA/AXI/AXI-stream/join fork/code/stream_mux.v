module stream_mux #(
    parameter DATA_WD = 4
)(
    input  clk,
    input  rstn,

    input                   sel,
    input [DATA_WD-1:0]     a_data,
    input                   a_valid,
    //input                   a_last,
    output                  a_ready,

    input [DATA_WD-1:0]     b_data,
    input                   b_valid,
    output                  b_ready,

    output [DATA_WD-1:0]  c_data,
    output                  c_valid,
    input                   c_ready
);
wire c_fire;
wire a_fire;
wire b_fire;
assign c_fire = c_valid && c_ready;
assign a_fire = a_valid && a_ready;
assign b_fire = b_valid  && b_ready;

assign c_data = sel ? b_data : a_data;
assign c_valid = sel ? b_valid : a_valid;
assign a_ready = sel ? 1'b0 : c_ready;
assign b_ready = sel ? c_ready : 1'b0;


endmodule //stream_mux