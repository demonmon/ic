module axi_addr #(
    parameter AW = 32,
    parameter DW = 32
)(
    input      [AW-1:0]     i_last_addr,
    input      [2:0]        i_size,
    input      [1:0]        i_burst,
    input      [7:0]        i_len,
    //output reg [7:0]        o_incr,
    output reg [AW-1 : 0]   o_next_addr
);
localparam DSZ = $clog2(DW/8);//log2(byte)

localparam [1:0] FIXED = 2'b00;
localparam [1:0] INCR = 2'b01;
localparam [1:0] WRAP = 2'b10;

reg [AW-1:0] wrap_mask, increment;
//youhua increment
always @(*) begin
    increment = 0;
    if (DSZ == 0) begin
        increment = 1;
    end else if (DSZ == 1) begin//01
        increment = i_size[0] ? 2 : 1;
    end else if (DSZ == 2) begin  //0 1 2
        increment = i_size[1] ? 4 : (i_size[0] ? 2 : 1);  
    end else if (DSZ == 3) begin // 64bit, 0 1 2 3
        case (i_size[1:0])
            2'b00 : increment = 1;
            2'b01 : increment = 2;
            2'b10 : increment = 4;
            2'b11 : increment = 8;
        endcase
    end else  begin
        increment = (1 << i_size);
    end
end

always@(*) begin
    wrap_mask = 1'b1;
    if (i_burst == WRAP) begin
        if (DSZ < 2) begin // 0 1-->8 16bit
            wrap_mask = wrap_mask | ({{(AW-4){1'b0}}, i_len[3:0]} << i_size[0]); 
        end else if (DSZ < 4) begin // 2,3 --> 32 64bit
            wrap_mask = wrap_mask | ({{(AW-4){1'b0}}, i_len[3:0]} << i_size[1:0]);
        end else begin
            wrap_mask = wrap_mask | ({{(AW-4){1'b0}}, i_len[3:0]} << i_size);
        end

        if (AW > 12) begin
            wrap_mask[(AW - 1) : ((AW > 12) ? 12 : (AW - 1))] = 0;
        end

        //wrap_mask = wrap_mask - 1;
    end
    
end

//aligned
always @(*) begin
    o_next_addr = i_last_addr + increment;
    if (i_burst != FIXED) begin
        if (DSZ < 2) begin //0,1
            if (i_size[0]) begin
                o_next_addr[0] = 0;
            end
        end else if (DSZ < 4) begin
            case (i_size[1:0])
                2'b00 : o_next_addr = o_next_addr;
                2'b01 : o_next_addr[0] = 0;
                2'b10 : o_next_addr[1:0] = 0;
                2'b11 : o_next_addr[2:0] = 0; 
            endcase
        end else begin
            case (i_size)
                3'd0: o_next_addr = o_next_addr;
                3'd1: o_next_addr[0] = 0;
                3'd2: o_next_addr[((AW-1>1) ? 1 : AW-1):0] = 0;
                3'd3: o_next_addr[((AW-1>2) ? 2 : AW-1):0] = 0;
                3'd4: o_next_addr[((AW-1>3) ? 3 : AW-1):0] = 0;
                3'd5: o_next_addr[((AW-1>4) ? 4 : AW-1):0] = 0;
                3'd6: o_next_addr[((AW-1>5) ? 5 : AW-1):0] = 0;
                3'd7: o_next_addr[((AW-1>6) ? 6 : AW-1):0] = 0;
            endcase
        end
    end
    if (i_burst[1]) begin
        o_next_addr = (i_last_addr & ~wrap_mask)  | (o_next_addr & wrap_mask);
    end
    if (AW > 12) begin
        o_next_addr[AW-1 : 12]  = i_last_addr[AW-1 : 12];
    end


end







endmodule //axi_addr