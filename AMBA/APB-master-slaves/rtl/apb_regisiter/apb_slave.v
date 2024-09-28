module apb_slave #(
    parameter ADDR_WIDTH = 12,
              DATA_WIDTH = 32
)(

    input                  pclk,
    input                  prst_n,

    input                   psel,
    input [ADDR_WIDTH-1:0]  paddr,
    input                   penable,
    input                   pwrite,
    input [DATA_WIDTH-1:0]  pwdata,
    input [3:0]             pstrb,
    input [3:0]             ecorevnum,

    output[DATA_WIDTH-1:0]  prdata,
    output                  pready ,
    output                  pslverr,            

    input [DATA_WIDTH-1:0]  rdata,
    input pready_r,
    input pslverr_r,
    output [ADDR_WIDTH-1:0] addr,
    output                  rd,
    output                  wr,
    output            [3:0] b_strobe,
    output [DATA_WIDTH-1:0] wdata

); 

    parameter SETUP = 2'd0, W_ACCESS = 2'd1,R_ACCESS = 2'd2,WAIT = 2'd3;
    reg [1:0] c_state,n_state;

    assign wdata = pwdata;
    assign prdata = rdata;
    assign pslverr = pslverr_r;    
    assign pready  = (c_state == WAIT) ? 0 : pready_r;
    //assign pslverr = 0;
    assign addr = paddr;
    assign rd = psel && (~pwrite) && (penable);
    assign wr = psel && pwrite && (penable);
    assign b_strobe = pstrb;


    always @(posedge pclk or negedge prst_n) begin
        if(~prst_n)
            c_state <= SETUP;
        else
            c_state <= n_state;
    end 
    always @(*) begin
        case (c_state)
            SETUP : 
                begin
                    if(psel && !penable) begin                    
                        n_state <= WAIT;
                        
                    end else
                        n_state <= SETUP;
                end
            WAIT :
                begin                
                    if(pwrite)                                                                                                                                                                                                                                                                                                                                               
                            n_state <= W_ACCESS;
                        else
                            n_state <= R_ACCESS;  
                end
            W_ACCESS :
                begin
                    if (pready) begin
                        n_state <= SETUP;
                    end
                end
            R_ACCESS :
                begin
                    if (pready) begin
                        n_state <= SETUP;
                    end
                end
            default : n_state <= SETUP;
                    
            
        endcase
    end
    
    //   assign pready = (c_state == WAIT) ? 1'b0 : 1'b1;
    /*always @(posedge pclk or negedge prst_n) begin
        if(~prst_n) begin
            pready <= 1;
        end else if (n_state == WAIT) begin
            pready <= 0;
        end else
            pready <=pready_r;

    end */
endmodule //apb_slave
