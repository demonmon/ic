module glitch_free (
	input clk0,    // Clock
	input clk1,
	input select,
	input rst_n,  // Asynchronous reset active low
	
	output clkout
);
 
	wire mid_clk0;
	reg mid_clk0_r1, mid_clk0_r2, mid_clk0_r2n;
	wire mid_clk1;
	reg mid_clk1_r1, mid_clk1_r2, mid_clk1_r2n;
 
	assign mid_clk1 = select & mid_clk0_r2n;
 
	assign mid_clk0 = ~select & mid_clk1_r2n;
 
	
	//第一级触发器用上升沿采样，选择信号与反馈信号的与运算
	always@(posedge clk1 or negedge rst_n) begin
		if(~rst_n) mid_clk1_r1 <= 0;
		else mid_clk1_r1 <= mid_clk1;
	end
 
	//第二级触发器用下降沿采样
	always@(negedge clk1 or negedge rst_n) begin
		if(~rst_n) begin
			mid_clk1_r2 <= 0;
			mid_clk1_r2n <= 1;
		end
		else begin
			mid_clk1_r2 <= mid_clk1_r1;
			mid_clk1_r2n <= ~mid_clk1_r1;
		end
	end
 
 
	//第一级触发器用上升沿采样，选择信号与反馈信号的与运算
	always@(posedge clk0 or negedge rst_n) begin
		if(~rst_n) mid_clk0_r1 <= 0;
		else mid_clk0_r1 <= mid_clk0;
	end
 
	//第二级触发器用下降沿采样
	always@(negedge clk0 or negedge rst_n) begin
		if(~rst_n) begin
			mid_clk0_r2 <= 0;
			mid_clk0_r2n <= 1;
		end
		else begin
			mid_clk0_r2 <= mid_clk0_r1;
			mid_clk0_r2n <= ~mid_clk0_r1;
		end
	end
 
	wire mid_clk11, mid_clk00;
	assign mid_clk11 = clk1 & mid_clk1_r2;
	assign mid_clk00 = clk0 & mid_clk0_r2;
 
	assign clkout = mid_clk11 | mid_clk00;
 
 
 
endmodule
