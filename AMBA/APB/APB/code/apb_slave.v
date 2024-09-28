module apb_slave #(
    parameter DATA_WIDTH = 8,
              ADDR_WIDTH = 8,
              CMD_WIDTH = DATA_WIDTH + ADDR_WIDTH + 1
)(
    input clk,rstn,
    input psel,penable,pwrite,
    input [ADDR_WIDTH-1:0] paddr,
    input [DATA_WIDTH-1:0] pwdata,
    output  [DATA_WIDTH-1:0] prdata,
    output reg pready
);

    localparam IDLE = 2'd0, W_ENABLE = 2'd1,R_ENABLE = 2'd2;
    reg [1:0] n_state, c_state;  

    always @(posedge clk or negedge rstn) begin
        if(!rstn)
            c_state = IDLE;
        else
            c_state = n_state;    
    end

    localparam DEPTH = 1 << ADDR_WIDTH;
    reg [DATA_WIDTH-1:0] mem [DEPTH-1:0];

    wire rd,wr;
    assign wr = psel && pwrite && penable;//写操作需要有等待传输
    //assign wr = psel && pwrite 不需要等待
    assign rd = psel && ~pwrite && penable;

    assign prdata = rd ? mem[paddr] : 'b0;//读不需要等待
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            pready = 1;
        end else if (wr) begin
            mem[paddr] <= pwdata;
            pready     <= 1'b1;
        end else if (n_state == R_ENABLE) begin
            pready <= 1'b1;
        end else if (n_state == IDLE) begin
            pready <= 1'b1;
        end else begin
            pready <= 1'b0;
        end
    end

    always @(*) begin
        case(c_state)
            IDLE :
                begin
                    if (psel && !penable) begin
                        if (pwrite) begin
                            n_state = W_ENABLE;
                        end else
                            n_state = R_ENABLE;
                    end else
                        n_state = IDLE;
                end
            W_ENABLE :
                begin
                    if(pready)
                        n_state = IDLE;
                    else
                        n_state = W_ENABLE;    
                end
            R_ENABLE :  
                begin
                    if(pready)
                        n_state = IDLE;
                    else
                        n_state = R_ENABLE;
                end
            default : n_state = IDLE;    
            
        endcase
    end

  /*  always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            prdata = 'b0;
            pready = 0;
        end else 
            case(n_state)
                IDLE :
                    begin
                        prdata = prdata;
                        pready = 0;
                    end
                W_ENABLE :
                    begin
                        if (wr) begin
                            mem[paddr] = pwdata;
                            pready = 1;
                        end
                    end
                R_ENABLE :
                    begin
                        if (rd) begin
                            prdata = mem[paddr];
                            pready = 1;
                        end
                    end
                default : 
                    begin
                        prdata = 'b0;
                        pready = 0;
                    end                  
            endcase
    end
    */

  /*  
    always @(*) begin
        if (!rstn) begin
            prdata = 'b0;
            pready = 0;
        end else 
            case(c_state)
                IDLE :
                    begin
                        prdata = prdata;
                        pready = 1;
                    end
                W_ENABLE :
                    begin
                        if (wr) begin
                            mem[paddr] = pwdata;
                            pready = 1;
                        end
                    end
                R_ENABLE :
                    begin
                        if (rd) begin
                            prdata = mem[paddr];
                            pready = 1;
                        end
                    end
                default : 
                    begin
                        prdata = 'b0;
                        pready = 0;
                    end                  
            endcase
    end


*/

endmodule //apb_slave