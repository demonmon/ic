module dma_buff #(
    parameter DATA_WD      = 32,
    parameter BE_WD        = DATA_WD / 8
) (
    input                  clk_i,
    input                  rstn_i,

    input  [DATA_WD-1 : 0] wdata_i,
    input  [BE_WD-1 : 0]   wbe_i,
    input                  wvalid_i,
    output                 wready_o,

    input  [BE_WD-1 : 0]   rbe_i,
    input                  rready_i,
    output [DATA_WD-1 : 0] rdata_o,
    output                 rvalid_o
);


wire       none_empty;
wire       none_full;
wire       dst_data_pop;
wire [7:0] dst_data;

wire       fire_in;
assign fire_in = wvalid_i && wready_o;
//----------------------------------SRC--------------------------------//

reg [1:0] src_wr_cs,src_wr_ns;
localparam [1:0] SRC_IDLE = 2'b00;
localparam [1:0] SRC_RUN = 2'b01;
localparam [1:0] SRC_DONE = 2'b10;

//------keep signal
//先缓存下来
reg [DATA_WD-1:0] wdata_keep;
reg [BE_WD-1:0]   wbe_keep;
reg               wvalid_keep;


localparam COUNT_WD = $clog2(BE_WD);

reg  [COUNT_WD-1 : 0] src_wr_index;//src_be的起点位置
reg  [COUNT_WD-1 : 0] src_wr_index_nx;
reg  [COUNT_WD-1 : 0] src_wr_target;
reg  [COUNT_WD-1 : 0] src_wr_target_nx;

wire                  src_wr_fire;

//.........output intermediate signals..........
wire  [7:0]           src_data;
wire                  src_data_push;
reg                   wready;


//缓存
always @(posedge clk_i or negedge rstn_i) begin
    if(!rstn_i) begin
        wvalid_keep <= 'b0;
        wdata_keep  <= 'b0;
        wbe_keep   <= 'b0;
    end else if (src_wr_cs == SRC_DONE) begin
        wvalid_keep <= 1'b0
    end else if (fire_in) begin
        wvalid_keep <= wvalid_i;
        wdata_keep  <= wdata_i;
        wbe_keep   <= wbe_i;
    end 
end

always @(posedge clk_i or negedge rstn_i) begin
    if (!rstn_i) begin
        src_wr_cs <= SRC_IDLE;
    end else begin
        src_wr_cs <= src_wr_ns;
    end
end


always @(*) begin
    src_wr_ns = SRC_IDLE;
    case (src_wr_cs)
        SRC_IDLE : 
                begin
                  if (wvalid_keep && none_full) begin
                    src_wr_ns = SRC_RUN; 
                  end else begin
                    src_wr_ns = SRC_IDLE;
                  end
                end 
        SRC_RUN : 
                begin
                  if (src_wr_fire) begin
                    src_wr_ns = SRC_DONE;
                  end else begin
                    src_wr_ns = SRC_RUN;
                  end
                end
        SRC_DONE : 
                begin
                  src_wr_ns = SRC_IDLE;
                end        
        default: src_wr_ns = SRC_IDLE;
    endcase
end


always @(posedge clk_i or negedge rstn_i) begin
    if (!rstn_i) begin
        src_wr_index  <= 'b0;
        src_wr_target <= 'b0;
    end else begin
        src_wr_index  <= src_wr_index_nx;
        src_wr_target <= src_wr_target_nx;
    end
end

reg [1:0] k;
reg [1:0] src_be_half;
reg [COUNT_WD-1:0] src_wr_lenth;//src_be的终点1
integer i;

always @(*) begin
    src_wr_index_nx = src_wr_index;
    src_wr_target_nx = 'b0;

    if (src_wr_cs == SRC_IDLE && none_full) begin
        if (wbe_keep[0]) begin
           src_wr_index = 0; 
        end else if (wbe_keep[1]) begin
            src_wr_index = 1;
        end else if (wbe_keep[2]) begin
            src_wr_index = 2;
        end else if (wbe_keep[3]) begin
            src_wr_index = 3;
        end

        for ( i=0; i<4; i = i + 1) begin
            if (wbe_keep[i]) begin
                src_wr_target_nx = src_wr_target_nx + 1;
            end
        end

        src_wr_lenth = src_wr_index_nx + src_wr_target_nx - 1;

    end
    if (src_wr_cs == SRC_RUN) begin
        src_wr_index_nx = src_wr_index_nx + 1;
    end
end

assign src_wr_fire = (src_wr_index == src_wr_lenth);

//-------------------------------src output---------------------
assign src_data = wdata_keep >> (src_wr_index * 8);

