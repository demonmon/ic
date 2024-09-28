module a_fsm (
    input clk_a,
    input rstn_a,
    input asend,
    input a_ack,
    output aready

);
    parameter READY = 1'b1, BUSY = 1'b0;
    reg c_state,n_state;

    always @(posedge clk_a or negedge rstn_a) begin
        if(~rstn_a) 
            c_state <= READY;
        else
            c_state <= n_state;    
    end

  always @(*) begin
    case(c_state)
    READY:
        begin
            if(asend) n_state = BUSY;
            else      n_state = READY;
        end
    BUSY:
        begin
            if(a_ack) n_state = READY;
            else      n_state = BUSY;
        end     
        
    endcase
  end

  assign aready = c_state;

endmodule //a_fsm