module ahb_sram (
    input                   clk,
    input                   rstn,
    input                   hsel,
    input  [mem_abit+2-1:0] haddr,
    input  [2:0]            hburst,
    input  [1:0]            htrans,
    input  [2:0]            hsize,
    input  [3:0]            hprot,
    input                   hwrite,
    input  [mem_dw-1:0]     hwdata,
    input                   hready,
    output                  hreadyout,
    output reg [31:0]       hrdata,
    output [1:0]            hresp 
);

parameter mem_depth = 1024;
parameter mem_abit = 10;
parameter mem_dw = 32;


parameter [1:0] T_IDLE = 2'd0, T_BUSY = 2'd1,T_NONS = 2'd2, T_SEQ = 2'd3;
parameter [1:0] R_OK = 2'd0;

wire bus_trans;
wire bus_idle;
wire bus_busy;

reg bus_wr_dph;
reg hready_idle;
reg hready_read;
wire hready_rd_w;
wire trans_fir;

reg [2:0] addr_step;
reg [2:0] addr_wrap_bloc;

reg  [mem_abit+2-1:0] addr_wrap;
wire [mem_abit+2-1:0] nxt_addr;
reg  [mem_abit+2-1:0] reg_addr;

wire bus_addr_inc;
wire bus_addr_inc_w;
reg  wrap_flag;

reg  mem_wr;
wire mem_rd;

assign bus_idle = hsel & hready & (htrans == T_IDLE);
assign bus_busy = hsel & hready & (htrans == T_BUSY);
assign bus_trans = hsel && hready && htrans[1];
assign trans_fir = hsel & hready & (htrans == T_NONS);

assign nxt_addr = reg_addr + addr_step;


assign bus_addr_inc_w = bus_trans & hwrite;
assign bus_addr_inc = bus_addr_inc_w | mem_rd;

