module hs_buf #(
    parameter DATA_WD = 32
) (
    input                       clk,
    input                       rstn,

    input                       valid_in,
    input  [DATA_WD-1 : 0]      data_in,
    output                      ready_in,

    output                      valid_out,
    output [DATA_WD-1 : 0]      data_out,
    input                       ready_out
);


reg                 valid_out_r;
reg  [DATA_WD-1:0]  data_out_r;
//reg ready_in_r;
wire                fire_in;
wire                fire_out;

assign data_out = data_out_r;
assign ready_in = ready_out | (!valid_out_r);
assign valid_out = valid_out_r;

assign fire_in = valid_in && ready_in;
assign fire_out = valid_out && ready_out;

always @(posedge clk or negedge rstn) begin
    if(!rstn) begin
        valid_out_r <= 1'b0;
    end else begin
        if (fire_out) begin
            valid_out_r <= 1'b0;
        end
        if (fire_in) begin
            valid_out_r <= 1'b1;
            data_out_r  <= data_in;
        end

        /*case ({fire_in,fire_out})
            2'b10 :
                begin
                    valid_out_r <= valid_in;
                    data_out_r  <= data_out;
                end
            2'b01 :
                begin
                    valid_out_r <= 1'b0; 
                end
            2'b11 : 
                begin
                    valid_out_r <= valid_in;
                    data_out_r  <= data_in;

                end
            default : valid_out_r <= 1'b0;
                   

            
        endcase*/
    end
end

endmodule //hs_buf