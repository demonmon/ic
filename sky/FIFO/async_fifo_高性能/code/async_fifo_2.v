module async_fifo_2 #(
    parameter DATESIZE  = 8,
    parameter ADDRSIZE  = 4
) 
(
    input [DATESIZE-1:0] wdata,
    input winc, wclk, w_rstn,
    input rinc, rclk, r_rstn,
    output  [DATESIZE-1:0] rdata,
    output reg wfull,
    output reg rempty
   
);

// RTL Verilog memory model
    wire [ADDRSIZE-1 : 0] waddr,raddr; 
    reg  [ADDRSIZE-1 : 0] wptr,rptr;

    localparam DEPTH = 1<<ADDRSIZE;
    reg [DATESIZE-1:0] mem [0:DEPTH-1];
    
    assign rdata = mem[raddr];
    always @(posedge wclk)
        if (winc && !wfull) mem[waddr] <= wdata;
      
    //COM
    async_cmp #(.ADDRSIZE(ADDRSIZE)) u_async_cmp  (
            .wptr(wptr),
            .rptr(rptr),
            .w_rstn(w_rstn),

            .aempty_n(aempty_n),
            .afull_n(afull_n)       
    );

    //异步信号需要先异步复位同步释放
    //aempty_n
    reg sync_r1;
    always @(posedge rclk or negedge aempty_n) begin
        if(~aempty_n)
            {rempty,sync_r1} = 2'b11;
        else 
            {rempty,sync_r1} = {sync_r1,~aempty_n};
    end

    reg sync_w1;
    always @(posedge rclk or negedge afull_n or negedge w_rstn) begin
        if (~w_rstn) 
            {wfull,sync_w1} = 2'b00;
        if(~afull_n) 
            {wfull,sync_w1} = 2'b11;
        else 
            {wfull,sync_w1} = {sync_w1,~afull_n} ;
    end
  
    reg [ADDRSIZE-1:0] wbin;
    wire [ADDRSIZE-1:0] wbin_next,wptr_next;
    wire mem_wr;
    assign mem_wr = winc & (!wfull);
    assign waddr = wbin;//写地址
    assign wbin_next = wbin+mem_wr;
    assign wptr_next = (wbin_next>>1) ^ wbin_next;// bin to gray code
    
    always @(posedge wclk or negedge w_rstn ) begin//reg output
        if (!w_rstn) begin
            {wptr,wbin} <= 0;
        end else begin
            {wptr,wbin} <= {wptr_next,wbin_next};
        end       
    end
    
    //empty 同理
    reg [ADDRSIZE-1:0] rbin;
    wire [ADDRSIZE-1:0] rptr_next, rbin_next;
    always @(posedge rclk or negedge r_rstn)
        if (!r_rstn) begin
            {rbin, rptr} <= 0;
        end
        else {rbin, rptr} <= {rbin_next, rptr_next};
    wire mem_rd;
    assign mem_rd = rinc & (~rempty);
    assign raddr = rbin;
    assign rbin_next = rbin + mem_rd;
    assign rptr_next = (rbin_next>>1) ^ rbin_next;

    
    





endmodule //async_fifo_2