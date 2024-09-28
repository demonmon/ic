module round_arb (
    input [3:0] req, 
    output reg [3:0] gnt, 
    
    input  clk,
    input  rstn  
);
    reg [1:0] cur_pri;
    reg [1:0] n_cur_pri ;

    reg arb_time_d;
    wire arb_time;
    reg [3:0] gnt_w;
    assign arb_time = (!arb_time_d) & (|req);


    always @(*) begin
        case (cur_pri)
            2'd0: begin
                if(req [0] ) begin 
                    gnt_w = 4'b0001;
                    n_cur_pri = 2'd1;
                end
                else if(req[1]) begin 
                    gnt_w = 4'b0010;
                    n_cur_pri = 2'd2;
                end
                else if(req[2]) begin
                    gnt_w = 4'b0100;
                    n_cur_pri = 2'd3;
                end
                else if(req[3]) begin 
                    gnt_w = 4'b1000;
                    n_cur_pri = 2'd0;
                end
                else gnt_w = 4'b0000;
            end
            2'd1:begin
                if(req [1] ) begin 
                    n_cur_pri = 2'd2;
                    gnt_w = 4'b0010;
                end
                else if(req[2]) begin
                    n_cur_pri = 2'd3;
                    gnt_w = 4'b0100;
                end
                else if(req[3]) begin
                    n_cur_pri = 2'd0;
                    gnt_w = 4'b1000;
                end
                else if(req[0]) begin 
                    n_cur_pri = 2'd1;
                    gnt_w = 4'b0001;
                end
                else gnt_w = 4'b0000;
            end
            2'd2:begin
                if(req [2] ) begin 
                    n_cur_pri = 2'd3;
                    gnt_w = 4'b0100;
                end
                else if(req[3]) begin
                    n_cur_pri = 2'd0;
                    gnt_w = 4'b1000;
                end
                else if(req[0]) begin 
                    n_cur_pri = 2'd1;
                    gnt_w = 4'b0001;
                end
                else if(req[1]) begin 
                    gnt_w = 4'b0010;
                    n_cur_pri = 2'd2;
                end
                else gnt_w = 4'b0000;
            end
            2'd3:begin
                if(req [3] ) begin 
                    n_cur_pri = 2'd0;
                    gnt_w = 4'b1000;
                end
                else if(req[0]) begin 
                    n_cur_pri = 2'd1;
                    gnt_w = 4'b0001;
                end
                else if(req[1]) begin 
                    gnt_w = 4'b0010;
                    n_cur_pri = 2'd2;
                end
                else if(req[2]) begin
                    n_cur_pri = 2'd3;
                    gnt_w = 4'b0100;
                end
                else gnt_w = 4'b0000;
            end
           
        endcase
    end


    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            gnt <= 0;
        end
        else if(arb_time) begin
            gnt <= gnt_w;
        end
        else if(arb_time_d) begin
            gnt <= 4'd0;
        end 
    end

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            cur_pri <= 2'd0;
        end
        else
            cur_pri <= n_cur_pri; 
    end

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            arb_time_d <= 0;
        end
        else 
            arb_time_d <= arb_time;
    end




endmodule //round_arb