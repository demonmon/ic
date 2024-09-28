`timescale  1ns / 1ps      

module tb_stream_join;     

// stream_join Parameters  
parameter PERIOD    = 10  ;
parameter DATA_WD   = 4  ;
parameter HAS_LAST  = 1'b1;

// stream_join Inputs
reg   clk                   ;
reg   rstn                  ;
reg   [DATA_WD-1:0]  a_data ;
reg   a_valid               ;
reg   a_last                ;
reg   [DATA_WD-1:0]  b_data ;
reg   b_valid               ;
reg   c_ready               ;

// stream_join Outputs
wire  a_ready                              ;
wire  b_ready                              ;
wire  [2*DATA_WD-1:0]  c_data              ;
wire  c_valid                              ;

//fire 
wire  a_fire,b_fire,c_fire;
assign a_fire = a_valid && a_ready;
assign b_fire = b_valid && b_ready;
assign c_fire = c_valid && c_ready;

initial
begin
    clk = 0;
    forever #(PERIOD/2)  clk=~clk;
end

initial
begin
    rstn = 0;
    #(PERIOD*2) rstn  =  1; //a_last = 1;

    #5000 $finish();
end
initial begin
    $dumpfile("test.vcd");
    $dumpvars;
end

always @(*) begin
    if (a_data == 4'd15) begin
        a_last = 1;
    end else begin
        a_last = 0;
    end
end

localparam RANDOM_FIRE = 1'b1;

generate if (RANDOM_FIRE) begin // random fire

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            a_valid <= 1'b0;
            a_data <= 'b0;
            b_valid <= 1'b0;
            b_data <= 'b0;
            a_last <= 0;
        end
        else begin
            if (!a_valid) begin
                a_valid <= $random;
            end
            else if (a_valid && a_ready) begin
                a_valid <= $random;
                a_data <= a_data + 1'b1;
                
            end
            if (!b_valid) begin
                b_valid <= $random;
            end else if (b_valid && b_ready) begin
                b_valid <= $random;
                b_data <= b_data + 1'b1;
            end
        end
    end

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            c_ready <= 1'b1;
        end
        else begin
            c_ready <= $random;
        end
    end
end

else begin // fire always

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            a_valid <= 1'b0;
            a_data <= 'b0;
            b_valid <= 1'b0;
            b_data <= 'b0;
        end
        else begin
            a_valid <= 1'b1;
            b_valid <= 1'b1;
            if (a_fire) begin
                a_data <= a_data + 1'b1;
            end
            if (b_fire) begin
                b_data <= b_data + 1;
            end
        end
    end

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            c_ready <= 1'b1;
        end
        else begin
            c_ready <= 1'b1;
        end
    end

end
endgenerate

stream_join #(
    .DATA_WD  ( DATA_WD  ),
    .HAS_LAST ( HAS_LAST ))
 u_stream_join (
    .clk                     ( clk                      ),
    .rstn                    ( rstn                     ),
    .a_data                  ( a_data   [DATA_WD-1:0]   ),
    .a_valid                 ( a_valid                  ),
    .a_last                  ( a_last                   ),
    .b_data                  ( b_data   [DATA_WD-1:0]   ),
    .b_valid                 ( b_valid                  ),
    .c_ready                 ( c_ready                  ),

    .a_ready                 ( a_ready                  ),
    .b_ready                 ( b_ready                  ),
    .c_data                  ( c_data   [DATA_WD-1:0] ),
    .c_valid                 ( c_valid                  )
);



endmodule