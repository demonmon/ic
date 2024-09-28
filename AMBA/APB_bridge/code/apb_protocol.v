//`include "./apb_master.v"
module apb_protocol #(
    parameter DATA_WIDTH = 32,
              ADDR_WIDTH = 12,
              CMD_WIDTH = DATA_WIDTH + ADDR_WIDTH + 1
)(
    input [CMD_WIDTH-1:0] cmd_in,
    input       cmd_vld,
    input       a_pclk,rstn,transfer,
    input       b_pclk,
    //input [ADDR_WIDTH-1:0] paddr,
    //input [DATA_WIDTH-1:0] pwdata,
    output [DATA_WIDTH-1:0] apb_rdata,
    output                 cmd_rdy
);


    wire PSEL_1,PSEL_2,psel;
    wire pready_1,pready_2;
    wire pready,penable,pwrite;
    wire [DATA_WIDTH-1:0] pwdata;
    wire [DATA_WIDTH-1:0] prdata_1,prdata_2,prdata;
    wire [ADDR_WIDTH-1:0] paddr;
    wire read_vld;
    wire pslverr;
    assign pready = pready_2;
    assign prdata = prdata_2;
    
    
    wire [ADDR_WIDTH-1:0] b_paddr;
    wire b_psel,b_penable,b_pwrite;
    wire [2:0] b_pprot,a_pprot;
    wire [3:0] b_pstrb;
    wire [31:0] b_pwdata,b_prdata,a_prdata;
    wire b_pready,b_pslverr;

    a_apb_master #(
        .DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH)) 
        dut_master (
        .clk       ( a_pclk    ),
        .rstn      ( rstn      ),
        .cmd_in    ( cmd_in    ),
        .cmd_vld   ( cmd_vld   ),
        .cmd_rdy   ( cmd_rdy   ),
        .read_vld  ( read_vld  ),
        .read_data ( apb_rdata ),
        .pready    ( pready    ),//
        .transfer  ( transfer  ),
        .prdata    ( prdata    ),  //      
        .pwdata    ( pwdata    ),
        .paddr     ( paddr     ),
        .psel      ( psel    ),//
        .penable   ( penable   ),
        .pwrite    ( pwrite    ),
        .pslverr   ( pslverr   )
    ); 


    apb2apb_bridge  u_apb2apb_bridge (
    .a_pclk                  ( a_pclk          ),
    .a_presetn               ( rstn            ),

    .a_psel                  ( psel            ),
    .a_penable               ( penable         ),
    .a_paddr                 ( paddr           ),
    .a_pwrite                ( pwrite          ),
    .a_pprot                 ( a_pprot         ),
    .a_pstrb                 ( 4'b1111         ),
    .a_pwdata                ( pwdata          ),//master 

    .a_pready                ( pready          ),
    .a_prdata                ( prdata          ),
    .a_pslverr               ( pslverr         ),//给master的信号

    .b_pclk                  ( b_pclk            ),
    .b_presetn               ( rstn              ),

    .b_prdata                ( b_prdata          ),
    .b_pready                ( b_pready          ),
    .b_pslverr               ( b_pslverr         ),//slave给的

    

    .b_paddr                 ( b_paddr           ),//给slave的
    .b_psel                  ( b_psel            ),
    .b_penable               ( b_penable         ),
    .b_pwrite                ( b_pwrite          ),
    .b_pprot                 ( b_pprot           ),
    .b_pstrb                 ( b_pstrb           ),
    .b_pwdata                ( b_pwdata          )
);


//slave 节点1
    apb_slave1 #(
        .DATA_WIDTH(DATA_WIDTH),.ADDR_WIDTH(ADDR_WIDTH)) 
    slave1 (
        .clk       ( b_pclk    ),
        .rstn      ( rstn     ),
        .psel      ( PSEL_1   ),
        .penable   ( penable  ),
        .pwrite    ( pwrite   ),
        .paddr     ( paddr    ),
        .pwdata    ( pwdata   ),
        .prdata    ( prdata_1 ),
        .pready    ( pready_1 )
    );

//slave 节点2
    slave_top #(
        .ADDR_WIDTH ( ADDR_WIDTH ),.DATA_WIDTH(DATA_WIDTH))
    slave2 (
    .pclk                    ( b_pclk      ),
    .prst_n                  ( rstn       ),
    .psel                    ( b_psel     ),
    .paddr                   ( b_paddr      ),
    .penable                 ( b_penable    ),
    .pwrite                  ( b_pwrite     ),
    .pwdata                  ( b_pwdata     ),
    .pstrb                   ( b_pstrb    ),
    .ecorevnum               ( 4'b0       ),

    .prdata                  ( b_prdata   ),
    .pready                  ( b_pready   ),
    .pslverr                 ( b_pslverr    )
);




endmodule //apb_protocol
