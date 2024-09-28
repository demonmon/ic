/*
first beat:
keep_in:1111  keep_insert =0011;
keepout = 1111

last beat :
keep_in : 1000 keep_insert 0011
keepout :1110 ---> not has extra beat
keep_in : 1110 keep_insert 0011
keep_out : 1111
keep_out : 1000-->has extra beat
*/
module stream_insert #(
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

    input                           valid_insert,
    input   [DATA_WD-1 : 0]         data_insert,
    input   [DATA_BYTE_WD-1 : 0]    keep_insert,
    input   [BYTE_CNT_WD-1 : 0]     byte_insert_cnt,
    output                          ready_insert      
); 

localparam DATA_BIT_WD = $clog2(DATA_WD);

wire                            fire_in;
wire                            fire_out;
wire                            fire_insert;
wire    [2*DATA_WD-1 : 0]       d_data; 
wire    [2*DATA_WD-1 : 0]       d_data_first;  

wire    [2*DATA_BYTE_WD-1 : 0]  d_keep;
wire    [2*DATA_BYTE_WD-1 : 0]  d_keep_last;  
wire    [2*DATA_BYTE_WD-1 : 0]  d_keep_first;         
wire    [BYTE_CNT_WD : 0]       byte_shift_cnt;
wire    [DATA_BIT_WD-1 : 0]     bit_shift_cnt;

wire                            extra_beat;
wire                            has_extra_keep;
wire                            has_extra_beat;
wire [DATA_WD-1 : 0]            first_data;

reg                             extra_beat_r;
reg [DATA_WD-1 : 0]             data_r;
reg [DATA_BYTE_WD-1 : 0]        keep_r;
reg                             valid_r;
reg                             last_out_r;
reg                             first_beat;

assign has_extra_keep = | (keep_in << (3'b100 - byte_insert_cnt));
assign extra_beat = has_extra_beat && fire_in;
assign has_extra_beat = last_in && (has_extra_keep);

assign fire_in = valid_in && ready_in;
assign fire_out = valid_out && ready_out;
assign fire_insert = valid_insert && ready_insert;


assign d_data = {data_r,data_in};
assign d_data_first = {data_insert,data_in};


assign d_keep = {keep_r,keep_in};
assign d_keep_last = {keep_r,{DATA_BYTE_WD{1'b0}}};
assign d_keep_first = {keep_insert,keep_in};

assign byte_shift_cnt = byte_insert_cnt;
assign bit_shift_cnt = byte_shift_cnt << 3;

assign data_out = first_beat ? (d_data_first >> bit_shift_cnt) 
                    : (d_data>>bit_shift_cnt);
                    
//assign keep_out = extra_beat_r ? (d_keep_last >> byte_shift_cnt) : (d_keep >> byte_shift_cnt);
assign keep_out = first_beat ? (d_keep_first >> byte_shift_cnt) 
                    : (extra_beat_r ? (d_keep_last >> byte_shift_cnt) 
                    : (d_keep >> byte_shift_cnt));

assign ready_in = !valid_r || (ready_out && valid_insert && !extra_beat_r);

assign ready_insert = last_out && fire_out;


assign last_out = last_in ? !has_extra_beat : extra_beat_r;

assign valid_out = first_beat ? valid_insert && valid_in : 
                    (extra_beat_r ? valid_r : 
                        (valid_r && valid_in && valid_insert) ); //第一拍可以同时fire


always@(posedge clk or negedge rstn) begin
    if (!rstn) begin
        first_beat <= 1'b1;
    end else if (fire_out && last_out) begin
        first_beat <= 1'b1;
    end else if (fire_out) begin
        first_beat <= 1'b0;
    end
end



always@(posedge clk or negedge rstn) begin
    if (!rstn) begin
        extra_beat_r <= 1'b0;
        last_out_r <= 1'b0;
    end else begin
        if (extra_beat) begin
            extra_beat_r <= 1'b1;
        end else if (fire_out) begin
            extra_beat_r <= 1'b0;
        end
        
    end
end


always@(posedge clk or negedge rstn) begin
    if (!rstn) begin
        data_r <= 'b0;
        keep_r <= 'b0;
        valid_r <= 1'b0;
    end else begin
        if (fire_out) begin
            valid_r <= 1'b0;
        end
        if (has_extra_beat && fire_in) begin
            valid_r <= 1'b1;
        end else if (!has_extra_beat && fire_in) begin
            valid_r <= 1'b1;
        end else if (fire_in) begin
            valid_r <= 1'b1;
        end
        if (fire_in) begin
            data_r <= data_in;
            keep_r <= keep_in;
        end
    end
end










endmodule //stream_insert