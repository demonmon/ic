module ahb_sram(
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
    output [31:0]           hrdata,
    output [1:0]            hresp 
);
    
parameter mem_depth = 1024;
parameter mem_abit = 10;
parameter mem_dw = 32;

reg [3:0] mem_wbe;
wire mem_cs;
wire mem_wr;
wire mem_rd;
wire [9:0]  mem_addr;
wire [31:0] mem_wdata;
wire [mem_dw-1:0] mem_rdata;

reg  bus_wr_phase;
wire bus_wr_phase_next;
reg [9:0] haddr_r;
reg hwrite_r;
wire bus_trans = hsel && hready && htrans[1];
wire bus_write = bus_trans && hwrite;
wire bus_read = (hready ? bus_trans : bus_trans_r) && (~hwrite);
assign hreadyout = !write2read_r;
assign hresp = 'd0;

//hsize
always @(posedge clk) begin
    if (!rstn) begin
        mem_wbe <= 4'b0000;
    end else if (hsel && hready) begin
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
    end
end




// write

assign mem_wdata = hwdata;
assign bus_wr_phase_next = (!hreadyout && bus_wr_phase) | bus_write;
reg bus_trans_r;
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        haddr_r <= 'b0;
        bus_trans_r <= 0;;
    end else if (bus_trans) begin
        haddr_r <= haddr[2+:mem_abit];
        bus_trans_r <= bus_trans;
    end
end

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        hwrite_r <= 1'b0;
    end else if (bus_trans) begin
        hwrite_r <=  hwrite;
    end
end
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        bus_wr_phase <= 1'b0;
    end else begin
        bus_wr_phase <= bus_wr_phase_next;//1：写命令的传输阶段
    end
end

wire write2read = bus_wr_phase && bus_read;
//写之后立马读产生读写矛盾
reg write2read_r;

assign hrdata = mem_rdata;

assign mem_rd = bus_read && (!bus_wr_phase);//读
assign mem_wr = bus_wr_phase && hready;

assign mem_cs = mem_rd | mem_wr;
assign mem_addr = (mem_wr | write2read_r) ? haddr_r : haddr[2 +: mem_abit];

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        write2read_r <= 1'b0;
    end else begin
        write2read_r <= write2read;
    end
end

spram_generic_wbe4 #(.ADDR_BITS(mem_abit),.ADDR_AMOUNT(mem_depth),.DATA_BITS(mem_dw))
    u_mem(
        .clk   (clk        ),
        .en    (mem_cs     ),
        .we    (mem_wr     ),
        .wbe   (mem_wbe    ),

        .addr  (mem_addr   ),
        .din   (mem_wdata  ),
        .dout  (mem_rdata  )
    );



endmodule