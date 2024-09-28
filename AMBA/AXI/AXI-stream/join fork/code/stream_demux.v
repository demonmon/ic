module stream_demux #(
    parameter DATA_WD = 32
)(
    input  clk,
    input  rstn,
    input                   sel,

    input [DATA_WD-1:0]     a_data,
    input                   a_valid,
    output                  a_ready,

    output [DATA_WD-1:0]    b_data,
    output                  b_valid,
    input                   b_ready,

    output [DATA_WD-1:0]    c_data,
    output                  c_valid,
    input                   c_ready
);
wire  a_fire,b_fire,c_fire;
assign a_fire = a_valid && a_ready;
assign b_fire = b_valid && b_ready;
assign c_fire = c_valid && c_ready;

assign b_data = a_data;
assign c_data = a_data;
assign {c_valid,b_valid} = sel ? {1'b0,a_valid} : {a_valid,1'b0};
assign a_ready = sel ? b_ready : c_ready;

endmodule //stream_demux