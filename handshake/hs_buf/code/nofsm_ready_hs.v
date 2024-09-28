module nofsm_ready_hs_buf  #(
    parameter DATA_WD = 32
)(
    input                       clk,
    input                       rstn,

    input                       valid_in,
    input  [DATA_WD-1 : 0]      data_in,
    output                      ready_in,

    output                      valid_out,
    output [DATA_WD-1 : 0]      data_out,
    input                       ready_out
    
);

reg                 valid_out_r;//bypaass
reg  [DATA_WD-1:0]  data_out_r;//缓存数据
reg                 ready_out_r;
wire                fire_in;
wire                fire_out;

parameter EMPTY = 2'b0, FULL = 2'b1;
reg        [1:0]    c_state,n_state; 



assign data_out = valid_out_r ? data_out_r : data_in;
assign valid_out = valid_out_r || valid_in;//直通信号(valid) + reg signal (valid_out_r)
assign ready_in = ready_out_r || !valid_out_r; //保证empty(直通)时候 ready_in一直是1


assign fire_in = valid_in && ready_in;
assign fire_out = valid_out && ready_out;

always @(posedge clk or negedge rstn) begin
    if(!rstn) 
        valid_out_r <= 1'b0;
    else begin
        if (fire_in && !fire_out) begin
            valid_out_r <= valid_out;
            data_out_r  <= data_in;
        end else if(!fire_in && fire_out) begin
            valid_out_r <= 1'b0;
        end
    end
            
end



always @(posedge clk or negedge rstn) begin
    if(!rstn)
        ready_out_r <= 1'b0;
    else
        ready_out_r <= ready_out;    
end




endmodule //nofsm_ready_hs