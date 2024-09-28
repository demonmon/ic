module ip_pulse_sync_tb (

    );
    
    
    reg                                                     i_src_clk                               ;   //
    reg                                                     i_src_rst_n                             ;   //
    reg                                                     i_src_pulse                             ;   //
    reg             [5:0]                                   i_src_cnt                               ;   //
    reg                                                     hrst_n                                  ;   //

    reg                                                     i_dst_clk                               ;   //
    reg                                                     i_dst_rst_n                             ;   //
    wire                                                    o_dst_pulse                             ;   //
    
initial begin
    i_src_clk                       =               0                                       ;   
    forever #1 i_src_clk = ~i_src_clk;
end

initial begin
    $dumpfile("test.vcd");
    $dumvpars;
end


initial begin
    hrst_n                          =               1'b0                                    ;   
    #10 hrst_n = 1;
end
    
always @(posedge i_src_clk or negedge hrst_n)
    if(!hrst_n) begin
        i_src_rst_n                     <=              1'b0                                    ;   
    end
    else  begin
        i_src_rst_n                     <=              1'b1                                    ;   
    end
    
    
always @(posedge i_src_clk or negedge hrst_n)
    if(!hrst_n) begin
        i_src_cnt                       <=              1'b0                                    ;   
    end
    else if((&i_src_cnt))  begin
        i_src_cnt                   <=            i_src_cnt                                            ;
    end 
    else if(!(&i_src_cnt))  begin
        i_src_cnt                   <=            i_src_cnt +  1'b1                                    ;
    end 
    
always @(posedge i_src_clk or negedge hrst_n)
    if(!hrst_n) begin
        i_src_pulse                     <=              1'b0                                    ;   
    end
    else  begin
        i_src_pulse                     <=              (i_src_cnt[2:0] ==3'b11)                            ;   
    end
    
    
    
    
initial begin
    i_dst_clk                       =               0                                       ;   
    forever #2 i_dst_clk = ~i_dst_clk;
end
    
    
always @(posedge i_dst_clk or negedge hrst_n)
    if(!hrst_n) begin
        i_dst_rst_n                     <=              1'b0                                    ;   
    end
    else  begin
        i_dst_rst_n                     <=              1'b1                                    ;   
    end
    

    ip_pulse_sync ip_pulse_sync (
        .i_src_clk                       (   i_src_clk                                                   ),   //
        .i_src_rst_n                     (   i_src_rst_n                                                 ),   //
        .i_dst_clk                       (   i_dst_clk                                                   ),   //
        .i_dst_rst_n                     (   i_dst_rst_n                                                 ),   //
        .i_src_pulse                     (   i_src_pulse                                                 ),   //
        .o_dst_pulse                     (   o_dst_pulse                                                 )    //
    
    );
    
    endmodule