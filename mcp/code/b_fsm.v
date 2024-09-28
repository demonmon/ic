module b_fsm (
    input  clk_b,
    input  rstn_b,
    input  b_en,
    input  bload,
    output bvalid    
);

    parameter WAIT = 1'b0, READY = 1'b1;
    reg c_state,n_state;

    always @(posedge clk_b or negedge rstn_b) begin
        if(~rstn_b)
            c_state <= WAIT;
        else 
            c_state <= n_state;
    end

    always @(*) begin
        case(c_state)
        WAIT:
            begin
                if(b_en) n_state = READY;
                else     n_state = WAIT;
            end
        READY:
            begin
                if(bload) n_state = WAIT;
                else      n_state = READY;
            end   

        endcase
    end
    
    assign bvalid = c_state;


endmodule //b_fsm