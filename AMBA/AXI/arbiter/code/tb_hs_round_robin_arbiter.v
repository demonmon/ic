`timescale  1ns / 1ps

module tb_hs_round_robin_arbiter;   

// hs_round_robin_arbiter Parameters
parameter PERIOD    = 10  ;
parameter REQ_NUM   = 8   ;
parameter USE_LAST  = 1'b1;

// hs_round_robin_arbiter Inputs
reg   clk                        ;
reg   rstn                       ;
reg   [REQ_NUM-1:0]  valid_in    ;
reg   [REQ_NUM-1:0]  payload_in  ;
reg   [REQ_NUM-1:0]  last_in     ;
reg   ready_out                  ;

// hs_round_robin_arbiter Outputs
wire  [REQ_NUM-1:0]  ready_in    ;
wire  valid_out                  ;
wire  payload_out                ;
wire  last_out                   ;

//fire
wire [REQ_NUM-1:0] fire_in;
assign fire_in = valid_in & ready_in;

parameter pack_num = 2;
reg [5:0] counter0;
reg [5:0] counter1;
reg [5:0] counter2;
reg [5:0] counter3;

reg [5:0] counter [REQ_NUM-1:0];




genvar i;
generate
for (i=0; i<REQ_NUM; i=i+1) begin
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            valid_in[i] <= 0;
            payload_in[i] <= 0;
        end else begin
            if (!valid_in[i]) begin
                valid_in[i]  <= #0.1  $random;
            end else if(fire_in[i]) begin
                valid_in[i]  <= #0.1 $random;
                payload_in[i] <= payload_in[i] + 1;
                //counter[i] <= counter[i] + 1;
            end
        end
    end
   /* always @(*) begin
        if (!rstn) begin
            last_in[i] = 1'b0;
        end else if(counter[i] == ((i+1)*4-1)) begin
            last_in[i] = 1'b1;
        end else begin
            last_in[i] = 1'b0;
        end
    end*/
end    
endgenerate
parameter AUTO = 1'b0;
genvar j;
generate if (REQ_NUM == 4) begin
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            counter0 <= 0;
            counter1 <= 0;
            counter2 <= 0;
            counter3 <= 0;
        end else begin
            if(fire_in[0]) begin
                counter0 <= counter0 + 1;
                if (counter0 == 3) begin
                  counter0 <= 0;  
               end
            end 
    
            if(fire_in[1]) begin
                counter1 <= counter1 + 1;
                if (counter1 == 7) begin
                    counter1 <= 0;
                end
            end
            if(fire_in[2]) begin
                counter2 <= counter2 + 1;
                if (counter2 == 11) begin
                    counter2 <= 0;
                end
            end
            if(fire_in[3]) begin
                counter3 <= counter3 + 1;
                if (counter3 == 15) begin
                    counter3 <= 0;
                end
            end
        end
    end
    always @(*) begin
        if(counter0 == 3)
            last_in[0] = 1;
        else begin
            last_in[0] = 0;
        end    
        if (counter1 == 7) begin
            last_in[1] = 1;
        end else begin
            last_in[1] = 0;
        end   
        if (counter2 == 11) begin
            last_in[2] = 1;
        end else begin
            last_in[2] = 0;
        end
        if (counter3 == 15) begin
            last_in[3] = 1;
        end else begin
            last_in[3] = 0;
        end
    end
end else begin
    for (j = 0; j < REQ_NUM ; j = j+1) begin
        always @(posedge clk or negedge rstn) begin
            if (!rstn) begin
                counter[j] <= 'b0;
            end else begin 
                if (fire_in[j]) begin
                    counter[j] <= counter[j] +1;
                    if (counter[j] == ((j+1)*8-1)) begin
                        counter[j] <= 'b0;
                    end
                end 
            end
        end
        always @(*) begin
            if (counter[j] == ((j+1)*8-1)) begin
                last_in[j] = 1'b1;
            end else begin
                last_in[j] = 1'b0;
            end
                
        end
    end
end
    
    
endgenerate

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        ready_out <= 0;
    end else begin
        ready_out <= $random;
    end
end

initial
begin
    clk = 0;
    forever #(PERIOD/2)  clk=~clk;
end
initial begin
    $dumpfile("test.vcd");
    $dumpvars;
end

initial
begin
    rstn = 0;
    #(PERIOD*2) rstn  =  1;
end

weight_hs_rr_arbiter #(
    .REQ_NUM  ( REQ_NUM  ),
    .USE_LAST ( USE_LAST ))
 u_hs_round_robin_arbiter (
    .clk                     ( clk                        ),
    .rstn                    ( rstn                       ),
    .valid_in                ( valid_in     [REQ_NUM-1:0] ),
    .payload_in              ( payload_in   [REQ_NUM-1:0] ),
    .last_in                 ( last_in      [REQ_NUM-1:0] ),
    .ready_out               ( ready_out                  ),

    .ready_in                ( ready_in     [REQ_NUM-1:0] ),
    .valid_out               ( valid_out                  ),
    .payload_out             ( payload_out                ),
    .last_out                ( last_out                   )
);


initial
begin
    #10000;
    $finish;
end

endmodule