assign hresp = R_OK;
assign hreadyout = (bus_wr_dph ? 1'b1 : hready_rd_w) | hready_idle;//

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        hready_idle <= 1'b1;
    end else if (hsel) begin
        hready_idle <= (bus_idle | bus_busy);
    end
end

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        bus_wr_dph <= 1'b0;
    end else begin
        bus_wr_dph <= (bus_trans & hwrite);
    end
end

always @(*) begin
    case (hsize)
        2'd0: addr_step = 'd1;
        2'd1: addr_step = 'd2;
        2'd2: addr_step = 'd4;
        2'd3: addr_step = 'd4;
    endcase
end

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        addr_wrap_bloc <= 3'b0;
        addr_wrap <= 'b0;
    end else if (trans_fir) begin
        case (hsize)
            'd0:
                begin
                    if (!hburst[2]) begin
                        addr_wrap_bloc <= 'd2;
                        addr_wrap <= {haddr[mem_abit+2-1:2],2'b0};
                    end else if (!hburst[1]) begin
                        addr_wrap_bloc <= 'd3;
                        addr_wrap <= {haddr[mem_abit+2-1:3],3'b0};
                    end else begin
                        addr_wrap_bloc <= 'd4;
                        addr_wrap <= {haddr[mem_abit+2-1:4],4'b0};
                    end
                end
            'd1: 
                begin
                    if (!hburst[2]) begin
                        addr_wrap_bloc <= 'd3;
                        addr_wrap <= {haddr[mem_abit+2-1:3],3'b0};
                    end else if (!hburst[1]) begin
                        addr_wrap_bloc <= 'd4;
                        addr_wrap <= {haddr[mem_abit+2-1:4],4'b0};
                    end else begin
                        addr_wrap_bloc <= 'd5;
                        addr_wrap <= {haddr[mem_abit+2-1:5],5'b0};
                    end
                end
            default:
                begin
                    if (!hburst[2]) begin
                        addr_wrap_bloc <= 'd4;//4beat
                        addr_wrap <= {haddr[mem_abit+2-1:4],4'b0};
                    end else if (!hburst[1]) begin
                        addr_wrap_bloc <= 'd5;//8beat
                        addr_wrap <= {haddr[mem_abit+2-1:5],5'b0};
                    end else begin
                        addr_wrap_bloc <= 'd6;//16beat
                        addr_wrap <= {haddr[mem_abit+2-1:6],6'b0};
                    end
                end
        endcase
    end
end

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        wrap_flag <= 1'b0;
    end else if (trans_fir) begin
        wrap_flag <= !hburst[0];
    end
end

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        reg_addr <= 'b0;
    end else if (trans_fir) begin
        reg_addr <= haddr;
    end else if (bus_addr_inc) begin
        if (wrap_flag) begin
            if (nxt_addr[addr_wrap_bloc] != addr_wrap[addr_wrap_bloc]) begin
                reg_addr <= addr_wrap;
            end else begin
                reg_addr <= nxt_addr;
            end
        end else begin
            reg_addr <= nxt_addr;
        end
    end
end


//----- write ------
wire [mem_dw-1:0] mem_wdata;
reg  [3:0] mem_wbe;
assign mem_wdata = hwdata;

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        mem_wr <= 1'b0;
    end else begin
        mem_wr <= bus_addr_inc_w;
    end
end


always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        mem_wbe <= 4'b0;
    end else if (bus_trans & hwrite) begin
        if (trans_fir) begin
            case (hsize)
                'd0:
                    begin
                        case (haddr[1:0])
                        'd0: mem_wbe <= 4'b0001;
                        'd1: mem_wbe <= 4'b0010;
                        'd2: mem_wbe <= 4'b0100;
                        'd3: mem_wbe <= 4'b1000;
                    endcase
                    end
                'd1:
                    begin
                        if (haddr[1]) begin
                            mem_wbe <= 4'b1100;
                        end else begin
                            mem_wbe <= 4'b0011;
                        end
                    end
                'd2: mem_wbe <= 4'b1111;
                'd3: mem_wbe <= 4'b1111;
            endcase
        end else begin
            case (hsize)
                'd0: mem_wbe <= {mem_wbe[2:0], mem_wbe[3]};
                'd1: mem_wbe <= {mem_wbe[1:0], mem_wbe[3:2]};
                default: mem_wbe <= mem_wbe;
            endcase
        end
    end
end


// read

reg mem_rd_time;
reg mem_rd_d;
wire [mem_dw-1:0] mem_dout;
assign mem_rd = mem_rd_time & (!bus_busy);//当前立马不读
assign hready_rd_w = hready_read & mem_rd_time;


always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        mem_rd_time <= 1'b0;
    end else if (trans_fir) begin
        if (!hwrite) begin
            mem_rd_time <= 1'b1;
        end else begin
            mem_rd_time <= 1'b0;
        end
    end else if (bus_idle) begin
        mem_rd_time <= 1'b0;
    end
end

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        mem_rd_d <= 1'b0;
    end else if (bus_idle | trans_fir) begin
        mem_rd_d <= 1'b0;
    end else begin
        mem_rd_d <= mem_rd;
    end
end

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        hready_read <= 1'b0;
    end else if (trans_fir | bus_idle) begin
        hready_read <= 1'b0;
    end else if (mem_rd_d) begin
        hready_read <= 1'b1;
    end
end

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        hrdata <= 'd0;
    end else if (mem_rd_d) begin
        hrdata <= mem_dout;
    end
end

//mem

wire mem_cs;
assign mem_cs = mem_wr | mem_rd;

spram_generic_wbe4 #(
    .ADDR_BITS   ( mem_abit   ),
    .ADDR_AMOUNT ( mem_depth ),
    .DATA_BITS   ( mem_dw   ))
 u_mem (
    .clk                     ( clk                       ),
    .en                      ( mem_cs                    ),
    .we                      ( mem_wr                    ),
    .wbe                     ( mem_wbe                   ),
    .addr                    ( reg_addr[2 +: mem_abit]   ),
    .din                     ( mem_wdata                 ),

    .dout                    ( mem_dout                  )
);

endmodule //ahb_sram