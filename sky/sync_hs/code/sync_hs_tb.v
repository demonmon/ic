`timescale 1ns/10ps

module sync_hs_tb ();

parameter DWIDTH = 8;
parameter SYNC_STAGE = 2;

integer cyc0_time = 10;
integer cyc1_time = 100;

reg clk_i,rstn_i;
reg clk_o,rstn_o;

reg in_vld;
reg [DWIDTH-1:0] din;
reg out_ack;

wire in_ack,out_vld;
wire in_ack_buf,out_vld_buf;

wire [DWIDTH-1:0] dout;
wire [DWIDTH-1:0] dout_buf;

assign #0.1 dout_buf = dout;
assign #0.1 out_vld_buf = out_vld;
assign #0.1 in_ack_buf = in_ack;

integer x,y;
integer test_cnt;

reg [7:0] rand_val;
reg [4:0] wait_cyc;

always #(cyc0_time/2.0) clk_i = ~clk_i;
always #(cyc1_time/2.0) clk_o = ~clk_o;

initial begin
    
    clk_i  = 0;
    rstn_i = 0;
    clk_o  = 0;
    rstn_o = 0;
    in_vld = 0;
    din    = 0;

    repeat(3) @(posedge clk_i); #1;
    rstn_i = 1;
    repeat(3) @(posedge clk_o); #1;
    rstn_o = 1;

    for ( test_cnt=0 ; test_cnt <=5 ; test_cnt = test_cnt +1 ) begin
        @(posedge clk_o);
        case(test_cnt)
            'd0: cyc1_time = 100;
            'd1: cyc1_time = 30;
            'd2: cyc1_time = 11;
            'd3: cyc1_time = 9;
            'd4: cyc1_time = 3;
            'd5: cyc1_time = 1;           
        endcase
    

        @(posedge clk_i) ;
        #0.1
        for ( x=0 ; x<100 ; x=x+1 ) begin
            in_vld =1;
            rand_val = $random() %256;
            if((rand_val >= 16) && (rand_val <= 250)) begin
                rand_val = 0;
            end 
            @(posedge clk_i) ;
            while(!in_ack_buf) begin
                @(posedge clk_i);
            end
            #0.1 in_vld = 0;

            //wait
            if (rand_val != 0) begin
                repeat(rand_val) @(posedge clk_i);
                #0.1;
            end
            din = din+1;
        
        end

        repeat(10) @(posedge clk_i);
        repeat(10) @(posedge clk_o);
    end
    $display("OK,sim pass");
    $finish();

end

wire out_cap;
reg [7:0] rand_vall;
reg [DWIDTH-1:0] out_cnt;

initial begin
    out_ack = 0;
    rand_vall = 0;
    out_cnt =0;
    @(posedge clk_o);
    @(posedge rstn_o);
    #0.1
    while(1) begin
        rand_vall = {$random} % 8;
        if((rand_vall >= 16) && (rand_vall <= 250))
            rand_vall = 0;
        if (rand_vall != 0) begin
            repeat(rand_vall) @(posedge clk_o);
            #0.1;
        end    
        out_ack = 1;
        @(posedge clk_o);
        while (!out_vld_buf) begin
            @(posedge clk_o);
        end
        #0.1;out_ack = 0;
    end   

end 

always @(posedge clk_o) begin
    if (rstn_o) begin
        if(out_vld_buf && out_ack) begin
            out_cnt <= #0.1 out_cnt + 1;
            if (out_cnt !== dout_buf) begin
                #1;
                $display("ERROR:SYNC data error!");
                $finish();
            end
        end
    end
end


sync_hs u_sync_hs(
    .clk_i(clk_i),
    .rstn_i(rstn_i),
    .in_vld(in_vld),
    .din(din),
    .in_ack(in_ack),

    .clk_o(clk_o),
    .rstn_o(rstn_o),
    .out_vld(out_vld),
    .dout(dout),
    .out_ack(out_ack)

);


endmodule //sync_hs_tb