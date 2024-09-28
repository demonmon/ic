module slave_top #(
    parameter ADDR_WIDTH = 12,
              DATA_WIDTH = 32
) (
    input pclk,
    input prst_n,
    input psel,
    input [ADDR_WIDTH-1:0] paddr,
    input penable,pwrite,
    input  [DATA_WIDTH-1:0] pwdata,
    input [3:0] pstrb,

    input [3:0] ecorevnum,
    
    output reg [DATA_WIDTH-1:0] prdata,
    output reg pready ,
    output reg pslverr
);

wire pready_r;
wire pslverr_r;
wire rd,wr;
wire [3:0] b_strobe;
wire [ADDR_WIDTH-1:0]addr;
wire [DATA_WIDTH-1:0] rdata;
wire [DATA_WIDTH-1:0] wdata;
apb_slave  #(.ADDR_WIDTH(ADDR_WIDTH),.DATA_WIDTH(DATA_WIDTH)) 
    u_apb_slave (
        .pclk                    ( pclk        ),
        .prst_n                  ( prst_n      ),
        .psel                    ( psel        ),
        .paddr                   ( paddr       ),
        .penable                 ( penable     ),
        .pwrite                  ( pwrite      ),
        .pwdata                  ( pwdata      ),
        .pstrb                   ( pstrb       ),
        .ecorevnum               ( ecorevnum   ),
        .rdata                   ( rdata       ),
        .pready_r                ( pready_r    ),
        .pslverr_r               ( pslverr_r   ),
    
        .prdata                  ( prdata      ),
        .pready                  ( pready      ),
        .pslverr                 ( pslverr     ),
        .addr                    ( addr        ),
        .rd                      ( rd          ),
        .wr                      ( wr          ),
        .b_strobe                ( b_strobe    ),
        .wdata                   ( wdata       )
    );

    apb_reg #(
        .ADDR_WIDTH ( ADDR_WIDTH ),.DATA_WIDTH(DATA_WIDTH))
    u_apb_reg (
        .pclk                    ( pclk        ),
        .rstn                    ( prst_n      ),
        .addr                    ( addr        ),
        .rd                      ( rd          ),
        .wr                      ( wr          ),
        .b_strobe                ( b_strobe    ),
        .wdata                   ( wdata       ),
        .ecorevnum               ( ecorevnum   ),
    
        .pready_r                ( pready_r    ),
        .pslverr_r               ( pslverr_r   ),
        .rdata                   ( rdata       )
    );


     

endmodule //slave_top
