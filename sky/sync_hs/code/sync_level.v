module sync_level (
    input clk_o,
    input rstn_o,
    input din,
    
    output  dout
);
    parameter SYNC_STAGE = 2;

    reg sync0,sync1 ;

    always @(posedge clk_o or negedge rstn_o) begin
        if(~rstn_o)
            sync0 <= 1'b0;
        else 
            sync0 <= din;    
    end

    always @(posedge clk_o or negedge rstn_o) begin
        if (~rstn_o) begin
            sync1 <= 1'b0;
        end
        else
            sync1 <= sync0 ;     
    end

    assign  dout = sync1;

  /*  generate
        if (SYNC_STAGE == 3) begin
            reg sync2;
            always @(posedge clk_o or negedge rstn_o) begin
                if (~rstn_o) begin
                    sync2 <= 1'b0;
                end
                else
                    sync2 <= sync1;
            end
            assign dout = sync2;
        end else begin
            assign dout = sync1;
        end
                
        
    endgenerate
    */


endmodule //sync_level