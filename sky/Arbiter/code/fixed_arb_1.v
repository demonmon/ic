module fixed_arb_1 (
    input [3:0] req, 
    output reg [3:0] gnt, 
    
    input  clk,
    input  rstn  

);
    reg arb_time_d;
    wire arb_time;
    reg [3:0] gnt_w;
    assign arb_time = (!arb_time_d) & (|req);


    always @(*)begin
        if(req [0] ) gnt_w = 4'b0001;
        else if(req[1]) gnt_w = 4'b0010;
        else if(req[2]) gnt_w = 4'b0100;
        else if(req[3]) gnt_w = 4'b1000;
        else gnt_w = 4'b0000;
    end

    always @(posedge clk or negedge rstn) begin
        if(~rstn) 
            gnt <= 4'b0;
        else if(arb_time) begin
            gnt<=gnt_w;
        end
        else if (arb_time_d) begin
            gnt <= 4'b0;
        end        
    end


    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            arb_time_d <= 4'b0;
        end
        else
            arb_time_d <= arb_time;
        
    end




endmodule

