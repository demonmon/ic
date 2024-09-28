module stream_fork #(
    parameter DATA_WD = 32,
    parameter COMBO = 1'b0
)(
    input  clk,
    input  rstn,

    input [DATA_WD-1:0]     a_data,
    input                   a_valid,
    //input                   a_last,
    output                  a_ready,

    output [DATA_WD-1:0]    b_data,
    output                  b_valid,
    input                   b_ready,

    output [DATA_WD-1:0]    c_data,
    output                  c_valid,
    input                   c_ready
);

wire a_fire;
wire c_fire,b_fire;

assign a_fire = a_valid && a_ready;
assign b_fire = b_valid && b_ready;
assign c_fire = c_valid && c_ready;

assign b_data = a_data;
assign c_data = a_data;

generate if (COMBO) begin
    assign b_valid =a_fire; //a_valid;//
    assign c_valid =a_fire;//a_valid;
    assign a_ready = b_ready && c_ready;
end else begin
    reg b_vld,c_vld;
    
    assign c_valid = c_vld ? 0 : a_valid;
    assign b_valid = b_vld ? 0 : a_valid;// 0 1 -->1  0,0 --> 0     1,0 1,1-->0
    //assign b_valid = (a_fire && !b_vld) ;
    //assign c_valid = (a_fire && !c_vld) ; 
    assign a_ready = (b_ready && c_ready)  || (b_vld && c_fire) || (b_fire && c_vld) ;//|| (b_vld && c_vld);
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            b_vld <= 0;
            c_vld <= 0;
        end else begin
            if (b_fire) begin
                b_vld <= 1;
            end
            if (c_fire) begin
                c_vld <= 1;
            end
            if(a_fire) begin
                b_vld <= 0;
                c_vld <= 0;
            end
        end
    end

end
    
endgenerate



endmodule