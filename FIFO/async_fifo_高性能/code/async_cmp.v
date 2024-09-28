module async_cmp #(
    parameter ADDRSIZE = 4
)
(
    input [ADDRSIZE-1:0] rptr,wptr,
    input w_rstn,
    output aempty_n,afull_n
);
    reg direct;
    wire dirset_n,dirclr;
    //wptr--->rptr-->afull---direct=1
    assign dirset_n = ~((wptr[ADDRSIZE-1] ^ rptr[ADDRSIZE-2]) & (~(wptr[ADDRSIZE-2] ^ rptr[ADDRSIZE-1])));
    //rptr-->wptr-->aempty--direct=0
    assign dirclr = (((wptr[ADDRSIZE-2]) ^ (rptr[ADDRSIZE-1])) & (~(wptr[ADDRSIZE-1] ^ rptr[ADDRSIZE-2])));
    
    wire rst;
    assign rst = ~(~w_rstn|dirclr);//dirclr有效时，rst=0,立即复位,无效时，rst=w_rstn。

    always @(negedge rst or negedge dirset_n ) begin
        if(!rst) 
            direct <= 0;
        else if (!dirset_n)
            direct <= 1;
        else    
            direct <= 0;
    end

    wire cmp_flag;
    assign cmp_flag = (rptr == wptr);
    assign aempty_n = ~(cmp_flag & (~direct));
    assign afull_n  = ~(cmp_flag & direct);

endmodule //async_cmp