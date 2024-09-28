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
    output reg                  ready_in,

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

  //  wire wr_cmd, rd_cmd;
  //  assign wr_cmd = fire_in && cmd_in;
  //  assign rd_cmd = fire_in && ~cmd_in;

    localparam IDLE = 2'd0, WRITE = 2'd1, READ = 2'd2;
    reg [1:0] c_state, n_state;

    always @(posedge clk or negedge rstn) begin
        if(!rstn)
            c_state <= IDLE;
        else
            c_state <= n_state;    
    end

  always @(*) begin
    case(c_state)
        IDLE :
            begin
                if (fire_in) begin
                    if(cmd_in)
                        n_state = WRITE;
                    else    
                        n_state = READ;
                end else
                    n_state = IDLE;
            end
        WRITE :
            begin
                if (fire_in) begin
                    if(cmd_in)
                        n_state = WRITE;
                    else    
                        n_state = READ;
                end else
                    n_state = IDLE;                
            end
        READ :
            begin
                if (fire_out) begin
                    if(cmd_in && fire_in) begin
                        n_state = WRITE;
                    end else if (~cmd_in && fire_in) begin
                        n_state = READ;
                    end else
                        n_state = IDLE;        
                end else
                    n_state = READ;
            end
        default : n_state = IDLE;
            
    endcase
  end

  //output: ready_in , valid_out,data_out
  /*always @(posedge clk or negedge rstn) begin
    if(~rstn) begin
        ready_in <= 1;
        valid_out <= 0;
    end else begin
        case (n_state)
            IDLE :
                begin
                    ready_in <= 1;
                    valid_out <= 0;
                end
            WRITE :
                begin
                    ready_in <= 1;
                    valid_out <= 0;
                end
            READ :
                begin
                    ready_in <= 0; //连续读的话，fire不能有效？先跳转到IDLE ,就不能在读状态接受命令
                    valid_out <= 1;
                end
            default : 
                begin
                    ready_in <= 1;
                    valid_out <= 0;
                end   
        endcase
    end
  end */
//改进  
  always @(*) begin
        case (c_state)
            IDLE :
                begin
                    ready_in <= 1;
                    valid_out <= 0;
                end
            WRITE :
                begin
                    ready_in <= 1;
                    valid_out <= 0;
                end
            READ :
                begin
                    ready_in <= ready_out; 
                    valid_out <= 1;
                end
            default : 
                begin
                    ready_in <= 1;
                    valid_out <= 0;
                end   
        endcase
    end


  always @(posedge clk or negedge rstn) begin
    if(~rstn)begin
        data_out <= 0;
    end else if (cmd_in && fire_in) begin
        mem[addr_in] <= data_in;
    end else if(~cmd_in && fire_in) begin
        data_out <= mem[addr_in];
    end

 end





              


endmodule  //handshake
