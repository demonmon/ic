module mcp #(
    parameter DWIDTH = 8
)
 (
    input clk_a,
    input [DWIDTH-1:0]adatain,
    input asend,
    input rstn_a,
    output aready,

    input clk_b,
    input rstn_b,
    input bload,
    output bvalid,
    output reg [DWIDTH-1:0] bdata
);

//-----------------clk_a domain-----------------------//
    wire din_cap; // 1 cycle pluse
    reg [DWIDTH-1:0] adata;
    reg a_en;

    assign din_cap = asend & aready;
    always @(posedge clk_a ) begin
        if (din_cap) 
            adata <= adatain;
    end

    //pluse--->level
    always @(posedge clk_a or negedge rstn_a) begin
        if(~rstn_a)
            a_en <= 0;
        else if (din_cap)
            a_en <= ~a_en;    
    end


    //level --> pluse
    wire b_ack_sync2;
    reg  b_ack_sync3;
    wire a_ack;
    reg   b_ack;

    sync2 b_ack_1 (
        .clk  ( clk_a  ),
        .rstn ( rstn_a ),
        .din  ( b_ack  ),
        .dout ( b_ack_sync2 ) 
    );

    always @(posedge clk_a or negedge rstn_a) begin
        if(~rstn_a) 
            b_ack_sync3 <= 0;
        else 
            b_ack_sync3 <= b_ack_sync2;    
    end

    assign a_ack = b_ack_sync2 ^ b_ack_sync3;

    //FSM
    /*
    a_fsm afsm (
        .clk_a  ( clk_a  ),
        .rstn_a ( rstn_a ),
        .asend  ( asend  ),
        .a_ack  ( a_ack  ),
        .aready ( aready )

    );*/

    reg aready_m;
    always @(posedge clk_a or negedge rstn_a) begin
       if(~rstn_a) 
            aready_m <= 1;
        else if (asend) begin
            aready_m <= 0;
        end  else if (a_ack) begin
            aready_m <= 1;
        end
    end
    assign aready = aready_m;


//-------------------clk_b domain----------------------------//
    wire  a_en_sync2;
    reg   a_en_sync3;
    wire  b_en;
    wire  bload_data;
    

    // level-->pluse
    sync2 a_en_1 (
        .clk(clk_b),
        .rstn(rstn_b),
        .din (a_en),
        .dout(a_en_sync2)
    );
    
    always @(posedge clk_b or negedge rstn_b) begin
        if(~rstn_b)
            a_en_sync3 <= 0;
        else 
            a_en_sync3 <= a_en_sync2;
    end

    assign b_en = a_en_sync2 ^ a_en_sync3; 
//FSM
 /*   b_fsm bfsm (
        .clk_b  (clk_b),
        .rstn_b ( rstn_b),
        .b_en   ( b_en  ),
        .bload  ( bload ),
        .bvalid ( bvalid )
    );  */

    reg bvalid_m ;
    always @(posedge clk_b or negedge rstn_b) begin
        if (~rstn_b)
            bvalid_m <= 0;
        else if (b_en) begin
            bvalid_m <= 1;
        end else if (bload) begin
            bvalid_m <= 0;
        end
    end
    assign bvalid = bvalid_m;


    assign bload_data = bvalid & bload;//pluse

    always @(posedge clk_b ) begin
        if (bload_data)
            bdata <= adata;
    end

    always @(posedge clk_b or negedge rstn_b) begin
        if(~rstn_b)
            b_ack <= 0;
        else if (bload_data)
            b_ack <= ~b_ack;    
    end




endmodule //mcp