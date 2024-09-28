`timescale  1ns / 1ps

module tb_pingpong;

// pingpong Parameters
parameter PERIOD   = 10;
parameter BUF_NUM  = 4;
parameter DATA_WD  = 8;

// pingpong Inputs
reg   clk                      ;
reg   rstn                     ;
reg   valid_in                 ;
reg   [DATA_WD-1 : 0]  data_in ;
reg   ready_out                ;

// pingpong Outputs
wire  ready_in                  ;
wire  valid_out                 ;
wire  [DATA_WD-1 : 0]  data_out ;


wire fire_in;
assign fire_in = valid_in && ready_in;


initial
begin
    clk = 0;
    forever #(PERIOD/2)  clk=~clk;
end

initial
begin
    rstn = 0;
    #(PERIOD*2) rstn  =  1;

    #1000 $finish;
end

always @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        valid_in <= 1'b0;
        ready_out <= 1'b0;
    end else begin
        if (fire_in) begin
            valid_in <= $random;
        end
        if (!valid_in) begin
            valid_in <= $random;
        end
        
        ready_out <= 1;
    end
        
end




always @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        data_in <= 0;
    end if(fire_in)
        data_in <= data_in + 1;
end


pingpong #(
    .BUF_NUM ( BUF_NUM ),
    .DATA_WD ( DATA_WD ))
 u_pingpong (
    .clk                     ( clk       ),
    .rstn                    ( rstn      ),
    .valid_in                ( valid_in  ),
    .data_in                 ( data_in   ),
    .ready_out               ( ready_out ),

    .ready_in                ( ready_in  ),
    .valid_out               ( valid_out ),
    .data_out                ( data_out  )
);



endmodule