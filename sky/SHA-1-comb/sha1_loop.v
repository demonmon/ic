module sha1_loop #(
    parameter LOOP_NUM = 0
)(
    input                clk,
    input                rstn,

    input in_vld,
    input [16*32-1 : 0] w,
    input [31 : 0] a,
    input [31 : 0] b,
    input [31 : 0] c,
    input [31 : 0] d,
    input [31 : 0] e,
    input [32*5-1 : 0] h,

    output reg out_vld,
    output reg [16*32-1 : 0]  w0,
    output reg [31 : 0]  a0,
    output reg [31 : 0]  b0,
    output reg [31 : 0]  c0,
    output reg [31 : 0]  d0,
    output reg [31 : 0]  e0,
    output reg [32*5-1 : 0]  h0
);


//h

`ifdef SHA_FULL_PIPE
always @(posedge clk) begin
    if (in_vld) begin
        h0 <= h;
    end
end
`else
always @(*) begin
    h0 = h;
end
`endif




//w: 16-->80
generate
    if (LOOP_NUM <= 14) begin
        `ifdef SHA_FULL_PIPE
            always @(posedge clk) begin
                if (in_vld) begin
                    w0 <= w;
                end
            end
        `else
            always @(*) begin
                w0 = w;
            end
        `endif 
        
    end else begin
        wire [31 : 0] w_0,w_2,w_8,w_13;
        assign w_0 = w[0 +: 32];
        assign w_2 = w[2*32 +: 32];
        assign w_8 = w[8*32 +: 32];
        assign w_13 = w[13*32 +: 32];
        wire [31:0] w_nxt, w_xor;
        assign w_xor = w_0 ^ w_2 ^ w_8 ^ w_13;
        assign  w_nxt = {w_xor[30:0], w_xor[31]};

        `ifdef SHA_FULL_PIPE
            always @(posedge clk) begin
                if (in_vld) begin
                    w0 <= {w_nxt, w[16*32-1 : 32]};
                end
            end
        `else
            always @(*) begin
                w0 = {w_nxt, w[16*32-1 : 32]};
            end
        `endif     
    end
endgenerate

// ABCDE update

wire [31:0] Kt;
wire [31:0] fx;
generate
    if (LOOP_NUM <= 19) begin
        assign Kt = 32'h5A827999;
        assign fx = (b&c) | ((~b)&d);
    end else if (LOOP_NUM <= 39) begin
        assign Kt = 32'h6ED9EBA1;
        assign fx = b ^ c ^ d;
    end else if (LOOP_NUM <= 59) begin
        assign Kt = 32'h8F1BBCDC;
        assign fx = (b&c)|(b&d)|(c&d);
    end else begin
        assign Kt = 32'hCA62C1D6;
        assign fx = b ^ c ^ d;
    end
endgenerate
wire [31:0] temp;
wire [31:0] Wt;
generate
    if (LOOP_NUM <=15) begin
        assign Wt = w[LOOP_NUM*32 +: 32];//wt有64个32bit，一开始可以配置16个 17个开始需要更新Wt
    end else begin
        assign Wt = w[15*32 +: 32];
    end
endgenerate

assign temp = {a[26:0],a[31:27]} + fx + e + Wt + Kt;

`ifdef SHA_FULL_PIPE
    always @(posedge clk) begin
        if (in_vld) begin
            a0 <= temp;
            b0 <= a;
            c0 <= {b[1:0],b[31:2]};
            d0 <= c;
            e0 <= d;
            out_vld <= in_vld;
        end
    end
`else
    always @(*) begin
        a0 = temp;
        b0 = a;
        c0 = {b[1:0],b[31:2]};
        d0 = c;
        e0 = d;
        out_vld = in_vld;
    end
`endif 









endmodule //sha1_loop