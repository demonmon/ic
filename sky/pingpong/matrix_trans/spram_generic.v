module spram_generic #(
    parameter ADDR_WIDTH = 7,
    parameter DATA_WIDTH = 32
    
) (
    input                         clk,
    input                         en,
    input                         we,
    input      [ADDR_WIDTH-1 : 0] addr,
    input      [DATA_WIDTH-1 : 0] din,
    output reg [DATA_WIDTH-1 : 0] dout
);
localparam  DEPTH = 1 << ADDR_WIDTH;
reg [DATA_WIDTH-1 : 0] mem [DEPTH-1 : 0];
always @(posedge clk ) begin
    if (en) begin
        if (we) begin
            mem[addr] <= din;
        end else begin
            dout <= mem[addr];
        end
    end
end



endmodule //spram_generic