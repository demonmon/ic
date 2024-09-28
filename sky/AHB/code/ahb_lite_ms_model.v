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
// File name    : ahb_lite_ms_model.v
// Author       : sky@SiliconThink
// Email        : 
// Project      :
// Created      : 
// Copyright    : 
//
// Description  : 
// 1: ahb-lite master model.
// 2: support idle/busy/nonseq/seq trans; 8b/16b/32b size;
// 3: doesn't check for hresp.
//----------------------------------------------------------------------------//

`define	MEM_PATH	tb.u_ahb_sram.u_mem

`define EN_BAKC2BACK
`timescale 1ns/10ps
module ahb_lite_ms_model(
	//--- ahb-lite master interface
	hsel			,
	haddr			,
	hburst			,
	htrans			,
	hsize			,
	hprot			,
	hwrite			,
	hwdata			,
	hready			,
	hreadyout		,
	hrdata			,
	hresp			,

    clk				,
    rstn			 
);


parameter   mem_depth   = 1024  ;
parameter   mem_abit    = 10    ;
parameter   mem_dw      = 32    ;   //can't change this


input   wire			clk, rstn	;

output	wire			hsel		;
output	wire	[11:0]	haddr		;
output	wire	[2:0]	hburst		;
output	wire	[1:0]	htrans		;
output	wire	[2:0]	hsize		;
output	wire	[3:0]	hprot		;
output	wire			hwrite		;	//should be 1'b0, read only
output	wire	[31:0]	hwdata		;
output	wire			hready		;

input	wire			hreadyout	;
input	wire	[31:0]	hrdata		;
input	wire	[1:0]   hresp		;


reg     [7:0]   ref_mem [0 : (mem_depth*4) - 1];

reg             bus_rd_dph  ;   //read trans data phase
reg     [4:0]   bt_wait     ;

//--- debug purpose
wire    [7:0]   ref_mem0    ;
wire    [7:0]   ref_mem1    ;
wire    [7:0]   ref_mem2    ;
wire    [7:0]   ref_mem3    ;
wire    [7:0]   ref_mem4    ;
wire    [7:0]   ref_mem5    ;
wire    [7:0]   ref_mem6    ;
wire    [7:0]   ref_mem7    ;
wire    [7:0]   ref_mem8    ;
wire    [7:0]   ref_mem9    ;
wire    [7:0]   ref_mem10   ;
wire    [7:0]   ref_mem11   ;

wire    [31:0]  dbg_addr    ;
wire    [7:0]   ref_dbg0    ;
wire    [7:0]   ref_dbg1    ;
wire    [7:0]   ref_dbg2    ;
wire    [7:0]   ref_dbg3    ;
wire    [31:0]  dut_dbg     ;

wire    [31:0]  dut_mem0    ;
wire    [31:0]  dut_mem1    ;
wire    [31:0]  dut_mem2    ;
wire    [31:0]  dut_mem3    ;
wire    [31:0]  dut_mem4    ;
wire    [31:0]  dut_mem5    ;
wire    [31:0]  dut_mem6    ;
wire    [31:0]  dut_mem7    ;
wire    [31:0]  dut_mem8    ;
wire    [31:0]  dut_mem9    ;
wire    [31:0]  dut_mem10   ;
wire    [31:0]  dut_mem11   ;
wire    [31:0]  dut_mem12   ;
wire    [31:0]  dut_mem13   ;
wire    [31:0]  dut_mem14   ;
wire    [31:0]  dut_mem15   ;


assign  dbg_addr    = 32'h5b8;
assign  ref_dbg0    = ref_mem[dbg_addr + 0];
assign  ref_dbg1    = ref_mem[dbg_addr + 1];
assign  ref_dbg2    = ref_mem[dbg_addr + 2];
assign  ref_dbg3    = ref_mem[dbg_addr + 3];
assign  dut_dbg     = `MEM_PATH.mem[dbg_addr>>2];

