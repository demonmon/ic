//`include "./round_robin_arbiter_base.v"
module weight_hs_rr_arbiter #(
    parameter REQ_NUM = 8,
    parameter USE_LAST = 1'b1
)(
    input                   clk,
    input                   rstn,

    input  [REQ_NUM-1:0]    valid_in,// req
    input  [REQ_NUM-1:0]    payload_in,
    input  [REQ_NUM-1:0]    last_in,
    output [REQ_NUM-1:0]    ready_in,

    output                  valid_out,
    output                  payload_out,
    output                  last_out,
    input                   ready_out

   // input  [REQ_NUM-1:0]    req,
    //output [REQ_NUM-1:0]    grant
);
wire [REQ_NUM-1:0] fire_in;
assign fire_in = valid_in & ready_in;
localparam REQ_WD = log2(REQ_NUM);

wire [REQ_NUM-1:0]      grant;
wire [REQ_NUM-1:0]      req;
assign req = valid_in;

wire                    has_grant;
wire                    chang_grant;
reg [REQ_NUM-1:0]       grant_r;
reg                     locker;

/*
round_robin_arbiter_base #(
    .REQ_NUM ( REQ_NUM ))
 u_round_robin_arbiter_base (
    .clk                     ( clk    ),
    .rstn                    ( rstn   ),
    .req                     ( valid_in),
    .en                      (!locker ),
    .grant                   ( grant  )
);
*/

weight_round_robin_arbiter #(
    .REQ_NUM ( REQ_NUM ))
 u_weight_round_robin_arbiter (
    .clk                     ( clk                  ),
    .rstn                    ( rstn                 ),
    .req                     ( req    [REQ_NUM-1:0] ),
    .en                      ( !locker              ),

    .grant                   ( grant  [REQ_NUM-1:0] )
);

assign has_grant = |grant;

generate if (USE_LAST) begin
    assign chang_grant = valid_out && ready_out && last_in;
end else begin
    assign chang_grant = valid_out && ready_out;
end    
endgenerate
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        locker  <= 1'b0;
        grant_r <= 1'b0;
    end else if(has_grant && !locker) begin
        locker <= 1'b1;
        grant_r <= grant;
    end else if(chang_grant) begin
        locker <= 1'b0;
        grant_r <= 1'b0;
    end
end


//select grant id
reg [REQ_WD-1:0] grant_id;

integer id = 0;
always @(*) begin
    for ( id = 0; id < REQ_NUM; id = id + 1) begin
        if (grant_r[id]) begin
            grant_id = id;//grant_r[0] = 0,1的情况是一样 grant_id = 0;
        end
            //grant_en = 1'b1;
    end 
    
end


//assign grant_en = |grant_r ? 1'b1 : 1'b0;

//out put

assign valid_out = valid_in[grant_id] && grant_r[grant_id];
assign payload_out = payload_in[grant_id];
assign last_out = last_in[grant_id] && grant_r[grant_id];
//assign ready_in[grant_id] = ready_out && grant_r[grant_id];
assign ready_in = {REQ_NUM{ready_out}} & grant_r;


function integer log2 (input integer num);
begin
    log2 = 0;
    while (num >> log2) begin
        //num = num >> 1;
        log2 = log2 + 1;
    end
end
    
endfunction





endmodule//weight_hs_rr_arbiter
