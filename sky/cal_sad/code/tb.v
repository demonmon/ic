`timescale 1ns/10ps

module tb ();

parameter cyc_time = 10.0;
parameter DWIDTH = 8 ;
parameter PIPE_STAGE = 5;

reg clk , rstn;
reg [DWIDTH-1:0]    din [15:0][15:0] ;
reg [DWIDTH-1:0]    refi [15:0][15:0];
reg                 cal_en;
wire [DWIDTH+7:0]   sad,sad_golden ;
wire                sad_vld;
wire                sad_vld_golden;

wire  [16*16*DWIDTH-1: 0] din_w,refi_w;

integer y,x;
integer test_cnt;
reg [7:0] rand_val;
reg [4:0] wait_cyc;

always #(cyc_time/2.0) clk = ~clk;
initial begin
    $fsdbDumpfile("tb.fsdb");
    $fsdbDumpvars("0,tb");
end

// ----1:generate test data

initial begin
    clk = 0;
    rstn = 0;
    cal_en = 0;
    test_cnt = 0;
    repeat(10) @(posedge clk);#1;
    rstn = 1;

    repeat(2) @(posedge clk);#1;
    // test0:din[y][x]=0,refi= 0
    cal_en = 1;
    for (y = 0 ; y<=15 ; y = y+1 ) begin
        for ( x = 0 ; x<=15 ; x=x+1 ) begin
            din[y][x] = 'b0;
            refi[y][x] = 'b0;
        end
    end
    @(posedge clk); #1;
    $display("Info:Do fixed test");
    
    //test-2 0  ff
    cal_en = 1;
    for (y = 0 ; y<=15 ; y = y+1 ) begin
        for ( x = 0 ; x<=15 ; x=x+1 ) begin
            din[y][x] = 0;
            refi[y][x] = 8'hff;  
        end
    end
    @(posedge clk); #1;

    //test-3 ff  0
    cal_en = 1;
    for (y = 0 ; y<=15 ; y = y+1 ) begin
        for ( x = 0 ; x<=15 ; x=x+1 ) begin
            din[y][x] = 8'hff;
            refi[y][x] = 0;
        end
    end
    @(posedge clk); #1;
    
    //--stop 2 cyc
    cal_en = 0;
    repeat(2) @(posedge clk);#1;

    //random test
    for ( test_cnt = 0 ; test_cnt<=(1<<15) ; test_cnt= test_cnt+1 ) begin
        rand_val = $random() %256  ;
        for ( y = 0; y<=15 ; y=y+1) begin
            for ( x = 0; x<=15 ; x=x+1 ) begin
                din[y][x] = $random() %256;
                refi[y][x] = $random() %256;

            end
        end

        if (rand_val <= 16) begin
            cal_en =0;
        end
        else
            cal_en = 1;
        @(posedge clk);#1;
    end
    cal_en = 0;

    $display("Info:Do random test_1");

    //--- random test2
    for ( test_cnt = 0 ; test_cnt<=(1<<15) ; test_cnt= test_cnt+1 ) begin
        rand_val = $random() %256  ;
        for ( y = 0; y<=15 ; y=y+1) begin
            for ( x = 0; x<=15 ; x=x+1 ) begin
                din[y][x] = $random() %256;
                refi[y][x] = $random() %256;

            end
        end

        if (rand_val >= 16) begin
            cal_en =0;
        end
        else
            cal_en = 1;
        @(posedge clk);#1;
    end
    cal_en = 0;

    repeat(20) @(posedge clk);#1;
    $display("info:sad_sal sim pass");
    $finish();
end

//---2 connect

generate
    genvar y0,x0;
    for (y0 = 0 ; y0<=15 ; y0=y0+1 ) begin 
        for ( x0 = 0 ; x0<=15 ; x0=x0+1 ) begin     
           assign din_w[(16*DWIDTH*y0+DWIDTH*x0) +: DWIDTH] = din[y0][x0] ;
           assign refi_w[(16*DWIDTH*y0+DWIDTH*x0) +: DWIDTH] = refi[y0][x0] ;
       
        end
    end

endgenerate


sad_model #(.DWIDTH(8), .PIPE_STAGE(5)) u_sad_model(
    .din (din_w),
    .refi(refi_w),
    .cal_en(cal_en),

    .sad(sad),
    .sad_vld(sad_vld_golden),
    
    .clk(clk),
    .rstn(rstn)

);

sad_cal  #(.DWIDTH(8)) u_sad_cal(
    .din (din_w),
    .refi(refi_w),
    .cal_en(cal_en),

    .sad(sad),
    .sad_vld(sad_vld),

    .clk(clk),
    .rstn(rstn)
);
// ---check

always @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        
    end
    else if(sad_vld_golden) begin
        if ((sad_vld_golden != sad_vld) || (sad_golden != sad)) begin
            #1;
            $display("info:sad_cal sim fail");
            $finish();
        end
    end
end







endmodule //tb