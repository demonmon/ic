module s_round_arb (
    input [3:0] req, 
    output reg [3:0] gnt, 
    
    input  clk,
    input  rstn  
);
    reg [3:0] fixed_req; 

    wire arb_time ;
    reg  arb_time_d ;
    assign arb_time = (!arb_time_d) & (|req);


    reg [3:0] gnt_w ;
    reg [7:0] cur_pri;


    always @(*) begin
        case(cur_pri[1:0])
        2'd0: fixed_req[0] = req[0];
        2'd1: fixed_req[0] = req[1];
        2'd2: fixed_req[0] = req[2];
        2'd3: fixed_req[0] = req[3];            
        endcase
        
    end

    always @(*) begin
        case(cur_pri[3:2])
        2'd0: fixed_req[1] = req[0];
        2'd1: fixed_req[1] = req[1];
        2'd2: fixed_req[1] = req[2];
        2'd3: fixed_req[1] = req[3];            
        endcase
        
    end

    always @(*) begin
        case(cur_pri[5:4])
        2'd0: fixed_req[2] = req[0];
        2'd1: fixed_req[2] = req[1];
        2'd2: fixed_req[2] = req[2];
        2'd3: fixed_req[2] = req[3];            
        endcase
        
    end

    always @(*) begin
        case(cur_pri[7:6])
        2'd0: fixed_req[3] = req[0];
        2'd1: fixed_req[3] = req[1];
        2'd2: fixed_req[3] = req[2];
        2'd3: fixed_req[3] = req[3];            
        endcase
        
    end

    always @(*)begin
        if(fixed_req[0] ) gnt_w = 4'b0001 <<cur_pri[1:0];
        else if(fixed_req[1]) gnt_w = 4'b0001<<cur_pri[3:2];
        else if(fixed_req[2]) gnt_w = 4'b0001 <<cur_pri[5:4];
        else if(fixed_req[3]) gnt_w = 4'b0001 << cur_pri[7:6];
        else gnt_w = 4'b0000;
    end

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            gnt <= 0;
        end
        else 
            gnt<=gnt_w;
    end
        

    always @(posedge clk or negedge rstn) begin
        if(~rstn) begin
            cur_pri <= {2'b11,2'b10,2'b01,2'b00};
        end
        else begin
            if (gnt_w[0]) begin 
                cur_pri <= {cur_pri[1:0],cur_pri[7:2]};
            end 
            else if(gnt_w[1]) begin 
                cur_pri <= {cur_pri[3:2],cur_pri[7:4],cur_pri[1:0]};
            end
            else if(gnt_w[2]) begin 
                cur_pri <={cur_pri[5:4],cur_pri[7:6],cur_pri[3:0]};
            end
            else if(gnt_w[3]) begin
                cur_pri <= cur_pri;
            end    
        end
    end

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            arb_time_d <= 0;
        end
        else
            arb_time_d<=arb_time;
    end


    










endmodule