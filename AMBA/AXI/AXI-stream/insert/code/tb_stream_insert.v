module tb_stream_insert;

// stream_insert Parameters
parameter PERIOD        = 10                 ;
parameter DATA_WD       = 32                 ;
parameter DATA_BYTE_WD  = DATA_WD / 8        ;
parameter BYTE_CNT_WD   = $clog2(DATA_BYTE_WD);

// stream_insert Inputs
reg   clk                                 ;
reg   rstn                                ;
reg   valid_in                            ;
reg   [DATA_WD-1 : 0]  data_in            ;
wire   last_in                             ;
wire   [DATA_BYTE_WD-1 : 0]  keep_in       ;
reg   ready_out                           ;
reg   valid_insert                        ;
reg   [DATA_WD-1 : 0]  data_insert        ;
wire   [DATA_BYTE_WD-1 : 0]  keep_insert   ;
reg   [BYTE_CNT_WD-1 : 0]  byte_insert_cnt;

// stream_insert Outputs
wire  ready_in                             ;
wire  valid_out                            ;
wire  [DATA_WD-1 : 0]  data_out            ;
wire  last_out                             ;
wire  [DATA_BYTE_WD-1 : 0]  keep_out       ;
wire  ready_insert                         ;
reg   [BYTE_CNT_WD-1:0] last_invalid_byte_cnt;
reg [1:0] data_beat_cnt;
assign last_in = & data_beat_cnt;
assign keep_in = last_in ? ~((1 << last_invalid_byte_cnt) - 1) : ((1 << DATA_BYTE_WD ) -1);
assign keep_insert = (1 << DATA_BYTE_WD ) -1;
//
wire                            fire_in;
wire                            fire_out;
wire                            fire_insert;
assign fire_in = valid_in && ready_in;
assign fire_out = valid_out && ready_out;
assign fire_insert = valid_insert && ready_insert;

always@(posedge clk or negedge rstn) begin
    if (!rstn) begin
        data_in <= $random;
        data_insert <= $random;
    end else begin 
        if (fire_in) begin
            data_in <= $random; 
        end
        if (fire_insert) begin
            data_insert <= $random;
        end

    end
end

always@(posedge clk or negedge rstn) begin
    if (!rstn) begin
        byte_insert_cnt <= 'b0;
        data_beat_cnt <= 'b0;
        last_invalid_byte_cnt <= 'b0;
    end else begin
        byte_insert_cnt <= byte_insert_cnt + fire_insert;
        data_beat_cnt <= data_beat_cnt + fire_in;
        if (fire_out && last_out && (&byte_insert_cnt)) begin
             last_invalid_byte_cnt <= last_invalid_byte_cnt + 1'b1; 
             if (last_invalid_byte_cnt == DATA_BYTE_WD - 1) begin
                last_invalid_byte_cnt <= 'b0;
            end
        end            
    end
end

localparam  RANDOM = 1'b0;
generate if (RANDOM) begin
    always@(posedge clk or negedge rstn) begin
        if (!rstn) begin
            valid_insert <= 1'b0;
            valid_in <= 1'b0;
            ready_out <= 1'b1;
        end else begin
            if (!valid_insert || ready_insert) begin
                valid_insert <= $random;
            end
            if (!valid_in || ready_in) begin
                valid_in <= $random;
            end
            ready_out <= $random;
        end
    end
end else begin
    always@(posedge clk or negedge rstn) begin
        if (!rstn) begin
            valid_insert <= 1'b0;
            valid_in <= 1'b0;
            ready_out <= 1'b1;
        end else begin
            
            valid_insert <= 1'b1;
            valid_in <= 1'b1;
            ready_out <= 1'b1;
        end
    end
end
    
endgenerate







initial
begin
    clk = 0;
    forever #(PERIOD/2)  clk=~clk;
end

initial
begin
    rstn = 0;
    #(PERIOD*2) rstn  =  1;
end
initial begin
    $dumpfile("test.vcd");
    $dumpvars;
end

stream_insert #(
    .DATA_WD      ( DATA_WD      ),
    .DATA_BYTE_WD ( DATA_BYTE_WD ),
    .BYTE_CNT_WD  ( BYTE_CNT_WD  ))
 u_stream_insert (
    .clk                     ( clk                                   ),
    .rstn                    ( rstn                                  ),
    .valid_in                ( valid_in                              ),
    .data_in                 ( data_in          [DATA_WD-1 : 0]      ),
    .last_in                 ( last_in                               ),
    .keep_in                 ( keep_in          [DATA_BYTE_WD-1 : 0] ),
    .ready_out               ( ready_out                             ),
    .valid_insert            ( valid_insert                          ),
    .data_insert             ( data_insert      [DATA_WD-1 : 0]      ),
    .keep_insert             ( keep_insert      [DATA_BYTE_WD-1 : 0] ),
    .byte_insert_cnt         ( byte_insert_cnt  [BYTE_CNT_WD-1 : 0]  ),

    .ready_in                ( ready_in                              ),
    .valid_out               ( valid_out                             ),
    .data_out                ( data_out         [DATA_WD-1 : 0]      ),
    .last_out                ( last_out                              ),
    .keep_out                ( keep_out         [DATA_BYTE_WD-1 : 0] ),
    .ready_insert            ( ready_insert                          )
);

initial
begin
    #5000
    $finish;
end

endmodule