always @(posedge clk_i or negedge rstn_i) begin
    if(!rstn_i) begin
        wready <= 1'b1; //should be 1
    end else if (fire_in) begin
        wready <= 1'b0;  
    end else if (src_wr_cs == SRC_DONE) begin
        wready <= 1'b1;
    end       
end

assign wready_o = wready;
assign src_data_push = (src_wr_cs == SRC_RUN) && none_full;



//------------------------------buff_fifo-------------
syn_fifo # (.DATA_WD(8),
            .DEPTH(64)
) buff_fifo (.clk(clk_i),
             .rstn(rstn_i),

             .data_in(src_data),
             .valid_in(src_data_push),
             .ready_in(none_full),

             .data_out(dst_data),
             .valid_out(none_empty),
             .ready_out(dst_data_pop)
);


//------------------DST module------------------------

reg [1:0] dst_rd_cs;
reg [1:0] dst_rd_ns;

localparam DST_IDLE = 2'b00;
localparam DST_RUN  = 2'b01;
localparam DST_DONE = 2'b10;

reg [BE_WD-1 : 0]    rbe_keep;
reg                  rready_keep;
reg [DATA_WD-1 : 0]  rdata_keep;

reg [COUNT_WD-1 : 0] dst_rd_index;
reg [COUNT_WD-1 : 0] dst_rd_index_nx;
reg [COUNT_WD-1 : 0] dst_rd_target;
reg [COUNT_WD-1 : 0] dst_rd_target_nx;

wire                 dst_rd_fire;

assign dst_data_pop = (dst_rd_cs == DST_RUN) && none_empty;
always @(posedge clk_i or negedge rstn_i) begin
    if (!rstn_i) begin
        dst_rd_cs <= DST_IDLE;
    end
    else begin
        dst_rd_cs <= dst_rd_ns;
    end
end

always @(*) begin
    dst_rd_ns = DST_IDLE;
    case (dst_rd_cs)
        DST_IDLE : 
                begin
                  if (rready_keep && none_empty) begin
                        dst_rd_ns = DST_RUN; 
                  end else begin
                        dst_rd_ns = DST_IDLE;
                  end
                end
        DST_RUN : 
                begin
                  if (dst_rd_fire) begin
                    dst_rd_ns = DST_DONE;
                  end else begin
                    dst_rd_ns = DST_RUN;
                  end
                end
        DST_DONE :
                begin
                  dst_rd_ns = DST_IDLE;
                end  
        default: dst_rd_ns = DST_IDLE;
    endcase


end


always @(posedge clk_i or negedge rstn_i) begin
    if (!rstn_i) begin
        rbe_keep <= 'b0;
        rready_keep <= 'b0;
    end else if (dst_rd_ns == DST_DONE) begin
        rready_keep <= 1'b0;
    end 
    else if (dst_rd_ns == DST_IDLE && rready_i) begin  //rready_i 可以不需要
        rbe_keep <= rbe_i;
        rready_keep <= rready_i;
    end
end


always @(posedge clk_i or negedge rstn_i) begin
    if (!rstn_i) begin
        dst_rd_index <= 'b0;
        dst_rd_target <= 'b0;
    end else begin
        dst_rd_index <= dst_rd_index_nx;
        dst_rd_target <= dst_rd_target_nx;
    end
end


integer j;
reg [COUNT_WD-1 : 0] dst_rd_lenth;//beb终点位置
always @(*) begin
    dst_rd_index_nx = dst_rd_index;
    dst_rd_target_nx = 'b0;
    if (dst_rd_cs == DST_IDLE && none_empty) begin
        if (rbe_keep[0]) begin
            dst_rd_index_nx = 0; 
        end else if (rbe_keep[1]) begin
            dst_rd_index_nx = 1;
        end else if (rbe_keep[2]) begin
            dst_rd_index_nx = 2;
        end else if (rbe_keep[3]) begin
            dst_rd_index_nx = 3;
        end

        for (j=0; j<4; j=j+1) begin
            if (rbe_keep[j] == 1) begin
                dst_rd_target_nx = dst_rd_target_nx + 1; 
            end
        end

        dst_rd_lenth = dst_rd_target_nx + dst_rd_index_nx - 1;

    end
    
    if (dst_rd_cs == DST_RUN && none_empty) begin
        dst_rd_index_nx = dst_rd_index_nx + 1;
    end


end


assign dst_rd_fire = (dst_rd_index == dst_rd_lenth);

//-------------------------------output-----------------------
always @(*) begin
    if (dst_rd_cs == DST_RUN && none_empty) begin
        rdata_keep[dst_rd_index*8 +: 8] = dst_data;
    end
end

assign rvalid_o = (dst_rd_cs == DST_DONE);
assign rdata_o = rdata_keep;




endmodule

