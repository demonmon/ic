// by a subsisting licensing agreement from SiliconThink.
//
//      (C) COPYRIGHT SiliconThink Limited or its affiliates
//                   ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from SiliconThink or its affiliates.
// ---------------------------------------------------------------------------//

//----------------------------------------------------------------------------//
// File name    : tb.v
// Author       : sky@SiliconThink
// Email        : 
// Project      : 
// Created      : 
// Copyright    : 
// Description  : 
//----------------------------------------------------------------------------//

`timescale 1ns / 10ps

module tb();

parameter	clk_cyc = 10.0;

parameter   mem_depth   = 1024  ;
parameter   mem_abit    = 10    ;
parameter   mem_dw      = 32    ;   //can't change this parameter

reg             clk, rstn   ;

always #(clk_cyc/2.0) clk = ~clk;

initial begin
	clk = 0; rstn = 1;
	repeat(10) @(posedge clk); rstn = 0;
	repeat(10) @(posedge clk); rstn = 1;
end


//--- connection model and DUT
wire			hsel	;
wire	[(mem_abit+2-1):0] haddr;
wire	[2:0]	hburst	;	//support all burst type
wire	[1:0]	htrans	;   //support htrans type
wire	[2:0]	hsize	;   //support 8/16/32 bit trans
wire	[3:0]	hprot	;   //ignored
wire			hwrite	;	//r/w
wire	[mem_dw-1:0]hwdata;
wire			hready	;
wire			hreadyout;
wire	[31:0]	hrdata	;
wire	[1:0]   hresp	;



ahb_lite_ms_model #(.mem_depth(mem_depth), .mem_abit(mem_abit)) u_ahb_ms_model(
	//--- AHB inf
	.hsel		    (hsel		    ),
	.haddr		    (haddr		    ),
	.hburst	        (hburst	        ),
	.htrans	        (htrans	        ),
	.hsize		    (hsize		    ),
	.hprot		    (hprot		    ),
	.hwrite	        (hwrite	        ),
	.hwdata	        (hwdata	        ),
	.hready	        (hready	        ),
	.hreadyout	    (hreadyout	    ),
	.hrdata	        (hrdata	        ),
	.hresp		    (hresp		    ),
                                    
    .clk			(clk			),
    .rstn			(rstn			)  
);

integer i;
initial begin
    $dumpfile("test.vcd");
    $dumpvars;
    for (i = 0; i < 32; i = i + 1) begin
        $dumpvars(0,u_ahb_sram.u_mem.mem[i]);
    end
end


ahb_sram #(.mem_depth(mem_depth), .mem_abit(mem_abit)) u_ahb_sram(
	//--- AHB slave inf
	.hsel		    (hsel		    ),
	.haddr		    (haddr		    ),
	.hburst	        (hburst	        ),
	.htrans	        (htrans	        ),
	.hsize		    (hsize		    ),
	.hprot		    (hprot		    ),
	.hwrite	        (hwrite	        ),
	.hwdata	        (hwdata	        ),
	.hready	        (hready	        ),
	.hreadyout	    (hreadyout	    ),
	.hrdata	        (hrdata	        ),
	.hresp		    (hresp		    ),
                                    
    .clk            (clk            ),
    .rstn           (rstn           )   
);

initial begin
	#50000;
	$finish();
end


endmodule

