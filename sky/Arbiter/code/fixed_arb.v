module fixed_arb (
    input [3:0] req, 
    output reg [3:0] gnt, 
    
    input  clk,
    input  rstn  

);


reg [3:0] gnt_w;



always @(*)begin
    if(req [0] ) gnt_w = 4'b0001;
    else if(req[1]) gnt_w = 4'b0010;
    else if(req[2]) gnt_w = 4'b0100;
    else if(req[3]) gnt_w = 4'b1000;
    else gnt_w = 4'b0000;
end
always @(posedge clk or negedge rstn) begin
    if(~rstn) gnt = 4'b0000;
    else 
        gnt = gnt_w;    
end





endmodule //fixed_arb