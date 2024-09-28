module mcp_tb ();
    parameter  DWIDTH = 8;
    reg clk_a;
    reg [DWIDTH-1:0] adatain;
    reg asend;
    reg rstn_a;
    wire aready;

    reg clk_b;
    reg rstn_b;
    reg bload;
    wire bvalid;
    wire  [DWIDTH-1:0] bdata;

    always #1 clk_a = ~clk_a;
    always #4 clk_b = ~clk_b;
    initial begin
        clk_a = 0;
        clk_b = 0;
        asend = 0;
        rstn_a = 0;
        rstn_b = 0;
        adatain = 0;
        bload  = 0;

        #1;rstn_a = 1;rstn_b = 1;
        @(posedge clk_a)#0.1;
        asend = 1;
        @(posedge clk_a)#0.1;
        asend = 0;
        adatain = 8'd1;
        //wait(b_en == 1); bload = 1;
        repeat(4) @(posedge clk_a);
        @(posedge clk_b);
        bload = 1;
        repeat(3) @(posedge clk_b);
        bload = 0;



        //wait(a_ack == 1);
        @(posedge clk_b);
        repeat(2) @(posedge clk_a)#0.1;
        asend   = 1;
        @(posedge clk_a)#0.1;
        adatain = 8'd2;
         asend = 0;
        //wait(b_en == 1); bload = 1;
        repeat(4) @(posedge clk_a);
        bload = 1;
        repeat(3) @(posedge clk_b);
        bload = 0;

        @(posedge clk_b);
        repeat(2) @(posedge clk_a);#0.1
        asend   = 1;
        @(posedge clk_a);#0.1
        adatain = 8'd3;
        asend = 0;
        //wait(b_en == 1); bload = 1;
        repeat(4) @(posedge clk_a);
        bload = 1;
        repeat(3) @(posedge clk_b);
        bload = 0;

        @(posedge clk_b);
        repeat(2) @(posedge clk_a);#0.1
        asend   = 1;
        @(posedge clk_a);#0.1
        adatain = 8'd4;
         asend = 0;
        //wait(b_en == 1); bload = 1;
        repeat(4) @(posedge clk_a);
        bload = 1;
        repeat(3) @(posedge clk_b);
        bload = 0;

        @(posedge clk_b);
        repeat(2) @(posedge clk_a);#0.1
        asend   = 1;
        @(posedge clk_a);#0.1
        adatain = 8'd5;
         asend = 0;
        //wait(b_en == 1); bload = 1;
        repeat(4) @(posedge clk_a);
        bload = 1;
        repeat(3) @(posedge clk_b);
        bload = 0;

        @(posedge clk_b);
        repeat(2) @(posedge clk_a);
        asend   = 1;
        @(posedge clk_a);#0.1
        adatain = 8'd6;
         asend = 0;
        //wait(b_en == 1); bload = 1;
        repeat(4) @(posedge clk_a);
        bload = 1;
        repeat(3) @(posedge clk_b);
        bload = 0;

        @(posedge clk_b);
        repeat(2) @(posedge clk_a);#0.1
        asend   = 1;
        @(posedge clk_a);#0.1
        //adatain = 8'd7;
         asend = 0;
        //wait(b_en == 1); bload = 1;
        repeat(4) @(posedge clk_a);
        bload = 1;
        repeat(3) @(posedge clk_b);
        bload = 0;



        #200
        $finish();

        
    end

    initial begin
		$dumpfile("test.vcd");
        $dumpvars;
	end

    mcp u_mcp (
        .clk_a   (clk_a),
        .adatain (adatain),
        .asend   (asend),
        .rstn_a  (rstn_a),
        .aready  (aready),

        .clk_b   (clk_b),
        .rstn_b  (rstn_b),
        .bload   (bload),
        .bvalid  (bvalid),
        .bdata   (bdata)
    );


endmodule //mcp_tb