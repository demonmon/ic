module weight_round_robin_arbiter #(
    parameter REQ_NUM = 8
)(
    input                   clk,
    input                   rstn,
    input  [REQ_NUM-1:0]    req,
    input                   en,
    output [REQ_NUM-1:0]    grant
);
localparam NUM_WD = log2(REQ_NUM);
reg [NUM_WD-1:0] weight [REQ_NUM-1:0];
wire  [5:0] counter0;
wire  [5:0] counter1;
wire  [5:0] counter2;
wire  [5:0] counter3;
assign counter0 = weight[0];
assign counter1 = weight[1];
assign counter2 = weight[2];
assign counter3 = weight[3];

reg  [REQ_NUM-1:0] mask;
wire [REQ_NUM-1:0] mask_req;
wire [REQ_NUM-1:0] mask_grant;
wire has_mask_req;

wire [REQ_NUM-1:0] unmask_req;
wire [REQ_NUM-1:0] unmask_grant;

assign mask_req = req & mask;
assign mask_grant = mask_req & (~(mask_req-1));
assign has_mask_req = |mask_req;

assign unmask_grant = req & ~(req-1);
assign grant = mask_grant | {REQ_NUM{~has_mask_req}} & unmask_grant;

reg [NUM_WD-1:0] grant_id;
integer i;
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        mask <= {REQ_NUM{1'b1}};
        for (i = 0; i < REQ_NUM; i = i + 1) begin
            weight[i] <= REQ_NUM-i;
        end
    end else if(en) begin
        if(~(|mask)) begin
            mask <= {REQ_NUM{1'b1}};
            for (i = 0; i < REQ_NUM; i = i + 1) begin
                weight[i] <= REQ_NUM-i;
            end
        end else if(has_mask_req) begin
            weight[grant_id] <= weight[grant_id] - 1;
            mask[grant_id] <= (weight[grant_id] != 1) ? 1'b1 : 1'b0;
        end
    end
end


//select grant id


integer id = 0;
always @(*) begin
    for ( id = 0; id < REQ_NUM; id = id + 1) begin
        if (grant[id]) begin
            grant_id = id;//grant_r[0] = 0,1的情况是一样 grant_id = 0;
        end
            //grant_en = 1'b1;
    end 
    
end

function integer log2 (input integer num);
begin
    log2 = 0;
    while (num >> log2) begin
        //num = num >> 1;
        log2 = log2 + 1;
    end
end
    
endfunction

endmodule //weight_round_robin_arbiter