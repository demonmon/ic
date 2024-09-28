// ---------------------------------------------------------------------------//
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
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
// File name    : spram_generic_wbe4.v
// Author       : sky@SiliconThink
// Email        : 
// Project      :
// Created      : 
// Copyright    : 
//
// Description  : 
// 1: Generic SP SRAM model.
//
//----------------------------------------------------------------------------//



module spram_generic_wbe4(
                    clk,
                    en,
                    we,
                    wbe,
            
                    addr,
                    din,
                    
                    dout
                    );    

parameter ADDR_BITS = 7;
parameter ADDR_AMOUNT = 128;
parameter DATA_BITS = 32;

input clk;
input en;
input we;
input [3:0]wbe;
input [ADDR_BITS-1:0]addr;
input [DATA_BITS-1:0]din;
output [DATA_BITS-1:0]dout;

reg [DATA_BITS-1:0]dout;
reg [DATA_BITS-1:0]mem[0 : ADDR_AMOUNT-1];

always@(posedge clk)
begin
	if(en) begin
        if(we==1'b1) begin
            if(wbe[0])
   	    	    mem[addr][0*8 +: 8] <= din[0*8 +: 8]; 

            if(wbe[1])
   	    	    mem[addr][1*8 +: 8] <= din[1*8 +: 8]; 

            if(wbe[2])
   	    	    mem[addr][2*8 +: 8] <= din[2*8 +: 8]; 

            if(wbe[3])
   	    	    mem[addr][3*8 +: 8] <= din[3*8 +: 8]; 
	    end else
        	dout<=mem[addr]; 
    end     
end


endmodule