assign  ref_mem0 = ref_mem[0];
assign  ref_mem1 = ref_mem[1];
assign  ref_mem2 = ref_mem[2];
assign  ref_mem3 = ref_mem[3];
assign  ref_mem4 = ref_mem[4];
assign  ref_mem5 = ref_mem[5];
assign  ref_mem6 = ref_mem[6];
assign  ref_mem7 = ref_mem[7];
assign  ref_mem8 = ref_mem[8];
assign  ref_mem9 = ref_mem[9];
assign  ref_mem10= ref_mem[10];
assign  ref_mem11= ref_mem[11];

assign  dut_mem0 = `MEM_PATH.mem[0];
assign  dut_mem1 = `MEM_PATH.mem[1];
assign  dut_mem2 = `MEM_PATH.mem[2];
assign  dut_mem3 = `MEM_PATH.mem[3];
assign  dut_mem4 = `MEM_PATH.mem[4];
assign  dut_mem5 = `MEM_PATH.mem[5];
assign  dut_mem6 = `MEM_PATH.mem[6];
assign  dut_mem7 = `MEM_PATH.mem[7];
assign  dut_mem8 = `MEM_PATH.mem[8];
assign  dut_mem9 = `MEM_PATH.mem[9];
assign  dut_mem10= `MEM_PATH.mem[10];
assign  dut_mem11= `MEM_PATH.mem[11];
assign  dut_mem12= `MEM_PATH.mem[12];
assign  dut_mem13= `MEM_PATH.mem[13];
assign  dut_mem14= `MEM_PATH.mem[14];
assign  dut_mem15= `MEM_PATH.mem[15];



assign	#1 hready	= hreadyout;
assign	hprot		= 4'b1110;

wire	[31:0]	hrdata_i	;
reg		[31:0]	haddr_i		;
reg				hsel_i		;
reg		[2:0]	hburst_i	;
reg		[1:0]	htrans_i	;
reg     [2:0]   hsize_i     ;
reg             hwrite_i    ;
reg     [31:0]  hwdata_i    ;

assign	#1 hrdata_i	= hrdata;
assign	#1 hsel		= hsel_i;
assign	#1 haddr	= haddr_i;
assign	#1 hburst	= hburst_i;
assign	#1 htrans	= htrans_i;
assign	#1 hsize	= hsize_i;
assign	#1 hwrite	= hwrite_i;
assign	#1 hwdata	= hwdata_i;



reg		[31:0]	rand0		;
reg		[31:0]	rand1		;
reg		[31:0]	rand2		;
reg     [31:0]  rand3       ;
reg		[7:0]	wait_cnt	;
integer         test_cnt	;
reg		[31:0]	addr		;
reg     [31:0]  hwdata_pre  ;               //1T pre of hwdata

//--- burst info
reg             skip_info_gen;
reg     [mem_abit+2-1:0]    bt_addr;        //byte addr
reg     [1:0]   bt_size     ;               //0:8b; 1:16b; 2:32b
reg     [4:0]   bt_len      ;
reg             bt_wrap     ;               //0: incr; 1:wrap
reg     [31:0]  bt_end_addr ;
reg     [mem_abit+2-1:0]    bt_addr_array [0:15];  //store all the addr of a burst
reg     [mem_abit+2-1:0]    inc_bt_addr ;
reg     [2:0]   addr_step   ;
reg     [2:0]   addr_wrap_bloc;
reg     [4:0]   addr_lcnt   ;
integer         acnt        ;
integer         rcnt        ;
integer         wcnt        ;

//--- debug purpose
wire    [mem_abit+2-1:0]    dbg_addr_array_0;
wire    [mem_abit+2-1:0]    dbg_addr_array_1;
wire    [mem_abit+2-1:0]    dbg_addr_array_2;
wire    [mem_abit+2-1:0]    dbg_addr_array_3;
wire    [mem_abit+2-1:0]    dbg_addr_array_4;
wire    [mem_abit+2-1:0]    dbg_addr_array_5;
wire    [mem_abit+2-1:0]    dbg_addr_array_6;
wire    [mem_abit+2-1:0]    dbg_addr_array_7;
wire    [mem_abit+2-1:0]    dbg_addr_array_8;
wire    [mem_abit+2-1:0]    dbg_addr_array_9;
wire    [mem_abit+2-1:0]    dbg_addr_array_10;
wire    [mem_abit+2-1:0]    dbg_addr_array_11;
wire    [mem_abit+2-1:0]    dbg_addr_array_12;
wire    [mem_abit+2-1:0]    dbg_addr_array_13;
wire    [mem_abit+2-1:0]    dbg_addr_array_14;
wire    [mem_abit+2-1:0]    dbg_addr_array_15;

