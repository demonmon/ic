module round_robin_arbiter_base_tb #(
    parameter REQ_NUM = 8
) ( );
reg                  clk;
reg                  rst_n;
reg  [REQ_NUM-1 : 0] reqs;
wire [REQ_NUM-1 : 0] grants;

initial begin
    clk = 1'b0;
    forever 
    #5 clk = ~clk;
end

// always #5 clk = ~clk;

initial begin
    rst_n = 1'b0;
    #12
    rst_n = 1'b1;
    #500
    $finish ();
end

initial begin
    $dumpfile ("test.vcd");
    $dumpvars;
end

//integer i;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        reqs <= 'b0;
    end
    else begin
        /*for (i=0; i<REQ_NUM; i=i+1) begin
           if (grans[i] == 1) begin
                reqs[i] = $random;
            end 
            
            if (reqs[i] == 0) begin
                reqs[i] = $random;    
            end

            if (reqs[i] == 1) begin
                reqs[i] = 1'b1;
            end
        end */
        reqs <= {REQ_NUM{1'b1}};
        // reqs <= $random; 
    end
end

round_robin_arbiter_base #(.REQ_NUM(REQ_NUM)
) u_round_robin_arbiter_base (.clk(clk),
                              .rst_n(rst_n),
                              .reqs(reqs),
                              .grants(grants)
);

endmodule