module matrix_trans #(
    parameter DATA_WD = 32,
    parameter ADDR_WD = 6
) (
    input                      clk,
    input                      rstn,
    input                      valid_in,
    input      [DATA_WD-1 : 0] data_in,
    input                      data_vld_in,
    output                     ready_in,
    output reg                 valid_out,
    output reg [DATA_WD-1 : 0] data_out,
    output reg                 data_out_vld,
    input                      ready_out

);
  wire        fire_in;
  wire        fire_out;


  //input receive
  reg         in_busy;  //1:busy
  reg         mem_we;
  reg  [31:0] mem_din;
  reg  [ 5:0] waddr;
  reg  [ 1:0] wptr;
  wire        in_pkg_end;


  //output send
  wire        out_pkg_end;
  reg         out_busy;
  wire        mem_rd;
  reg  [ 5:0] rcnt;
  wire [ 5:0] raddr;
  reg  [ 1:0] rptr;
  wire [31:0] dout_mux;
  reg         mem_rd_d;

  //mem r/w
  wire        buf_empty;
  wire        buf_full;
  
  wire        mem0_we;
  wire        mem0_cs;
  wire        mem0_rd;
  wire [ 5:0] mem0_addr;
  wire [31:0] mem0_dout;

  wire        mem1_we;
  wire        mem1_cs;
  wire        mem1_rd;
  wire [ 5:0] mem1_addr;
  wire [31:0] mem1_dout;



  assign fire_in = valid_in && ready_in;
  assign fire_out = valid_out && ready_out;

  //----input receive
  assign buf_empty = (wptr == rptr);
  assign buf_full = (wptr[1] != rptr[1]) && (wptr[0] == rptr[0]);

  assign ready_in = (!in_busy) && (!buf_full);
  assign in_pkg_end = mem_we && (waddr == 'd63);

  always @(posedge clk or negedge rstn) begin
    if (data_vld_in) begin
      mem_din <= data_in;
    end
  end


  always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      mem_we <= 1'b0;
    end else if (data_vld_in) begin
      mem_we <= 1'b1;
    end else begin
      mem_we <= 1'b0;
    end
  end

  always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      waddr <= 'b0;
    end else if (fire_in) begin
      waddr <= 'b0;
    end else if (mem_we) begin
      waddr <= waddr + 1;
    end
  end

  always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      in_busy <= 'd0;
    end else if (fire_in) begin
      in_busy <= 1'b1;
    end else if (in_pkg_end) begin
      in_busy <= 1'b0;
    end
  end

  always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      wptr <= 'd0;
    end else if (in_pkg_end) begin
      wptr <= wptr + 1;
    end
  end

  // output receive

  assign raddr = {rcnt[2:0], rcnt[5:3]};
  assign out_pkg_end = mem_rd && (rcnt == 'd63);
  assign mem_rd = out_busy;

  //valid_out ??

  always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      out_busy <= 1'd0;
    end else if (fire_out) begin
      out_busy <= 1'b1;
    end else if (out_pkg_end) begin
      out_busy <= 1'b0;
    end
  end

  always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      rcnt <= 'd0;
    end else if (fire_out) begin
      rcnt <= 'd0;
    end else if (mem_rd) begin
      rcnt <= rcnt + 1;
    end
  end

  always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      rptr <= 'd0;
    end else if (out_pkg_end) begin
      rptr <= rptr + 1;
    end
  end

  always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      valid_out <= 1'b0;
    end else if ((!out_busy) && (!valid_out) && (!buf_empty) && (!data_out_vld)) begin
      valid_out <= 1'b1;
    end else if (ready_out) begin
      valid_out <= 1'b0;
    end
  end

  always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      {data_out_vld, mem_rd_d} <= 'd0;
    end else begin
      {data_out_vld, mem_rd_d} <= {mem_rd_d, mem_rd};
    end
  end

  always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      data_out <= 'd0;
    end else begin 
      data_out <= dout_mux;
    end
  end


  //mem

  assign mem0_we = mem_we && (!wptr[0]);
  assign mem1_we = mem_we && (wptr[0]);
  assign mem0_rd = mem_rd && (!rptr[0]);
  assign mem1_rd = mem_rd && (rptr[0]);

  assign mem0_addr = (mem0_we) ? waddr : raddr;
  assign mem1_addr = (mem1_we) ? waddr : raddr;

  assign mem0_cs = mem0_we | mem0_rd;
  assign mem1_cs = mem1_we | mem1_rd;

  assign dout_mux = rptr[0] ? mem1_dout : mem0_dout;

  spram_generic #(
    .ADDR_WIDTH ( ADDR_WD ),
    .DATA_WIDTH ( DATA_WD ))
 u1_spram_generic (
    .clk                     ( clk       ),
    .en                      ( mem0_cs   ),
    .we                      ( mem0_we   ),
    .addr                    ( mem0_addr ),
    .din                     ( mem_din   ),

    .dout                    ( mem0_dout ) 
);

spram_generic #(
    .ADDR_WIDTH ( ADDR_WD ),
    .DATA_WIDTH ( DATA_WD ))
 u2_spram_generic (
    .clk                     ( clk       ),
    .en                      ( mem1_cs   ),
    .we                      ( mem1_we   ),
    .addr                    ( mem1_addr ),
    .din                     ( mem_din   ),

    .dout                    ( mem1_dout ) 
);





























endmodule  //matrix_trans
