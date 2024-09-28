`timescale  1ns / 1ps

module tb_axil_top;

// axil_top Parameters
parameter PERIOD   = 10                ;
parameter DATA_WD  = 8                 ;
parameter ADDR_WD  = 8                 ;
parameter BYTE_WD  = (ADDR_WD + DATA_WD)>>3;
parameter MODE = 1'b1;

// axil_top Inputs
reg   clk                            ;
reg   rstn                           ;
reg   [BYTE_WD-1:0]  tkeep           ;
wire   [DATA_WD + ADDR_WD-1:0]  tdata ;
reg   tvalid                         ;

// axil_top Outputs
wire    tready;
wire    tfire;
assign tfire = tready && tvalid;
//计数器
reg  [ADDR_WD : 0]  cnt;
reg  [DATA_WD-1: 0] data; 

wire mode;
assign mode = cnt[ADDR_WD];
assign tdata = {data,cnt[ADDR_WD-1:0]};

generate if (MODE) begin
    always@(posedge clk or negedge rstn) begin
        if (!rstn) begin
            tvalid <= 0;
            cnt <='b0;
            data <= 'b0;
        end else begin
            if(!mode) begin
                tkeep <= 2'b11;
                if (!tvalid) begin
                    tvalid <= $random; 
                end
                if (tfire) begin
                    cnt <= cnt + 1;
                    data <= data + 1;
                    tvalid <= $random;
                end
            end else begin
                tkeep <= 2'b01;
                if (!tvalid) begin
                    tvalid <= $random; 
                end
                if (tfire) begin
                    cnt <= cnt + 1;
                    tvalid <= $random;
                end
                
            end
                
        end
    end
end else begin
    always@(posedge clk or negedge rstn) begin
        if (!rstn) begin
            tvalid <= 0;
            cnt <='b0;
            data <= 'b0;
        end else  begin
            if(!mode) begin
                tkeep <= 2'b11;
                tvalid <= 1;

                if (tfire) begin
                    cnt <= cnt + 1;
                    data <= data + 1;
                end

            end else begin
                tkeep <= 2'b01;
                tvalid <= 1;
                if (tfire) begin
                    cnt <= cnt + 1;
                    //data <= data + 1;
                    //tvalid <= $random;
                end
                
            end
        end
    end
end
    
endgenerate







initial
begin
    clk = 0;
    forever #(PERIOD/2)  clk=~clk;
end

initial
begin
    rstn = 0;
    #(PERIOD*2) rstn  =  1;
end
initial begin
    $dumpfile("test.vcd");
    $dumpvars;
end

axil_top #(
    .DATA_WD ( DATA_WD ),
    .ADDR_WD ( ADDR_WD ),
    .BYTE_WD ( BYTE_WD ))
 u_axil_top (
    .clk                     ( clk                             ),
    .rstn                    ( rstn                            ),
    .tkeep                   ( tkeep   [BYTE_WD-1:0]           ),
    .tdata                   ( tdata   [DATA_WD + ADDR_WD-1:0] ),
    .tvalid                  ( tvalid                          ),

    .tready                  ( tready                          )
);

initial
begin
    #10000;
    $finish;
end

endmodule