assign  dbg_addr_array_0 = bt_addr_array[0];
assign  dbg_addr_array_1 = bt_addr_array[1];
assign  dbg_addr_array_2 = bt_addr_array[2];
assign  dbg_addr_array_3 = bt_addr_array[3];
assign  dbg_addr_array_4 = bt_addr_array[4];
assign  dbg_addr_array_5 = bt_addr_array[5];
assign  dbg_addr_array_6 = bt_addr_array[6];
assign  dbg_addr_array_7 = bt_addr_array[7];
assign  dbg_addr_array_8 = bt_addr_array[8];
assign  dbg_addr_array_9 = bt_addr_array[9];
assign  dbg_addr_array_10= bt_addr_array[10];
assign  dbg_addr_array_11= bt_addr_array[11];
assign  dbg_addr_array_12= bt_addr_array[12];
assign  dbg_addr_array_13= bt_addr_array[13];
assign  dbg_addr_array_14= bt_addr_array[14];
assign  dbg_addr_array_15= bt_addr_array[15];


task bt_info_gen;
reg     [31:0]  addr_mask;
begin
    rand1   = $random;
    if(rand1[7:0] <= 128)
        bt_size = 'd2;
    else
        bt_size = {1'b0, rand1[5]};

    addr_step   = 2**bt_size;


    if(rand1[15:8] <= (128 + 64 + 32))  begin //4/8/16  
        case(rand1[11:10])
            'd0:    bt_len  = 'd4;
            'd1:    bt_len  = 'd8;
            default:bt_len  = 'd16; 
        endcase

        bt_wrap = rand1[9];
    end else begin
        if(rand1[15:8] <= (128 + 64 + 32 + 16)) //single
            bt_len = 1;
        else
            bt_len = rand1[12:9];               //incr

        bt_wrap = 1'b0;
    end

    if(bt_wrap)
        addr_wrap_bloc = bt_size + $clog2(bt_len);
    else
        addr_wrap_bloc = 8;                     //incr burst, no use of this value

    //addr
    bt_addr = $random;
    if(bt_size == 1)
        bt_addr[0] = 1'b0;
    else if(bt_size == 2)
        bt_addr[1:0] = 2'd0;    

    //1K boundary check
    bt_end_addr = bt_addr + addr_step*bt_len;
    if((bt_end_addr[10] != bt_addr[10]) && (bt_end_addr[9:0] != 'd0))  begin //corss 1KB boundary
        bt_addr = {bt_end_addr[mem_abit+2-1 : 10], 10'h0} - (2**bt_size)*bt_len;
    end

    inc_bt_addr = bt_addr;
    addr_lcnt   = 0;
    bt_addr_array[0] = inc_bt_addr;
    
    for(acnt=1; acnt<bt_len; acnt=acnt+1) begin
        inc_bt_addr = inc_bt_addr + addr_step;

        if( (inc_bt_addr[addr_wrap_bloc] != bt_addr[addr_wrap_bloc]) && bt_wrap) begin //need wrap
            addr_mask   = ~( (1<<addr_wrap_bloc)-1 );            
            inc_bt_addr = bt_addr & addr_mask;
            addr_lcnt   = 1;
        end else begin
            addr_lcnt   = addr_lcnt + 'd1;
        end
    
        bt_addr_array[acnt] = inc_bt_addr;
        //#0.1;
    end

end
endtask

always @(*) begin
    hsize_i = bt_size;

	if(bt_len== 4)
		hburst_i = {2'b01, ~bt_wrap};
    else if(bt_len == 8)
		hburst_i = {2'b10, ~bt_wrap};
	else if(bt_len == 16)
		hburst_i = {2'b11, ~bt_wrap};
	else if(bt_len == 1)
        hburst_i = 'd0;
    else
		hburst_i = 3'h1;
end


task bt_busy_trans;
reg             has_busy    ;
reg     [2:0]   busy_cyc    ;
begin
    rand3 = $random % 15;
    rand2 = $random % 128;
    if(rand3[3:0] >= 12) begin
        has_busy = 1;
        
        if(rand2[2:0] <= 4)
            busy_cyc = 1;
        else if(rand2[2:0] == (4+1))
            busy_cyc = 2;
        else if(rand2[2:0] == 6)
            busy_cyc = 3;
        else
            busy_cyc = {1'b1, rand2[6:5]};
    end else begin
        has_busy = 0;
    end

    if(has_busy) begin
        while(busy_cyc != 0) begin
            htrans_i = 'd1;
            @(posedge clk);
            while(!hready) begin
	    		@(posedge clk);
    		end
            busy_cyc = busy_cyc - 1;
        end
    end

end
endtask

task ahb_rd_burst;
reg     [31:0]  ref_data[0:15];
reg     [31:0]  ref_addr;
reg     [31:0]  tmp_data;

begin
    repeat(bt_wait) @(posedge clk);

    //--- generate burst info
    if(!skip_info_gen)
        bt_info_gen;

    hwrite_i = 1'b0;
    //--- send out each beat
	for(rcnt=0; rcnt< bt_len; rcnt=rcnt+1) begin

        haddr_i = bt_addr_array[rcnt];

        if((rcnt != 0)) begin
            //--- insert busy trans
            bt_busy_trans;
        end

		if(rcnt == 0)
			htrans_i = 2'h2;
		else
			htrans_i = 2'h3;
        
		@(posedge clk);
		while(!hready) begin
			@(posedge clk);
		end

        //-- always check for 32b data
        ref_addr    = (haddr_i >> 2) << 2;
        tmp_data[8*0 +: 8] = ref_mem[ref_addr + 0];
        tmp_data[8*1 +: 8] = ref_mem[ref_addr + 1];
        tmp_data[8*2 +: 8] = ref_mem[ref_addr + 2];
        tmp_data[8*3 +: 8] = ref_mem[ref_addr + 3];
        
        ref_data[rcnt] = tmp_data;
	end
	
	htrans_i = 2'h0;
end
endtask


task ahb_write_burst;
reg     [2:0]   bcnt    ;   //byte wcnt
reg     [31:0]  waddr   ;
reg     [7:0]   bt_wdata[0 : (16*4-1)];
reg     [31:0]  bus_addr_align;
reg     [7:0]   bus_wbyte[0:3];
integer         out_idx;
reg     [1:0]   byte_sf ;
begin

    repeat(bt_wait) @(posedge clk);
    //--- generate burst info
    if(!skip_info_gen)
        bt_info_gen;

    hwrite_i = 1'b1;
    //-- generate wdata of the whole burst
    out_idx = 0;
    for(wcnt=0; wcnt< bt_len; wcnt=wcnt+1) begin
        for(bcnt=0; bcnt<(2**bt_size); bcnt=bcnt+1) begin
            bt_wdata[out_idx] = $random;
            out_idx = out_idx + 1;
        end
    end

    //--- send out each beat
    out_idx = 0;
	for(wcnt=0; wcnt< bt_len; wcnt=wcnt+1) begin
        haddr_i         = bt_addr_array[wcnt];
        
        for(bcnt=0; bcnt<(2**bt_size); bcnt=bcnt+1) begin
            bus_wbyte[bcnt] = bt_wdata[out_idx];
            out_idx = out_idx + 1;
        end

        //-- put bus_wbyte to the right byte lane
        case(bt_size)
        'd0:    begin
                    case(bt_addr_array[wcnt][1:0])
                    'd0:    hwdata_pre = {24'hf0f0f0, bus_wbyte[0]};
                    'd1:    hwdata_pre = {16'hf0f0, bus_wbyte[0], 8'hf0};
                    'd2:    hwdata_pre = {8'hf0, bus_wbyte[0], 16'h0};
                    'd3:    hwdata_pre = {bus_wbyte[0], 24'h0};
                    endcase
                end

        'd1:    begin
                    if(bt_addr_array[wcnt][1])
                        hwdata_pre = {bus_wbyte[1], bus_wbyte[0], 16'h0f0f};
                    else
                        hwdata_pre = {16'h0f0f, bus_wbyte[1], bus_wbyte[0]};
                end

        default:begin
                    hwdata_pre = {bus_wbyte[3], bus_wbyte[2], bus_wbyte[1], bus_wbyte[0]};
                end
        endcase


        if((wcnt != 0)) begin
            //--- insert busy trans
            bt_busy_trans;
        end

        if(wcnt == 0)
			htrans_i = 2'h2;
		else
			htrans_i = 2'h3;
        
		@(posedge clk);
		while(!hready) begin
			@(posedge clk);
		end
    end

    //--- copy burst write data to ref_mem
    out_idx = 0;
    for(wcnt=0; wcnt< bt_len; wcnt=wcnt+1) begin
        waddr   = bt_addr_array[wcnt];
        for(bcnt=0; bcnt<(2**bt_size); bcnt=bcnt+1) begin
            ref_mem[waddr] = bt_wdata[out_idx];
            waddr   = waddr + 1;
            out_idx = out_idx + 1;
        end
    end

    htrans_i = 2'h0;
end
endtask


task mem_content_chk;
reg     [31:0]  cnt ;
reg     [7:0]   ref_byte[0:3];
reg     [31:0]  ref ;
reg     [31:0]  dut ;

begin
    for(cnt=0; cnt<mem_depth; cnt=cnt+4) begin
        ref_byte[0] = ref_mem[(cnt<<2) + 0];
        ref_byte[1] = ref_mem[(cnt<<2) + 1];
        ref_byte[2] = ref_mem[(cnt<<2) + 2];
        ref_byte[3] = ref_mem[(cnt<<2) + 3];

        ref = {ref_byte[3], ref_byte[2], ref_byte[1], ref_byte[0]};
        dut = `MEM_PATH.mem[cnt];

        
        if(ref !== dut) begin
            $display("Error: AHB SRAM content error at %8x: DUT is %8x, should be %8x.", (cnt<<2), dut, ref);
            repeat(2) @(posedge clk);
            $finish();
        end
    end
end
endtask

reg     [31:0]      haddr_r         ;
wire                bus_fir_beat    ;
reg                 bus_fir_beat_r  ;   //1T delay
wire                bus_read        ;
wire                bus_write       ;
reg                 bus_read_r      ;
reg     [7:0]       ref_rbyte [0:3] ;
reg     [31:0]      ref_rdata       ;
wire    [31:0]      haddr_r_align   ;


assign  bus_fir_beat    = hsel & hready & (htrans == 'd2);
assign  bus_read        = hsel & hready & (htrans[1]) & (!hwrite);
assign  bus_write       = hsel & hready & (htrans[1]) & hwrite;
assign  haddr_r_align   = (haddr_r >> 2) << 2;

always @(posedge clk or negedge rstn)
if(!rstn)
    hwdata_i    <= 'd0;
else if(bus_write)
    hwdata_i    <= hwdata_pre;

always @(posedge clk or negedge rstn)
if(!rstn) begin
    bus_read_r  <= #1 1'b0;
    haddr_r     <= #1 'd0;
end else if(bus_read) begin     //read addr phase
    bus_read_r  <= #1 1'b1;
    haddr_r     <= #1 haddr;
end else if(hready) begin
    bus_read_r  <= #1 1'b0;
end

//--- check read out data
always @(posedge clk or negedge rstn)
if(!rstn) begin
    
end else begin
    if(bus_read_r && hready) begin  //read data phase
        ref_rbyte[0]= ref_mem[haddr_r_align + 0];
        ref_rbyte[1]= ref_mem[haddr_r_align + 1];
        ref_rbyte[2]= ref_mem[haddr_r_align + 2];
        ref_rbyte[3]= ref_mem[haddr_r_align + 3];
        ref_rdata   = {ref_rbyte[3], ref_rbyte[2], ref_rbyte[1], ref_rbyte[0]};
        
        if(ref_rdata !== hrdata_i) begin
            $display("Error: AHB read error at %8x: DUT is %8x, should be %8x.", haddr_r, hrdata_i, ref_rdata);
            repeat(2) @(posedge clk);
            $finish();
        end
    end
end

//--- 2: send out AHB burst ---//
reg		[31:0]	ini_addr	;
reg		[31:0]	ini_data	;
integer         l0, l1      ;
reg     [31:0]  addr_wrap_back;
reg     [15:0]  rw_rand     ;
wire    [31:0]  max_test    ;

assign  max_test = (1<<14);

initial begin
    #1;
    bt_wait = 'd1;
	hsel_i	= 1'b0;
	haddr_i	= 32'h0;
	hburst_i= 3'h0;
	htrans_i= 2'h0;
	@(posedge rstn);
	hsel_i	= 1'b1;

    //--- initial SRAM with random value
	for(ini_addr=0; ini_addr<mem_depth; ini_addr=ini_addr+1) begin
		ini_data    = $random;
        
        `MEM_PATH.mem[ini_addr] = ini_data;
        ref_mem[(ini_addr << 2) + 0] = ini_data[8*0 +: 8];
        ref_mem[(ini_addr << 2) + 1] = ini_data[8*1 +: 8];
        ref_mem[(ini_addr << 2) + 2] = ini_data[8*2 +: 8];
        ref_mem[(ini_addr << 2) + 3] = ini_data[8*3 +: 8];
	end

	repeat(2) @(posedge clk);

    skip_info_gen = 1;

    //-- t0: addr = 0, r/w
    bt_addr = 0; bt_size = 2; bt_len = 8; bt_wrap = 0;
    for(l0 =0; l0<bt_len; l0=l0+1) begin
        bt_addr_array[l0] = bt_addr + 4*l0;
    end
    ahb_rd_burst;
    ahb_write_burst;

    //-- t1: addr = max r/w
    bt_addr = (mem_depth-1)*4; bt_size = 2; bt_len = 16; bt_wrap = 1;
    //-- beat_0
    bt_addr_array[0] = bt_addr;
    addr_wrap_back = (mem_depth - bt_len)*4;

    //-- beat_1~15
    for(l0 =0; l0<(bt_len-1); l0=l0+1) begin
        bt_addr_array[l0+1] = addr_wrap_back + 4*l0;
    end

    ahb_rd_burst;
    ahb_write_burst;

    skip_info_gen = 0;

    for(test_cnt=0; test_cnt< max_test; test_cnt=test_cnt + 1) begin
        rw_rand = $random;

        if(rw_rand[15:8] < 64)
            bt_wait = 'd0;
        else if(rw_rand[15:8] < (64 + 16))
            bt_wait = 'd1;
        else if(rw_rand[15:8] < (64 + 16 + 16))
            bt_wait = 'd2;
        else if(rw_rand[15:8] < (64 + 16 + 16 + 16))
            bt_wait = 'd3;
        else if(rw_rand[15:8] < (64 + 16 + 16 + 16 + 8))
            bt_wait = 'd4;
        else
            bt_wait = rw_rand[4:0];

        `ifndef  EN_BAKC2BACK
        if(bt_wait == 0)
            bt_wait = 1;
        `endif
        

        if(test_cnt < (max_test >> 1)) begin    //read dominate
            if(rw_rand[5:0] < 48)
                ahb_rd_burst;
            else
                ahb_write_burst;
        end else begin                          //wirte dominate
            if(rw_rand[5:0] >= 16)
                ahb_write_burst;
            else
                ahb_rd_burst;
        end
    end

    
    repeat(20) @(posedge clk);

    $display("OK: sim pass.");
    $finish();
end


//--- check mem content at the beginning of each burst ---//
always @(posedge clk or negedge rstn)
if(!rstn)
    bus_fir_beat_r  <= 1'b0;
else
    bus_fir_beat_r  <= bus_fir_beat;


always @(posedge clk or negedge rstn)
if(!rstn)
    bus_rd_dph  <= 1'b0;
else if(bus_read)
    bus_rd_dph  <= 1'b1;
else if(hready)
    bus_rd_dph  <= 1'b0;

always @(negedge clk or negedge rstn)
if(!rstn) begin
`ifdef EN_BAKC2BACK
end else if(bus_fir_beat_r && bus_rd_dph) begin
`else
end else if(bus_fir_beat) begin
`endif
    mem_content_chk;
end



endmodule

