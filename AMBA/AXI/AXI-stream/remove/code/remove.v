module remove #(
    parameter DATA_WD = 32,
    parameter DATA_BYTE_WD = DATA_WD / 8,
    parameter BYTE_CNT_WD = $clog2(DATA_BYTE_WD)
)(
    input                           clk,
    input                           rstn,

    input                           valid_in,
    input   [DATA_WD-1 : 0]         data_in,
    input                           last_in,
    input   [DATA_BYTE_WD-1 : 0]    keep_in,
    output                          ready_in,

    output                          valid_out,
    output  [DATA_WD-1 : 0]         data_out,
    output                          last_out,
    output   [DATA_BYTE_WD-1 : 0]   keep_out,
    input                           ready_out,
    
    input                           valid_remove,
    input   [BYTE_CNT_WD-1 : 0]     byte_remove_cnt,
    output                          ready_remove
);

wire fire_in,fire_out,fire_remove;
assign fire_in = valid_in && ready_in;
assign fire_out = valid_out && ready_out;
assign fire_remove = valid_remove && ready_remove;
reg [DATA_WD-1 : 0]         data_r;
reg [DATA_BYTE_WD-1 : 0]    keep_r;
wire    [2*DATA_WD-1 : 0]       d_data;    
wire    [2*DATA_BYTE_WD-1 : 0]  d_keep;
wire  [3:0] byte_shift_cnt = 4 - byte_remove_cnt;
wire  [5:0] bit_shift_cnt = byte_shift_cnt << 3;

assign data_out = {data_r, data_in} >> bit_shift_cnt;
assign keep_out = extra_beat_r ? ({keep_r, 32'b0}>>byte_shift_cnt)
                                : {keep_r, keep_in}>>byte_shift_cnt;


assign ready_in = !valid_r | (ready_out )                             
reg [DATA_WD-1 : 0] data_r;
reg [DATA_BYTE_WD-1 : 0] keep_r;
reg valid_r;




always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        data_r <= 'b0;
        keep_r <= 'b0;
        valid_r <= 1'b0;
    end else begin
        if (fire_out) begin
            valid_r <= 0;
        end
        f (fire_in && last_in) begin
            valid_r <= extra_beat;
        end else if (fire_in) begin
            valid_r <= 1'b1;
        end

        if (fire_in) begin
            data_r <= data_in;
            keep_r <= keep_in;
        end
    end
end


endmodule //remove