module tb_matrix_trans;

  // matrix_trans Parameters
  parameter PERIOD = 10;
  parameter DATA_WD = 32;
  parameter ADDR_WD = 6;
  parameter test_cnt = 10000;


  // matrix_trans Inputs
  reg                  clk;
  reg                  rstn;
  reg                  valid_in;
  reg  [DATA_WD-1 : 0] data_in;
  reg                  data_vld_in;
  reg                  ready_out;

  // matrix_trans Outputs
  wire                 ready_in;
  wire                 valid_out;
  wire [DATA_WD-1 : 0] data_out;
  wire                 data_out_vld;


  reg [31:0] ini_mem [(1<<16-1):0];
  reg [31:0] ini_cnt;
  reg [31:0] in_pkg_cnt,out_pkg_cnt;


  wire                 valid_in_buf;
  wire  [DATA_WD-1 : 0]data_in_buf;
  wire                 data_vld_in_buf;
  wire                 ready_out_buf;

  wire                 ready_in_buf;
  wire                 valid_out_buf;
  wire [DATA_WD-1 : 0] data_out_buf;
  wire                 data_out_vld_buf;

  assign #1 valid_in_buf = valid_in;
  assign #1 ready_in_buf = ready_in;
  assign #1 data_vld_in_buf = data_vld_in;
  assign #1 data_in_buf = data_in;

  assign #1 valid_out_buf = valid_out;
  assign #1 ready_out_buf = ready_out;
  assign #1 data_out_buf = data_out;
  assign #1 data_out_vld_buf = data_out_vld;

  initial begin
    clk = 0;
    forever #(PERIOD / 2) clk = ~clk;
  end

  initial begin
    rstn = 1;
    repeat(10) @(posedge clk); rstn = 0;
    repeat(10) @(posedge clk); rstn = 1;
  end

  //test gen
  //data send
  reg [15:0] ini_wait_max;

  initial begin
    valid_in = 0; data_vld_in = 0;
    for (ini_cnt=0; ini_cnt<(1<<16); ini_cnt=ini_cnt+1) begin
        ini_mem[ini_cnt] = ini_cnt;
    end

    @(posedge rstn);
    repeat(10) @(posedge clk);
    for (in_pkg_cnt=0; in_pkg_cnt<test_cnt; in_pkg_cnt=in_pkg_cnt+1) begin
        if(in_pkg_cnt<250)
            ini_wait_max = 'd5;
        else if (in_pkg_cnt<500) begin
            ini_wait_max = 'd100;
        end else if(in_pkg_cnt<750) begin
            ini_wait_max = 'd1000;
        end else
            ini_wait_max = {$random} % 20; 
            
        dsend((in_pkg_cnt*64),ini_wait_max);   
    end
    repeat(10) @(posedge clk);
    while (in_pkg_cnt != out_pkg_cnt) begin
        repeat(10) @(posedge clk);
    end
    $display("OK,sim pass.\n");
    $stop();
  end

  //data recv

  reg [15:0] out_wait_max;
  initial begin
    ready_out = 0; 
    ini_wait_max = 'd1000;
    @(posedge rstn);
    repeat(10) @(posedge clk);
    out_pkg_cnt = 0;
    
    while (1) begin
        if(out_pkg_cnt<250)
            out_wait_max = 'd1000;
        else if (out_pkg_cnt<500) begin
            out_wait_max = 'd100;
        end else if(out_pkg_cnt<750) begin
            out_wait_max = 'd5;
        end else
            out_wait_max = {$random} % 20;


        drecv((out_pkg_cnt*64),out_wait_max);
        out_pkg_cnt = out_pkg_cnt + 1;    
    end

  end


  task dsend;
  input  [31:0] beg_addr;
  input  [15:0] max_ini_wait;
  reg    [15:0] cnt;
  reg    [15:0] ini_wait;
  begin
    //send valid
    ini_wait = {$random} % max_ini_wait;
    repeat(ini_wait) @(posedge clk);
    valid_in = 1'b1;
    @(posedge clk) 
    while(!ready_in_buf) begin
        @(posedge clk);
    end
    valid_in = 1'b0;

    //send data
    data_vld_in = 1'b1;
    for (cnt=0; cnt<64; cnt=cnt+1) begin
        data_in = ini_mem[beg_addr+cnt];
        @(posedge clk);
    end
    data_vld_in = 1'b0;
  end  
    
  endtask

  task drecv;
  input  [31:0] beg_addr;
  input  [15:0] max_ini_wait;
  reg    [15:0] cnt;
  reg    [5:0]  vertial_addr;
  reg    [15:0] ini_wait;
  reg    [31:0] ref_data;
  begin
    //recv ready
    ini_wait = {$random} % max_ini_wait;
    repeat(ini_wait) @(posedge clk);
    ready_out = 1'b1;
    @(posedge clk) 
    while(!valid_out_buf) begin
        @(posedge clk);
    end
    ready_out = 1'b0;

    //recv data
    @(posedge clk);
    for (cnt=0; cnt<64; cnt=cnt+1) begin
        vertial_addr = {cnt[2:0],cnt[5:3]};
        ref_data = ini_mem[beg_addr+vertial_addr];
        @(posedge clk);
        while (!data_out_vld_buf) begin
            @(posedge clk);
        end

        if (ref_data != data_out_buf) begin
            $display("ERROR");
            @(posedge clk);
            $stop();
        end
    end
  end
  endtask



  matrix_trans #(
      .DATA_WD(DATA_WD),
      .ADDR_WD(ADDR_WD)
  ) u_matrix_trans (
      .clk          ( clk          ),
      .rstn         ( rstn         ),
      .valid_in     ( valid_in     ),
      .data_in      ( data_in      ),
      .data_vld_in  ( data_vld_in  ),
      .ready_out    ( ready_out    ),

      .ready_in     ( ready_in     ),
      .valid_out    ( valid_out    ),
      .data_out     ( data_out     ),
      .data_out_vld ( data_out_vld )
  );

  initial begin

    $finish;
  end

endmodule
