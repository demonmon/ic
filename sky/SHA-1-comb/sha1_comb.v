module sha1_comb (
    input                clk,
    input                rstn,
    
    input  [16*32-1 : 0] din,
    input                din_vld,
    input  [31 : 0]      h0,
    input  [31 : 0]      h1,
    input  [31 : 0]      h2,
    input  [31 : 0]      h3,
    input  [31 : 0]      h4,

    output reg           dout,
    output reg           dout_vld

);

wire [31:0] a [80:0];
wire [31:0] b [80:0];
wire [31:0] c [80:0];
wire [31:0] d [80:0];
wire [31:0] e [80:0];

wire [16*32-1:0] w [80:0];//81个512bit（64个w）
wire [5*32-1:0] h [80:0];
wire  vld [80:0];

assign a[0] = h0;
assign b[0] = h1;
assign c[0] = h2;
assign d[0] = h3;
assign e[0] = h4;
assign w[0] = din;//就是基于din去扩展W
assign vld[0] = din_vld;
assign h0 = {h4, h3, h2, h1, h0};

generate
    genvar i;
    for (i=0; i<80; i=i+1) begin
        sha1_loop #(.LOOP_NUM ( i )) u_sha1_loop (
            .clk                     ( clk ),
            .rstn                    ( rstn),

            .in_vld                  ( vld[i]),
            .w                       ( w[i]   ),
            .a                       ( a[i]   ),
            .b                       ( b[i]   ),
            .c                       ( c[i]   ),
            .d                       ( d[i]   ),
            .e                       ( e[i]   ),
            .h                       ( h[i]   ),

            .out_vld                 ( vld[i+1]),
            .w0                      ( w[i+1]  ),
            .a0                      ( a[i+1]  ),
            .b0                      ( b[i+1]  ),
            .c0                      ( c[i+1]  ),
            .d0                      ( d[i+1] ),
            .e0                      ( e[i+1]  ),
            .h0                      ( h[i+1]  )
        );

    end
endgenerate

wire [31:0] h0_nxt, h1_nxt, h2_nxt, h3_nxt, h4_nxt;
`ifdef _SHA_STAND_ALGORUTHM_ 
    assign h0_nxt = h[80][0*32 +: 32] + a[80];
    assign h1_nxt = h[80][1*32 +: 32] + b[80];
    assign h2_nxt = h[80][2*32 +: 32] + c[80];
    assign h3_nxt = h[80][3*32 +: 32] + d[80];
    assign h4_nxt = h[80][4*32 +: 32] + e[80];
`else 
    assign h0_nxt = h[80][0*32 +: 32] + a[80];
    assign h1_nxt = h[80][1*32 +: 32] + b[80];
    assign h2_nxt = h[80][2*32 +: 32] + c[80];
    assign h3_nxt = h[80][3*32 +: 32] + d[80];
    assign h4_nxt = h[80][4*32 +: 32] + e[80];
`endif

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        dout_vld <= 1'b0;
    end else if (vld[80]) begin
        dout_vld <= 1'b1;
    end
end

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        dout <= 1'b0;
    end else if (vld[80]) begin
        dout <= {h4_nxt, h3_nxt, h2_nxt, h1_nxt, h0_nxt};
    end
end



endmodule //sha1_comb