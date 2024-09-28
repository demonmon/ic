module apb2apb_bridge  (
    input               a_pclk,
    input               a_presetn,
    
    input               a_psel, //a_clk的slave
    input               a_penable,

    input [11:0]        a_paddr,
    input               a_pwrite,
    input [2:0]         a_pprot,
    input [3:0]         a_pstrb,
    input [31:0]        a_pwdata,

    output reg          a_pready,
    output reg [31:0]   a_prdata,
    output reg          a_pslverr, 

    input               b_pclk, //b_clk的master
    input               b_presetn,
    output reg  [11:0]  b_paddr,
    output reg          b_psel,
    output reg          b_penable,
    output reg          b_pwrite,
    output reg [2:0]    b_pprot,
    output reg [3:0]    b_pstrb,
    output reg [31:0]   b_pwdata,
    input      [31:0]   b_prdata,
    input               b_pready,
    input               b_pslverr 
);

    reg         a_apb_req;
    reg         a2b_apb_req_r1,a2b_apb_req_r2,a2b_apb_req_r3;
    wire        a2b_apb_req_edge;// 1 cycle plus
    reg         a2b_apb_req_edge_r1;


    always @(posedge a_pclk or negedge a_presetn) begin
        if(~a_presetn)
            a_apb_req <= 0;
        else if (a_psel && !a_penable) begin
            a_apb_req <= 1;
        end else if (a_pready) 
            a_apb_req <= 0;
    end

    always @(posedge b_pclk or negedge b_presetn) begin
        if(~b_presetn) begin
            {a2b_apb_req_r3,a2b_apb_req_r2,a2b_apb_req_r1} <= 3'b0;
        end else begin
            {a2b_apb_req_r3,a2b_apb_req_r2,a2b_apb_req_r1} <= {a2b_apb_req_r2,a2b_apb_req_r1,a_apb_req};
        end
    end

    assign a2b_apb_req_edge = a2b_apb_req_r2 && ~a2b_apb_req_r3 ;

    always @(posedge b_pclk or negedge a_presetn) begin
        if(~a_presetn)
            a2b_apb_req_edge_r1 <= 0;
        else begin
            a2b_apb_req_edge_r1 <= a2b_apb_req_edge;
        end    
    end

    always @(posedge b_pclk or negedge b_presetn) begin
        if(~b_presetn)
            b_psel <= 1'b0;
        else if (a2b_apb_req_edge) 
            b_psel <= 1'b1;
        else if(b_psel && b_penable && b_pready) 
            b_psel <= 1'b0;
    end

    always @(posedge b_pclk or negedge b_presetn) begin
        if(~b_presetn)
            b_penable <= 1'b0;
        else if (a2b_apb_req_edge_r1) 
            b_penable <= 1'b1;
        else if(b_psel && b_penable && b_pready) 
            b_penable <= 1'b0;
    end


    always @(posedge b_pclk or negedge b_presetn) begin
        if(~b_presetn) begin
            b_pwrite <= 1'b0;
            b_paddr  <= 0;
            b_pstrb  <= 0;
            b_pprot  <= 0;
            b_pwdata <= 0; 
        end else if(a2b_apb_req_edge) begin
            b_pwrite <= a_pwrite;
            b_paddr  <= a_paddr;
            b_pstrb  <= a_pstrb;
            b_pprot  <= a_pprot;
            b_pwdata <= a_pwdata; 
        end
    end

    reg         b_ready_req;
    reg         b2a_ready_req_r1,b2a_ready_req_r2,b2a_ready_req_r3;
    wire        b2a_ready_req_edge; //1cycle plus

    always @(posedge b_pclk or negedge b_presetn) begin
        if(~b_presetn)
            b_ready_req <= 1'b0;
        else if(b_psel && b_penable && b_pready) 
            b_ready_req <= 1'b1;
        else if(b_psel && !b_penable)
            b_ready_req <= 1'b0;
    end

    always @(posedge a_pclk or negedge a_presetn) begin
        if(~b_presetn)
            {b2a_ready_req_r3,b2a_ready_req_r2,b2a_ready_req_r1} <= 3'b0;
        else
            {b2a_ready_req_r3,b2a_ready_req_r2,b2a_ready_req_r1} <= {b2a_ready_req_r2,b2a_ready_req_r1,b_ready_req};
    end      

            
    assign b2a_ready_req_edge = b2a_ready_req_r2 && ~b2a_ready_req_r3 ;

    always @(posedge a_pclk or negedge a_presetn) begin
        if(~a_presetn)
            a_pready <= 1'b1;
        else if(a_psel && ~a_penable)
            a_pready <= 1'b0;
        else if (b2a_ready_req_edge) begin
            a_pready <= 1'b1;
        end               
    end

    always @(posedge a_pclk or negedge a_presetn) begin
        if(~a_presetn) begin
            a_pslverr <= 1'b0;
            a_prdata  <= 'b0;
        end else if(b2a_ready_req_edge) begin
            a_pslverr <= b_pslverr;
            a_prdata  <= b_prdata;
        end
    end



endmodule //apb2apb_bridge
