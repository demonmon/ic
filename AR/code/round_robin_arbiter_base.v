module round_robin_arbiter #(
    parameter REQ_NUM = 8
) (
    input                  clk,
    input                  rst_n,
    input [REQ_NUM-1 : 0]  reqs,
    output [REQ_NUM-1 : 0] grants
);

    reg [REQ_NUM-1 : 0]  mask;         //掩码，默认为11111111
    wire has_masked_reqs;
    wire [REQ_NUM-1 : 0] masked_reqs;
    wire [REQ_NUM-1 : 0] masked_grants;
    wire [REQ_NUM-1 : 0] unmasked_grants;
    
    assign has_masked_reqs = |masked_reqs;
    assign masked_reqs = mask & reqs;
    assign masked_grants = masked_reqs & ~(masked_reqs - 1'b1);
    assign unmasked_grants = reqs & ~(reqs - 1'b1);
    assign grants = has_masked_reqs ? masked_grants : unmasked_grants;

    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            mask <= {REQ_NUM{1'b1}};  //用{}扩展
        end
        else if(~(|mask)) begin
            mask <= {REQ_NUM{1'b1}};
        end
        else if(has_masked_reqs) begin
            mask <= ~(grants|(grants-1'b1));
        end
    end
    
    // reqs =                 8'b01010001;
    // mask =                 8'b11111100;
    // masked_reqs =          8'b01010000;
    // grants =               8'b00010000; 
    // grants-1 =             8'b00001111;
    // grants|(grants-1) =    8'b00011111;
    // ~(grants|(grants-1)) = 8'b11100000;      形成下一个mask的算法
    // next_mask =            8'b11100000;

endmodule