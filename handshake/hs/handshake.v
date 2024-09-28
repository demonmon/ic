module handshake #(
    parameter DATA_WD = 4,
    parameter ADDR_WD = 4
) (
    input                       clk,
    input                       rstn,

    input                       valid_in,
    input                       cmd_in, //1: write 0: read
    input  [ADDR_WD-1 : 0]      addr_in,
    input  [DATA_WD-1 : 0]      data_in,
    output                      ready_in,

    output reg                  valid_out,
    output reg [DATA_WD-1 : 0]  data_out,
    input                       ready_out

);
    localparam DEPTH = 1 << ADDR_WD;
    reg [DATA_WD-1 : 0] mem [DEPTH-1 : 0];

    wire fire_in;
    wire fire_out;

    assign fire_in = valid_in && ready_in;
    assign fire_out = ready_out && valid_out;//read need handshake

    assign ready_in = !valid_out || ready_out; 
    //valid_out = 0时属于空闲 valid_out=1时候在读。
    //读的时候也可以接受命令必须在读握手成功时候(ready_out == 1)可以接收  
    //assign valid_out = ;

    wire wr_cmd, rd_cmd;
    assign wr_cmd = fire_in && cmd_in;
    assign rd_cmd = fire_in && ~cmd_in;

    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            valid_out <= 0;
        end else begin
            if(fire_out) begin
                valid_out <= 0;
            end
            if (rd_cmd) begin
                valid_out <= 1;
            end
        end
    end

    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            data_out <= 'b0;
        end else if (rd_cmd) begin
            data_out <= mem[addr_in];
        end else if(wr_cmd) begin
            mem[addr_in] <= data_in;
        end
    end
    

    


endmodule  //handshake
