module top_module (
    input clk,
    input reset,   // Synchronous active-high reset
    output [3:1] ena,
    output [15:0] q);
    

    wire en4;
    wire en2,en1,en3;
    assign ena[1] = en1;
    assign ena[2] = en2 ;
    assign ena[3] = en3; 
    
    bcd4 bcd4_0(
        .clk(clk),
        .reset(reset),
        .cin(1'b1),
        .q(q[3:0]),
        .cout(en1)
    );
    
    bcd4 bcd4_1(
        .clk(clk),
        .reset(reset),
        .cin(en1),
        .q(q[7:4]),
        .cout(en2)
    );
    
    bcd4 bcd4_2(
        .clk(clk),
        .reset(reset),
        .cin(en2),
        .q(q[11:8]),
        .cout(en3)
    );
    
    bcd4 bcd4_3(
        .clk(clk),
        .reset(reset),
        .cin(en3),
        .q(q[15:12]),
        .cout(en4)
    );
  
endmodule

module  bcd4 (
    input clk,
    input reset,
    input cin,
    output  [3:0] q,   
    output  cout
    );
     reg cout_m;
     reg [3:0]q_m;
    always @(posedge clk ) begin
        if (reset) begin
            q_m <= 4'b0;
        	cout_m <= 0;
        end
        else  if(cin) begin 
            if (q_m == 4'd9) begin
            	q_m <= 4'b0;
            	
            end
        	else begin
            	q_m <= q_m+4'b1;
            	
       		end
        end
        else q_m <= q_m;
    end
    
    assign q = q_m;
   	assign cout = (q == 4'd9 && cin) ?1'b1:1'b0;
endmodule