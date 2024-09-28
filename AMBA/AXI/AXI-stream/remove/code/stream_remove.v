/*unaligned address :0xA
unaligned keep = 4'b1111
nearest aligned address = 0x8
aligned keep = 4'b00 11

data len = 7  0xA
1.unaligned(output 2 beat)

first beat
unali keep 4'b1111 ：10 11 12 13
last beat
ali keep 4'b1110 14 15 16 17（第八个数据不需要）

2.aligned (input 3 beat)
nearest addr : 0x8
aligned keep :4'b0011  
addr : 10 11
next addr: 0x12
aligned keep :4'b1111 
addr : 12 -15 
last addr :
aligned keep :4'b1000 -- 16

data len = 9    addr:0xA
1.unaligned(output 3 beat)
first beat:
unali keep 4'b1111 
addr:10 11 12 13
second beat
unali keep 4'b1111 
addr : 14 15 16 17
last beat:
unali keep 4'b1000
addr : 18

2.aligned  (input 3 beat)
nearest addr : 0x8
aligned keep :4'b0011 -- 10 11
next addr: 0x12
aligned keep :4'b1111 --12 -15
last addr :
aligned keep :4'b1000 -- 16


*/

module stream_remove #(
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
localparam DATA_BIT_WD = log2(DATA_WD);
wire                            fire_in;
wire                            fire_out;
wire                            fire_remove;
wire    [2*DATA_WD-1 : 0]       d_data;    
wire    [2*DATA_BYTE_WD-1 : 0]  d_keep;
wire    [2*DATA_BYTE_WD-1 : 0]  d_keep_last;           
wire    [BYTE_CNT_WD : 0]     byte_shift_cnt;
wire    [DATA_BIT_WD-1 : 0]     bit_shift_cnt;

wire                            extra_beat;
wire                            has_extra_keep;

reg [DATA_WD-1 : 0]         data_r;
reg [DATA_BYTE_WD-1 : 0]    keep_r;
reg                         valid_r;
reg                         extra_beat_r;
reg                         remove_r;
reg                         last_out_r;
wire                        has_extra_beat;
assign has_extra_keep = | (keep_in << byte_remove_cnt) ;
assign extra_beat = has_extra_beat && fire_in;
assign has_extra_beat = last_in && has_extra_keep;
    
assign fire_in = valid_in && ready_in;
assign fire_out = valid_out && ready_out;
assign fire_remove = valid_remove && ready_remove;


assign d_data = {data_r,data_in};
assign d_keep = {keep_r,keep_in};
assign d_keep_last = {keep_r,{DATA_BYTE_WD{1'b0}}};
assign byte_shift_cnt = DATA_BYTE_WD - byte_remove_cnt;
assign bit_shift_cnt = byte_shift_cnt << 3;

assign data_out = d_data >> bit_shift_cnt;
assign keep_out = extra_beat_r ? (d_keep_last >> byte_shift_cnt) : (d_keep >> byte_shift_cnt);

assign ready_in = !valid_r | (ready_out && valid_remove);
//assign last_out = last_in ? !extra_beat : extra_beat_r;
//assign ready_remove = (last_out && fire_out) ? 1'b1 : remove_r;
assign ready_remove = (last_out && fire_out);
assign valid_out = extra_beat_r ? valid_r : valid_r && valid_remove && valid_in;//要用当前数据必须要valid_in

assign last_out = last_in ? !has_extra_beat : extra_beat_r;


always@(posedge clk or negedge rstn) begin
    if (!rstn) begin
        data_r <= 'b0;
        keep_r <= 'b0;
        valid_r <= 1'b0;
    end else begin
        if (fire_out) begin
            valid_r <= 1'b0;
        end
        if (fire_in && last_in) begin
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

always@(posedge clk or negedge rstn) begin
    if (!rstn) begin
        extra_beat_r <= 1'b0;
        remove_r <= 1'b0;
        last_out_r <= 1'b0;
    end else begin
        if (extra_beat) begin
            extra_beat_r <= 1'b1;
        end else if (fire_out) begin
            extra_beat_r <= 1'b0;
        end
        
    end
end



function integer log2(input integer x);
begin
    log2 = 0;
    while (x >> log2) begin
        log2 = log2 + 1;
    end
end
        
endfunction




endmodule //stream_remove

