module hs_fifo #(
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

    output                      valid_out,
    output     [DATA_WD-1 : 0]  data_out,
    input                       ready_out
);

    localparam DEPTH = 1 << ADDR_WD;
    reg [DATA_WD-1 : 0] mem [DEPTH-1 : 0];

    localparam CNT_WD = log2(DEPTH-1) + 1;
    reg [CNT_WD-1 : 0] rptr;
    reg [CNT_WD-1 : 0] wptr;
    
    wire fire_in;
    wire fire_out;

    assign fire_in = valid_in && ready_in;
    assign fire_out = ready_out && valid_out;//read need handshake

    assign ready_in = !((wptr[CNT_WD-1] ^ rptr[CNT_WD-1]) && (wptr[CNT_WD-2:0] == rptr[CNT_WD-2:0]));//no full
    assign valid_out = !(wptr == rptr);// no empty

    wire wr_cmd, rd_cmd;
    assign wr_cmd = fire_in && cmd_in; //write
    assign rd_cmd = fire_in && ~cmd_in; //read

    
    always @(posedge clk or negedge rstn) begin
        if(~rstn)begin
            wptr <= 'b0;          
        end else if (wr_cmd) begin
            wptr <= wptr + 1;
            mem[wptr[CNT_WD-2]] <= data_in;
        end 

    end

    always @(posedge clk or negedge rstn) begin
        if(~rstn)begin
            rptr <= 'b0;
        end else if (rd_cmd) begin          
            rptr = rptr + 1;
        end
    end 

    assign data_out = mem[rptr[CNT_WD-2:0]];
        




    function integer log2(input integer v);
    begin
        log2=0;
        while(v>>log2) 
        log2=log2+1;
    end
    endfunction

endmodule //hs_fifo