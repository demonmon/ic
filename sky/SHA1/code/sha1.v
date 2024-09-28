module sha1 (
    input           clk,
    input           rstn,
    input           din_vld,//16T
    input  [31:0]   din,
    input           use_prec_cv,
    output reg      busy,
    output [159:0]  dout,
    output reg      dout_vld //1T
);
parameter   H0 = 32'h67452301,
            H1 = 32'hEFCDAB89,
            H2 = 32'h98BADCFE,
            H3 = 32'h10325476,
            H4 = 32'hC3D2E1F0;
            //K0 = 32'h5A827999,
            //K1 = 32'h6ED9EBA1,
            //K2 = 32'h8F1BBCDC,
            //K3 = 32'hCA62C1D6;
//-------------------------W(t) generation------------------------//
reg din_vld_d;
reg  [6:0]   w_cnt;
reg  [31:0]  w_reg [15:0];
reg          w_busy;

wire [31:0] r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,r13,r14,r15;
//assign r0 = w_reg[0];
//assign r1 = w_reg[1];
//assign r2 = w_reg[2];
//assign r3 = w_reg[3];
//assign r4 = w_reg[4];
//assign r5 = w_reg[5];
//assign r6 = w_reg[6];
//assign r7 = w_reg[7];
//assign r8 = w_reg[8];
//assign r9 = w_reg[9];
//assign r10 = w_reg[10];
//assign r11 = w_reg[11];
//assign r12 = w_reg[12];
//assign r13 = w_reg[13];
//assign r14 = w_reg[14];
//assign r15 = w_reg[15];


wire [31:0] next_reg;
wire [31:0] next_reg_xor;
assign next_reg_xor = w_reg[13]^w_reg[8]^w_reg[2]^w_reg[0];
assign next_reg = {next_reg_xor[30:0],next_reg_xor[31]};

always@(posedge clk or negedge rstn) begin
    if (!rstn) begin
        w_cnt <= 'b0;
    end else if (din_vld || w_busy) begin
        w_cnt <= w_cnt + 1;
        if (w_cnt == 'd79) begin
            w_cnt <= 'b0;
        end
    end
end

always@(posedge clk or negedge rstn) begin
    if (!rstn) begin
        w_busy <= 1'b0;//enable
    end else if (din_vld) begin
        w_busy <= 1'b1;
    end else if (w_cnt == 'd79) begin
        w_busy <= 1'b0;
    end
end

generate
    genvar i;
    for (i = 0; i < 15; i = i+1) begin
        always@(posedge clk or negedge rstn) begin
            if (!rstn) begin
                w_reg[i] <= 'b0;
            end else begin
                w_reg[i] <= w_reg[i+1];
            end
        end
    end

endgenerate

always@(posedge clk or negedge rstn) begin
    if (!rstn) begin
        w_reg[15] <= 'b0;
    end else if (din_vld) begin
        w_reg[15] <= din;
    end else if (w_busy) begin
        w_reg[15] <= next_reg;
    end 
    
end

always@(posedge clk or negedge rstn) begin
    if (!rstn) begin
        din_vld_d <= 0;
    end else begin
        din_vld_d <= din_vld;
    end
end

// -------------------------------------------------------
// -- 核心计算
// -------------------------------------------------------
reg [31:0] h0,h1,h2,h3,h4;
assign dout = {h0,h1,h2,h3,h4};

reg [31:0] A_reg,B_reg,C_reg,D_reg,E_reg;
wire [31:0] A_next;
reg [31:0] k;
reg [31:0] fx;
reg     a_e_busy;
reg     a_e_busy_d;
assign A_next = {A_reg[26:0],A_reg[31:27]} + fx + E_reg + w_reg[15] + k;


always@(posedge clk or negedge rstn) begin
    if (!rstn) begin
        A_reg <= H0;
        B_reg <= H1;
        C_reg <= H2;
        D_reg <= H3;
        E_reg <= H4;
    end else if (din_vld && !din_vld_d) begin
        if (use_prec_cv) begin
            A_reg <= h0;
            B_reg <= h1;
            C_reg <= h2;
            D_reg <= h3;
            E_reg <= h4;
        end else  begin
            A_reg <= H0;
            B_reg <= H1;
            C_reg <= H2;
            D_reg <= H3;
            E_reg <= H4;
        end
    end else if (a_e_busy) begin
        A_reg <= A_next;
        B_reg <= A_reg;
        C_reg <= {B_reg[1:0],B_reg[31:2]};
        D_reg <= C_reg;
        E_reg <= D_reg;
    end
end
reg [1:0] stage_cal;
always@(posedge clk or negedge rstn) begin
    if (!rstn) begin
        stage_cal <= 'b0;
    end else if (din_vld && !din_vld_d) begin
        stage_cal <= 'b0;
    end else if ((w_cnt=='d20) || (w_cnt=='d40) || (w_cnt=='d60)) begin
        stage_cal <= stage_cal + 1;
    end
end
always @(*) begin
    case (stage_cal)
        'd0 : 
            begin
                k = 32'h5A827999;
                fx = (B_reg & C_reg) |((~B_reg) & D_reg);
            end
        'd1 :
            begin
                k = 32'h6ED9EBA1;
                fx = (B_reg ^ C_reg ^ D_reg);
            end
        'd2 :
            begin
                k = 32'h8F1BBCDC;
                fx = (B_reg & C_reg) |(B_reg & D_reg) | (C_reg & D_reg);
            end
        'd3 :
            begin
                k = 32'hCA62C1D6;
                fx = (B_reg ^ C_reg ^ D_reg);
            end
    endcase
end


always@(posedge clk or negedge rstn) begin
    if (!rstn) begin
        {a_e_busy_d,a_e_busy} <= 'b0;
    end else begin
        {a_e_busy_d,a_e_busy} <= {a_e_busy,din_vld|w_busy};
    end
end

always@(posedge clk or negedge rstn) begin
    if (!rstn) begin
        h0 <= H0;
        h1 <= H1;
        h2 <= H2;
        h3 <= H3;
        h4 <= H4;
    end else if (din_vld && (!din_vld_d)) begin
        if (use_prec_cv) begin
            h0 <= H0;
            h1 <= H1;
            h2 <= H2;
            h3 <= H3;
            h4 <= H4;
        end
    end else if (!a_e_busy && a_e_busy_d) begin
        //`ifndef _SHA_STAND_ALGORUTHM_
        //    h0 <= A_reg;
        //    h1 <= B_reg;
        //    h2 <= C_reg;
        //    h3 <= D_reg;
         //   h4 <= E_reg;
        //`else 
            h0 <= A_reg + H0;
            h1 <= B_reg + H1;
            h2 <= C_reg + H2;
            h3 <= D_reg + H3;
            h4 <= E_reg + H4;
        //`endif 
    end
end


always@(posedge clk or negedge rstn) begin
    if (!rstn) begin
        dout_vld <= 1'b0;
    end else if (!a_e_busy && a_e_busy_d) begin
        dout_vld <= 1'b1;
    end else begin
        dout_vld <= 1'b0;
    end
end

always@(posedge clk or negedge rstn) begin
    if (!rstn) begin
        busy <= 1'b0;
    end else if (din_vld && !din_vld_d) begin
        busy <= 1'b1;
    end else if (!a_e_busy && a_e_busy_d) begin
        busy <= 1'b0;
    end
end












endmodule //sha1