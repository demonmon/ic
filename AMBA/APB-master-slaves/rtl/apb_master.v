module apb_master #(
    parameter  DATA_WIDTH = 32,
               ADDR_WIDTH = 12,
               CMD_WIDTH = DATA_WIDTH + ADDR_WIDTH + 1
) (
    input clk,rstn,
    //cmd input output
    input [CMD_WIDTH-1:0] cmd_in,
    input cmd_vld,
    input transfer,
    output reg cmd_rdy,
    output  read_vld,
    output  [DATA_WIDTH-1 : 0]read_data,

    //apb output input
    input [DATA_WIDTH-1:0] prdata,
    input pready,pslverr,
    
    //input pslverr
    output reg psel,penable,pwrite,
    output reg [ADDR_WIDTH-1:0] paddr,
    output reg [DATA_WIDTH-1:0] pwdata
);
    parameter IDLE = 3'b001,SETUP = 3'b010,ACCESS = 3'b100;
    reg [2:0] c_state,n_state;
    wire rw_flag;
    wire [DATA_WIDTH-1:0] data;
    wire [ADDR_WIDTH-1:0] addr;
    reg [CMD_WIDTH-1:0] cmd_buf;

    //reg ready_out;
    wire fire_in;
    wire fire_out;
    assign fire_in = cmd_vld && cmd_rdy;
    //assign fire_out = read_vld && ready_out;
    assign {rw_flag,addr,data} = cmd_in;

    always @(posedge clk or negedge rstn) begin
        if(!rstn)
            cmd_buf <= 'b0;
        //else if (cmd_vld && cmd_rdy  ) begin
        else if(fire_in) begin
            cmd_buf <= cmd_in;
        end    
          
    end 

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
                        
                    //paddr  = 'b0;
                    //pwdata = 'b0;
                    cmd_rdy = 1'b1;
                    if(fire_in && transfer)
                        n_state = SETUP;
                    else
                        n_state = IDLE ;    
                end
            SETUP :
                begin
                       /* if (pwrite) begin
                            pwdata = data;
                            paddr  = addr;
                        end else begin
                            paddr = addr;
                        end     */     
                        cmd_rdy = 1'b0;                                         
                        n_state = ACCESS;
                    
                end
            ACCESS :
                begin      
                        if (pready) begin
                            cmd_rdy = 1'b1;
                            if (transfer && fire_in) begin
                                n_state <= SETUP;
                            end else begin
                                n_state <= IDLE;
                            end
                            
                        end else  begin
                            n_state = ACCESS;
                        end                                      
                end
            default : n_state = IDLE ;          
        endcase
    end

//output
 //   assign psel = ((c_state != IDLE )? rw_flag : 1'b0)
    reg [DATA_WIDTH-1:0] read_data_buf;
    reg read_vld_w;
    assign read_data = ((c_state == ACCESS && transfer && pready && ~pwrite)? prdata:'d0);
    assign read_vld = penable && psel && pready && !pwrite ;   
    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            read_data_buf <= 'b0;
        end else begin    
            read_data_buf <= read_data;
            read_vld_w  <= read_vld;
        end
    end
    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            psel <= 0;
            penable <= 0;
            pwrite  <= 0;
            paddr   <= 'd0;
            pwdata  <= 'd0;
        end else begin
            case(n_state)
                IDLE :
                    begin
                        psel <= 1'b0;
                        penable <= 1'b0;
                        pwrite  <= 1'b0;
                        paddr   <= 'd0;
                    end
                SETUP :
                    begin
                        psel <= 1'b1;
                        penable <= 1'b0;
                        pwrite  <= cmd_in[CMD_WIDTH-1];
                        paddr   <= addr;

                        if(cmd_in[CMD_WIDTH-1])
                            pwdata <= data;
                    end
                ACCESS : 
                    begin
                        psel <= 1'b1;
                        penable <= 1'b1;
                        pwrite  <= pwrite;
                        paddr   <= paddr;
                        pwdata  <= pwdata;
                    end
                default : 
                    begin
                        psel <= 0;
                        penable <= 0;
                        pwrite  <= 0;
                        paddr   <= 'd0;
                        pwdata  <= 'd0; 
                    end                     
            endcase    
        end
    end

    


endmodule //apb_master
