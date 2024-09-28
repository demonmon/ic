module sync2 (
    input clk,
    input rstn,
    input din,
    
    output  dout
);
   

    reg sync0,sync1 ;

    always @(posedge clk or negedge rstn) begin
        if(~rstn)
            sync0 <= 1'b0;
        else 
            sync0 <= din;    
    end

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            sync1 <= 1'b0;
        end
        else
            sync1 <= sync0 ;     
    end

    assign  dout = sync1;

endmodule