module cdc_syncfifo #(
    parameter  DWIDTH = 8
)
(
    input wclk,w_rstn,
    input w_en,
    input [DWIDTH-1:0] wdata,  
    output wrdy,
    
    input rclk,r_rstn,
    input r_en,
    output rrdy,
    output [DWIDTH-1:0] rdata
);

reg rptr,wptr;

//wctl logic
    wire we;
    
    wire wq2_rptr;
    assign we = w_en & wrdy;
    assign wrdy = ~(wptr ^ wq2_rptr);
    always @(posedge wclk or negedge w_rstn) begin
        if(~w_rstn)
            wptr <= 0;
        else if (we) 
            wptr <= ~wptr;
    end
    sync2 rptr_sync2 (
        .clk  (wclk),
        .rstn (w_rstn),
        .din  (rptr),
        .dout (wq2_rptr)
    );



//rtcl logic
    wire re;
    wire wq2_wptr;
    assign re = r_en & rrdy ;
    assign rrdy = (rptr ^ wq2_wptr);
    always @(posedge rclk or negedge r_rstn) begin
        if(~r_rstn)
            rptr <= 0;
        else if (re) 
            rptr <= ~rptr;
    end

    sync2 wptr_sync2 (
        .clk  (rclk),
        .rstn (r_rstn),
        .din  (wptr),
        .dout (wq2_wptr)
    );


//memory
    
    reg [DWIDTH-1:0] mem [1:0];

    always @(posedge wclk ) begin
        if(we)
            mem[wptr] <= wdata;
    end
    assign rdata = mem[rptr];

endmodule //cdc_syncfifo