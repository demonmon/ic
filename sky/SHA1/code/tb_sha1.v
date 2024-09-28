`timescale  1ns / 1ps

module tb_sha1;      

// sha1 Parameters
parameter PERIOD = 10          ;
parameter MAX_TEST = 4;

// sha1 Inputs
reg   clk        ;
reg   rstn       ;
reg   din_vld    ;
reg   [31:0]  din;
reg   use_prec_cv;

// sha1 Outputs
wire  busy         ;
wire  [159:0]  dout;
wire  dout_vld     ;
integer i,tcnt;
reg [7:0]   b0, b1, b2, b3;
reg [159:0] expected_result, cv, cv_next;

integer fp_din, fp_dout;
reg start;
//integer j;

initial
begin
    clk = 0;
    forever #(PERIOD/2)  clk=~clk;
end
initial
begin
    rstn = 0;
    repeat(4) @(posedge clk);
    #1 rstn  =  1;
end
initial begin
    $dumpfile("test.vcd");
    $dumpvars;
    for (i=0; i < 16; i = i + 1) begin
        $dumpvars(0, u_sha1.w_reg[i]);
    end
end

sha1 u_sha1 (
    .clk                     ( clk                  ),
    .rstn                    ( rstn                 ),
    .din_vld                 ( din_vld              ),
    .din                     ( din          [31:0]  ),
    .use_prec_cv             ( use_prec_cv          ),

    .busy                    ( busy                 ),
    .dout                    ( dout         [159:0] ),
    .dout_vld                ( dout_vld             )
);
initial begin
    cv = 160'h67452301_EFCDAB89_98BADCFE_10325476_C3D2E1F0;
    use_prec_cv = 1'b0;
    start = 0; din_vld = 0;

    fp_din = $fopen("../cmodel/sha_1/sha_in.bin","rb");
    fp_dout = $fopen("../cmodel/sha_1/sha_out.bin","rb");
    
    if (fp_din == 0) begin
        $display("Sim ERROR : FILE ../cmodel/sha_1/sha_in.bin don't exist which is needed by %m .");
        $finish();
    end

    if (fp_dout == 0) begin
        $display("Sim ERROR : FILE ../cmodel/sha_1/sha_out.bin don't exist which is needed by %m .");    
        $finish();
    end

    @(posedge clk);
    @(negedge clk);
    repeat(6) @(posedge clk);

    for ( tcnt=0; tcnt<MAX_TEST; tcnt=tcnt+1) begin
        
        for (i=0; i<16; i=i+1) begin
            b0 = $fgetc(fp_din);
            b1 = $fgetc(fp_din);
            b2 = $fgetc(fp_din);
            b3 = $fgetc(fp_din);
            #1;
            din = {b0,b1,b2,b3};
            din_vld = 1;
            @(posedge clk);
        end
        #1;
        din_vld = 0;
        start = 1;
        @(posedge clk);#1;
        start = 0;

        @(posedge dout_vld);
        //@(posedge clk);

        for (i=0; i<5; i=i+1) begin
            b0 = $fgetc(fp_dout);
            b1 = $fgetc(fp_dout);
            b2 = $fgetc(fp_dout);
            b3 = $fgetc(fp_dout);
            expected_result = (expected_result<<32)|{b3,b2,b1,b0};
        end
        @(posedge clk);
        if (expected_result !== dout) begin
            #1;
            $display("SHA-1 fail at test : %d \n",tcnt);
            $stop();
        end    
    end

    
    $display("SHA-1 test pass!\n : %d \n",tcnt);
    $finish();

end



endmodule