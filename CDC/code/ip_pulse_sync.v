module ip_pulse_sync(
    input                                               i_src_clk                               ,   //
    input                                               i_src_rst_n                             ,   //
    input                                               i_dst_clk                               ,   //
    input                                               i_dst_rst_n                             ,   //
    input                                               i_src_pulse                             ,   //
    output  reg                                         o_dst_pulse                                 //
);

reg                                                     src_pulse_req                           ;   //
reg                                                     dst_pulse_req_d1                        ;   //
reg                                                    dst_pulse_req                           ;   //
reg                                                     src_pulse_ack                           ;   //


always @(posedge i_src_clk or negedge i_src_rst_n)
    if(!i_src_rst_n) begin
        src_pulse_req                   <=              1'b0                                    ;   
    end
    else if (i_src_pulse) begin
        src_pulse_req                   <=              1'b1                                    ;   
    end
    else if (src_pulse_ack) begin
        src_pulse_req                   <=              1'b0                                    ;   
    end
    
reg dst_pulse_req_r1;
always @(posedge i_dst_clk or negedge i_dst_rst_n) begin
    if (!i_dst_rst_n) begin
        {dst_pulse_req,dst_pulse_req_r1} <= 0;
    end else begin
        {dst_pulse_req,dst_pulse_req_r1} <= {dst_pulse_req_r1,src_pulse_req};
    end
end
    


always @(posedge i_dst_clk or negedge i_dst_rst_n)
    if(!i_dst_rst_n) begin
        dst_pulse_req_d1                <=              1'b0                                    ;   
    end
    else begin
        dst_pulse_req_d1                <=              dst_pulse_req                           ;   
    end
    
      
    
assign  dst_pulse_ack                               =   dst_pulse_req                           ;   //



always @(posedge i_src_clk or negedge i_src_rst_n) begin
    if (!i_src_rst_n) begin
        src_pulse_ack <= 0;
    end else begin
        src_pulse_ack <= dst_pulse_ack;
    end
end





always @(posedge i_dst_clk or negedge i_dst_rst_n)
    if(!i_dst_rst_n) begin
        o_dst_pulse                     <=              1'b0                                    ;   
    end
    else begin
        o_dst_pulse                     <=              (!dst_pulse_req_d1)&&dst_pulse_req      ;   
    end
    
    
endmodule