/* 



wrap : 
i_last_addr = 124  i_size = 2^2 = 4 i_len = 7(7+1=8) 
124 = 0111_1100    120 = 0111_1000
下界 = 124/32*32=3*32=96   上界 = 96+32 = 128
o_next = 124+4=128 = 1000_0000;  o_next = 120+4 = 124
wrap_mask = 0010_0000 - 1 = 0001_1111 (小于32的位都是1)
o_next = last & ~wrap_mask  | o_next & mask
124 : o_next = 0110_0000;
120 : o_next = 0111_1100;
个人理解：因为主要应用在Cache操作中，因为cache是按照cache line进行操作，
采用wrap传输可以方便的实现从内存中取回整个cache line。
此次就是总字节数是32，那么last & ~wrap_mask表明的是此地址代表第几个cahce linne也就是下界
o_next & mask 该低地址表明相对于下界你相对位移，
如果一旦达到回环边界一定会进位导致高位加一(到另一个cahch line)，地位变0
所以我们要高位还是该cahch line ，低位从下界开始
i_last_addr = 124 = 0110_0000;第三个cahch line(3*32)
128 = 1000_0000;(4*32 第四个)，我们只需要的是前五位即可，高三位不变和last_addr保持一样

*/
module faxi_addr #(
    parameter AW = 32
)(
    input      [AW-1:0]     i_last_addr,
    input      [2:0]        i_size,
    input      [1:0]        i_burst,
    input      [7:0]        i_len,
    output reg [7:0]        o_incr,
    output reg [AW-1 : 0]   o_next_addr
);

localparam [1:0] FIXED = 2'b00;
localparam [1:0] INCR = 2'b01;
localparam [1:0] WRAP = 2'b10;

reg [AW-1:0] wrap_mask, increment;
always@(*) begin
    increment = 0;
    if (i_burst != FIXED) begin
        case (i_size)
            3'd0 :  increment = 1;
            3'd1 :  increment = 2;
            3'd2 :  increment = 4;  
            3'd3 :  increment = 8;
            3'd4 :  increment = 16;
            3'd5 :  increment = 32;
            3'd6 :  increment = 64;
            3'd7 :  increment = 128;
        endcase
    end else begin
        increment = 0;
    end
end

//aligned
always @(*) begin
    o_next_addr = i_last_addr + increment;
    if (i_burst != FIXED) begin
        if (i_size == 1) begin
            o_next_addr[0] = 0;
        end else if ((i_size == 2) && (AW >= 2)) begin
            o_next_addr[1:0] = 0;
        end else if ((i_size == 3) && (AW >= 3)) begin
            o_next_addr[2:0] = 0;
        end else if ((i_size == 4) && (AW >= 4)) begin
            o_next_addr[3:0] = 0;
        end else if ((i_size == 5) && (AW >= 5)) begin
            o_next_addr[4:0] = 0;
        end else if ((i_size == 6) && (AW >= 6)) begin
            o_next_addr[5:0] = 0;
        end else if ((i_size == 7) && (AW >= 7)) begin
            o_next_addr[6:0] = 0;
        end
    end
    if (i_burst == WRAP) begin
        o_next_addr = (i_last_addr & ~wrap_mask)  | (o_next_addr & wrap_mask);
    end
end



always@(*) begin
    wrap_mask = 'b0;
    if (i_burst == WRAP) begin
        if (i_len == 1) begin  //len = 2
            wrap_mask = 1 << (i_size + 1);
        end else if (i_len == 3) begin
            wrap_mask = 1 << (i_size + 2);
        end else if (i_len == 7) begin
            wrap_mask = 1 << (i_size + 3);
        end else if (i_len == 15) begin
            wrap_mask = 1 << (i_size + 4);
        end
        wrap_mask = wrap_mask - 1;
    end
    
end

always@(*) begin
    o_incr = 0;
    o_incr[((AW>7) ? 7 : AW-1):0] = increment[((AW>7) ? 7 : AW-1):0];
end





endmodule //faxi_addr