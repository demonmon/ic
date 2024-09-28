module round_robin_arbiter_base #(
    parameter REQ_NUM = 8
)(
    input                   clk,
    input                   rstn,
    input  [REQ_NUM-1:0]    req,
    input                   en,
    output [REQ_NUM-1:0]    grant
);
reg  [REQ_NUM-1:0] base;
wire [2*REQ_NUM-1:0] double_req;
wire [2*REQ_NUM-1:0] double_gnt;
assign double_req = {req,req};
assign double_gnt = (~(double_req -  base)) & double_req;
assign grant = double_gnt[2*REQ_NUM-1:REQ_NUM] | double_gnt[REQ_NUM-1:0];

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        base <= 'b1;//{(REQ_NUM-1){1'b0}, 1'b1};
    end else if(en) begin 
        if(|req) begin
        //base[0] <= base[REQ_NUM-1];
        //base[REQ_NUM-1:1] <= base[REQ_NUM-2:0];
        //base <= {base[REQ_NUM-2:0],base[REQ_NUM-1]};
            base <= {grant[REQ_NUM-2:0],grant[REQ_NUM-1]};
        end
    end
end


endmodule



module round_robin_arbiter #(
    parameter REQ_NUM = 8
)(
    input                   clk,
    input                   rstn,
    input  [REQ_NUM-1:0]    req,
    output [REQ_NUM-1:0]    grant
);


reg  [REQ_NUM-1:0] mask;
wire [REQ_NUM-1:0] mask_req;
wire [REQ_NUM-1:0] mask_grant;
wire has_mask_req;

wire [REQ_NUM-1:0] unmask_req;
wire [REQ_NUM-1:0] unmask_grant;

assign mask_req = req & mask;
assign mask_grant = mask_req & (~(mask_req-1));
assign has_mask_req = |mask_req;

//wire [REQ_NUM-1:0] mask_pre_mask;
//assign mask_pre_mask[REQ_NUM-1:1] = mask_pre_mask[REQ_NUM-2:0] | mask_req[REQ_NUM-2:0];
//assign mask_grant = mask_req && ~mask_pre_mask;

assign unmask_grant = req & ~(req-1);
//assign grant = has_mask_req ? mask_grant : unmask_grant;
//has_mask_req=1--> mask_grant,
//has_mask_req=0-->mask_grant='b0,grant= unmask_grant
assign grant = mask_grant | {REQ_NUM{~has_mask_req}} & unmask_grant;

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        mask <= {REQ_NUM{1'b1}};
    end else if(~(|mask)) begin
        mask <= {REQ_NUM{1'b1}};
    end else if(has_mask_req) begin
        mask <= ~((grant-1) | grant);
    end
end

endmodule //round_robin_arbiter
















