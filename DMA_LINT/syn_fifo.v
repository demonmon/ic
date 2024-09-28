module syn_fifo #(
    parameter DATA_WD = 4,
    parameter DEPTH =16
) (
    input                  clk,
    input                  rstn,

    input  [DATA_WD-1 : 0] data_in,
    input                  valid_in,  
    output                 ready_in,

    input                  ready_out,
    output [DATA_WD-1 : 0] data_out,
    output                 valid_out
);

localparam ADDR_WD = $clog2(DEPTH);//ADDR_WD = 4 

reg [DATA_WD-1 : 0] mem [DEPTH-1 : 0];

wire fire_in, fire_out;
wire full,empty;

reg [ADDR_WD : 0] wptr,rptr;

assign fire_in = valid_in && ready_in;
assign fire_out = valid_out && ready_out;

assign full = (wptr[ADDR_WD] ^ rptr[ADDR_WD]) && (wptr[ADDR_WD-1:0] == rptr[ADDR_WD-1:0]);
assign empty = (rptr == wptr);

assign ready_in = !full;
assign valid_out = !empty;

assign data_out = mem[rptr[ADDR_WD-1:0]];


always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        wptr <= 'b0;
    end
    else if (fire_in) begin
        wptr <= wptr + 1;
    end   
end

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        rptr <= 'b0;
    end else if (fire_out) begin
        rptr <= rptr + 1;
    end   
end

always @(posedge clk or negedge rstn) begin
    if (fire_in) begin
        mem[wptr[ADDR_WD-2 : 0]] <= data_in;
    end
end

endmodule