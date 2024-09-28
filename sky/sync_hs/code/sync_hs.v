module sync_hs #(
    parameter  DWIDTH = 8 
)(
    input clk_i,
    input rstn_i,
    input in_vld,
    input [DWIDTH-1:0] din,
    output in_ack,

    input clk_o,
    input rstn_o,
    output reg out_vld,
    output reg [DWIDTH-1:0] dout,
    input out_ack

);
    parameter SYNC_STAGE = 2;
   // parameter DWIDTH     = 8;

    // clk_i domain signals
    wire din_cap ;
    reg in_vld_lev;
    reg [DWIDTH-1:0] din_r;

    wire vld_sync_clk_i; //level signal
    reg vld_sync_clk_i_r0; // 1T delay
    wire vld_sync_clk_i_rise; // 1T pulse


    // clk_o domain signals
    wire dout_cap; // 1T pulse
    reg vld_sync;  //level signals

    assign din_cap = in_vld & in_ack;

    assign in_ack = (!vld_sync_clk_i) & (!in_vld_lev);
    assign vld_sync_clk_i_rise = vld_sync_clk_i & (! vld_sync_clk_i_r0 );//只产生前面的脉冲


    sync_level #(.SYNC_STAGE(SYNC_STAGE)) u_vld_sync_clk_i(
        .din(vld_sync),
        .dout(vld_sync_clk_i),
        .clk_o(clk_i),
        .rstn_o(rstn_i)
    );

    always @(posedge clk_i) begin
        if(din_cap)
            din_r <= din;
    end

    always @(posedge clk_i or negedge rstn_i) begin
        if(~rstn_i) 
            vld_sync_clk_i_r0 <= 1'b0;
        else
            vld_sync_clk_i_r0 <= vld_sync_clk_i;    
    end
    //再打一拍，共三拍 


    always @(posedge clk_i or negedge rstn_i) begin
        if(~rstn_i) 
            in_vld_lev <= 1'b0;
        else if (din_cap) begin
            in_vld_lev <=1'b1;
        end
        else if (vld_sync_clk_i_rise)
            in_vld_lev <= 1'b0 ;                        
    end


// clk_o domain
    wire in_vld_clk_o;
    reg in_vld_r0_clk_o;
    wire in_vld_rise_clk_o;

    assign dout_cap = out_vld & out_ack;

    sync_level #(.SYNC_STAGE(SYNC_STAGE)) u_in_vld_sync_clko(
        .din(in_vld_lev),
        .dout(in_vld_clk_o),
        .clk_o(clk_o),
        .rstn_o(rstn_o)
    );

    assign in_vld_rise_clk_o = in_vld_clk_o & (!in_vld_r0_clk_o);


    always @(posedge clk_o or negedge rstn_o) begin   //共三拍
        if(~rstn_o) 
            in_vld_r0_clk_o <= 1'b0;
        else
            in_vld_r0_clk_o <= in_vld_clk_o;    
    end 



    always @(posedge clk_o or negedge rstn_o) begin
        if(in_vld_rise_clk_o)
            dout <= din_r;
    end
    always @(posedge clk_o or negedge rstn_o ) begin
        if(~rstn_o) begin
            out_vld<=1'b0;
        end
        else if (in_vld_rise_clk_o) begin
            out_vld <= 1'b1;
        end
        else if(out_ack) begin
            out_vld <= 1'b0;
        end
    end

    always @(posedge clk_o or negedge rstn_o) begin
        if(~rstn_o)
            vld_sync <= 1'b0;
        else if (in_vld_rise_clk_o) 
            vld_sync <= 1'b1;
        else if (vld_sync) begin
            if ((!out_vld) && (!in_vld_clk_o)) begin
                vld_sync <= 1'b0;
            end
        end        
    end


endmodule //sync_hs