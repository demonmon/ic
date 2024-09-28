//`include "stream_remove.v"
`timescale  1ns / 1ps

module tb_stream_remove;

// stream_remove Parameters
parameter PERIOD        = 10               ;
parameter DATA_WD       = 32               ;
parameter DATA_BYTE_WD  = DATA_WD / 8      ;
parameter BYTE_CNT_WD   = $clog2(DATA_BYTE_WD);

// stream_remove Inputs
reg   clk                                  ;
reg   rstn                                 ;
reg   valid_in                             ;
reg   [DATA_WD-1 : 0]  data_in             ;
wire   last_in                              ;
wire   [DATA_BYTE_WD-1 : 0]  keep_in        ;
wire   [DATA_BYTE_WD-1 : 0]  keep_out       ;
reg   ready_out                            ;
reg   valid_remove                         ;
reg   [BYTE_CNT_WD-1 : 0]  byte_remove_cnt ;

// stream_remove Outputs
wire  ready_in                             ;
wire  valid_out                            ;
wire  [DATA_WD-1 : 0]  data_out            ;
wire  last_out                             ;
wire  ready_remove                         ;


reg   [BYTE_CNT_WD-1:0]        last_byte_cnt;
//reg   [BYTE_CNT_WD-1:0]        remove_cnt;
wire                            fire_in;
wire                            fire_out;
wire                            fire_remove;
assign fire_in = valid_in && ready_in;
assign fire_out = valid_out && ready_out;
assign fire_remove = valid_remove && ready_remove;

reg [1:0] data_beat_cnt;
assign last_in = &data_beat_cnt;
assign keep_in = last_in ? ~((1 << last_byte_cnt) - 1) 
                : ((1 << DATA_BYTE_WD ) -1);

always@(posedge clk or negedge rstn) begin
    if (!rstn) begin
        byte_remove_cnt <= 1'b0;
    end else if (fire_remove) begin
        byte_remove_cnt <= byte_remove_cnt + 1;
    end
end

always@(posedge clk or negedge rstn) begin
    if (!rstn) begin
        data_beat_cnt <= 'b0;
        last_byte_cnt <= 'b0;
    end else begin
        data_beat_cnt <= data_beat_cnt + fire_in;
        last_byte_cnt <= last_byte_cnt + (fire_out && last_out);
    end
end

always@(posedge clk or negedge rstn) begin
    if (!rstn) begin
        data_in <= $random;
    end else if (fire_in) begin
        data_in <= $random;        
    end
end
localparam  RANDOM = 1'b1;
generate if (RANDOM) begin
    always@(posedge clk or negedge rstn) begin
        if (!rstn) begin
            valid_remove <= 1'b0;
            valid_in <= 1'b0;
            ready_out <= 1'b1;
        end else begin
            if (!valid_remove || ready_remove) begin
                valid_remove <= $random;
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
            valid_remove <= 1'b0;
            valid_in <= 1'b0;
            ready_out <= 1'b1;
        end else begin
            
            valid_remove <= 1'b1;
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


stream_remove #(
    .DATA_WD      ( DATA_WD      ),
    .DATA_BYTE_WD ( DATA_BYTE_WD ))
 u_stream_remove (
    .clk                     ( clk             ),
    .rstn                    ( rstn            ),
    .valid_in                ( valid_in        ),
    .data_in                 ( data_in         ),
    .last_in                 ( last_in         ),
    .keep_in                 ( keep_in         ),
    .keep_out                ( keep_out        ),
    .ready_out               ( ready_out       ),
    .valid_remove            ( valid_remove    ),
    .byte_remove_cnt         ( byte_remove_cnt ),

    .ready_in                ( ready_in        ),
    .valid_out               ( valid_out       ),
    .data_out                ( data_out        ),
    .last_out                ( last_out        ),
    .ready_remove            ( ready_remove    )
);

initial
begin
    #5000;
    $finish;
end

endmodule