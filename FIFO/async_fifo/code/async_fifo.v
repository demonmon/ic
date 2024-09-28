module async_fifo #(
    parameter DATESIZE  = 8,
    parameter ADDRSIZE  = 4,
    parameter ALMOST    = 3
) 
(
    input [DATESIZE-1:0] wdata,
    input winc, wclk, w_rstn,
    input rinc, rclk, r_rstn,
    output wire [DATESIZE-1:0] rdata,
    output reg wfull,
    output reg rempty,
    output reg almost_full,
    output reg almost_empty
);
    parameter DEPTH = 1<<ADDRSIZE;
    wire [ADDRSIZE-1 : 0] waddr,raddr;  
    reg  [ADDRSIZE : 0] wptr,rptr;
    
    //read pointer to write clk sync
    reg [ADDRSIZE:0] wq1_rptr,wq2_rptr;
    always @(posedge wclk or negedge w_rstn) begin
        if (!w_rstn) begin
            {wq2_rptr,wq1_rptr} <= 0 ;
        end else begin
            {wq2_rptr,wq1_rptr} <= {wq1_rptr,rptr};
        end
    end

    // write pointer to read clk domain

    reg [ADDRSIZE:0] wq1_wptr,wq2_wptr;
    always @(posedge rclk or negedge r_rstn) begin
        if (!r_rstn) begin
            {wq2_wptr,wq1_wptr} <= 0 ;
        end else begin
            {wq2_wptr,wq1_wptr} <= {wq1_wptr,wptr};
        end
    end


    // full and empty logic
    reg [ADDRSIZE:0] wbin;
    wire [ADDRSIZE:0] wbin_next,wptr_next;
    wire mem_wr;
    assign mem_wr = winc & (!wfull);
    assign waddr = wbin[ADDRSIZE-1:0];
    assign wbin_next = wbin+mem_wr;
    //bin to gray code
    assign wptr_next = (wbin_next>>1) ^ wbin_next;
    //寄存器输出
    always @(posedge wclk or negedge w_rstn ) begin
        if (!w_rstn) begin
            {wptr,wbin} <= 0;
        end else begin
            {wptr,wbin} <= {wptr_next,wbin_next};
        end       
    end

    // full logic  MSB 不同 LSB相同
    //同步过来的读信号为wq2_rptr(gray code),wq2_rptr与下一个wptr的值进行比较
    //因为wq2_rptr是即将要读的，所以是比较下一个wptr，因为这拍完成之后，才符合full
    //例如wq2_rptr=0 此时wptr=7，
    //那么此时如果写数据有效(winc有效)的话，此时7这拍肯定写了，下一拍wptr就是8也就是满，
    //那么此时如果写数据无效(！winc有效)的话，此时7这拍肯定没写（将写），下一拍wptr还是7，也不会满
    //所以提前一拍判断是不是写满
    wire wfull_val;
    assign wfull_val = (wptr_next == {~wq2_rptr[ADDRSIZE:ADDRSIZE-1],wq2_rptr[ADDRSIZE-2:0]} );
    always @(posedge wclk or negedge w_rstn ) begin
        if (!w_rstn) begin
            wfull <= 0;
        end else begin
            wfull  <= wfull_val;
        end
    end

//empty 同理
    reg [ADDRSIZE:0] rbin;
    wire [ADDRSIZE:0] rptr_next, rbin_next;
    always @(posedge rclk or negedge r_rstn)
        if (!r_rstn) begin
            {rbin, rptr} <= 0;
        end
        else {rbin, rptr} <= {rbin_next, rptr_next};
    wire mem_rd;
    assign mem_rd = rinc & (~rempty);
    assign raddr = rbin[ADDRSIZE-1:0];
    assign rbin_next = rbin + mem_rd;
    assign rptr_next = (rbin_next>>1) ^ rbin_next;
    //empty logic
    assign rempty_val = (rptr_next == wq2_wptr);

    always @(posedge rclk or negedge r_rstn) begin
        if (!r_rstn) rempty <= 1'b1;
        else rempty <= rempty_val ;
    end

    //almost full and empty logic
    //需要将同步过来的格雷码转换成二进制去判断将空将满
    //gray to bin
    wire [ADDRSIZE:0] wq2_rptr_bin,wq2_wptr_bin;
    assign wq2_rptr_bin[ADDRSIZE] = wq2_rptr[ADDRSIZE];
    assign wq2_wptr_bin [ADDRSIZE] = wq2_wptr[ADDRSIZE];
    genvar i;
    generate
        for ( i=ADDRSIZE-1 ; i>= 0 ; i=i-1 ) begin
            assign wq2_rptr_bin[i] = wq2_rptr[i] ^ wq2_rptr_bin[i+1];
            assign wq2_wptr_bin[i] = wq2_wptr[i] ^ wq2_wptr_bin[i+1];
        end
    endgenerate

    //almost empty and full
    wire almost_empty_val,almost_full_val;
    //empty
    wire [ADDRSIZE:0] wgap;
    assign wgap = wq2_wptr_bin-rbin;
    assign almost_empty_val = (wgap <= ALMOST);
    always @(posedge rclk or negedge r_rstn) begin
        if (!r_rstn) begin
            almost_empty <= 1'b1;
        end else begin
            almost_empty <= almost_empty_val;
        end
    end


    //full
    wire [ADDRSIZE:0] rcap;
    assign rcap = (wq2_rptr_bin[ADDRSIZE] != wbin[ADDRSIZE]) ? 
                 (wq2_rptr_bin[ADDRSIZE-1:0] - wbin[ADDRSIZE-1:0]) : (DEPTH-(wbin - wq2_rptr_bin)) ;
    assign almost_full_val = (rcap <= ALMOST);
    always @(posedge wclk or negedge w_rstn) begin
        if (!w_rstn) 
            almost_full <= 1'b0;
        else 
            almost_full <= almost_full_val;       
    end     
    dpram #(.ADDRSIZE(ADDRSIZE),.DATESIZE(DATESIZE)) u_dpram(
        .clkb(rclk),
        .enb(mem_rd),
        .addrb(raddr),
        .doutb(rdata),

        .clka(wclk),
        .ena(mem_wr),
        .wea(mem_wr),
        .dina(wdata),
        .addra(waddr)

    );
    
endmodule //async_fifo
