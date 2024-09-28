module tb_handshake();

// handshake Parameters
parameter PERIOD   = 10;
parameter DATA_WD  = 4;
parameter ADDR_WD  = 4;

// handshake Inputs
reg                     clk      ;
reg                     rstn     ;
reg                     valid_in ;
wire                    cmd_in   ;
wire   [ADDR_WD-1 : 0]  addr_in  ;
wire   [DATA_WD-1 : 0]  data_in  ;
reg                     ready_out;

// handshake Outputs
wire  ready_in        ;
wire  valid_out            ;
wire  [DATA_WD-1 : 0]  data_out   ;

reg   [DATA_WD : 0] cnt;
wire  fire_in;
wire  fire_out;  

assign fire_in = valid_in && ready_in;
assign fire_out = ready_out && valid_out;

assign cmd_in = ~cnt[DATA_WD];
assign addr_in = cnt[DATA_WD-1 : 0];
assign data_in = cnt[DATA_WD-1 : 0];



initial begin
    clk = 0;
    forever #(PERIOD/2)  clk=~clk;
end

initial begin
    rstn = 0;
    #(PERIOD*2) rstn  =  1;

    #5000 $finish;
end

initial begin
    $fsdaDumpfile("test.fsdb");
    $fsdbDumpvars;
end
/*
always @(posedge clk or negedge rstn) begin
    if(~rstn) begin
        valid_in <= 0;
        cnt <= 0;
        ready_out <= 1;
    end else begin
        if(!valid_in) begin
            valid_in <= $random;
        end 
        if (fire_in) begin
            cnt <= cnt + 1;
            valid_in <= $random;
        end 
        
        ready_out <= $random;
    end
end
 */

always @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        valid_in <= 1'b0;
        cnt <= 0;
        ready_out <= 0;
    end else begin
        valid_in <= 1;
        if (fire_in) begin
            cnt <= cnt + 1;
        end
        ready_out <= 1;
    end
end


handshake #(
    .DATA_WD ( DATA_WD ),
    .ADDR_WD ( ADDR_WD ))
 u_handshake (
    .clk                     ( clk        ),
    .rstn                    ( rstn       ),
    .valid_in                ( valid_in   ),
    .cmd_in                  ( cmd_in     ),
    .addr_in                 ( addr_in    ),
    .data_in                 ( data_in    ),
    .ready_out               ( ready_out  ),

    .ready_in                ( ready_in   ),
    .valid_out               ( valid_out  ),
    .data_out                ( data_out   )
);



endmodule