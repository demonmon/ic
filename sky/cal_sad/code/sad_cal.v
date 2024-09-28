module sad_cal (
  clk,
  rstn,
  din ,
  refi,
  cal_en,

 sad,
 sad_vld,
);
parameter  DWIDTH = 8;
input  wire  clk,rstn;
input  wire  [16*16*DWIDTH - 1 : 0] din,refi;
input  wire  cal_en;
output reg   sad_vld;
output reg  [8+DWIDTH-1:0] sad;

reg  [4:0] cal_en_d;
// 0---
always @(posedge clk or negedge rstn) begin
  if(~rstn) begin
    cal_en_d <= 1'b0;
  end
  else 
    cal_en_d <= {cal_en_d[3:0],cal_en};
end

wire [DWIDTH-1 : 0] din_array [15:0] [15:0];
wire [DWIDTH-1 : 0] refi_array[15:0] [15:0];

//转化成数组
generate
  genvar i,j;
  for(j=0;j<=15;j=j+1) begin : gen_array_out
    for (i = 0; i<=15 ; i=i+1 ) begin : gen_array_in
      assign din_array[j][i] = din[(j*16*DWIDTH + i*DWIDTH) +: DWIDTH] ;
      assign refi_array[j][i] = refi[(j*16*DWIDTH + i*DWIDTH) +: DWIDTH] ;
    end
  end
endgenerate



// 1--sub

reg [DWIDTH:0] sub [15:0][15:0];


generate
  genvar y ,x ;
  for ( y = 0; y<=15 ; y=y+1 ) begin : gen_sub_y
    for ( x = 0 ; x<=15 ; x=x+1 ) begin : gen_sub_x
        always @(posedge clk or negedge rstn) begin
          if(~rstn) sub[y][x] <= 'b0;
          else if (cal_en) 
            sub[y][x] <= {1'b0,din_array[y][x]} - {1'b0,refi_array[y][x]};
        end
    end
  end
endgenerate

//2-abs
reg [DWIDTH-1:0] abs [15:0][15:0];
generate
  genvar abs_y,abs_x;
  for (abs_y = 0 ;abs_y <=15 ; abs_y=abs_y+1 ) begin : gen_abs_y
    for ( abs_x = 0 ;abs_x <=15 ; abs_x = abs_x+1) begin :gen_abs_x
       always @(posedge clk or negedge rstn) begin
         if (~rstn) begin
           abs[abs_y][abs_x] <= 'b0;
         end
         else if(cal_en_d[0]) begin
           if (sub[abs_y][abs_x][DWIDTH]) begin
             abs[abs_y][abs_x] <= ~sub[abs_y][abs_x][DWIDTH-1:0] + 'b1;
           end
           else
            abs[abs_y][abs_x] <= sub[abs_y][abs_x][DWIDTH-1:0];
         end
       end
    end
  end
endgenerate

//3--16*16-->16*4
reg [DWIDTH+1: 0] acc_16_4[15:0][3:0];
generate
  genvar y0,x0;
  for (y0 = 0 ; y0<=15 ; y0=y0+1 ) begin: acc0_y
    for ( x0 = 0 ; x0<=3 ; x0=x0+1 ) begin : acc0_x
      always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
          acc_16_4[y0][x0] <= 'b0;
        end
        else if(cal_en_d[1])
          acc_16_4[y0][x0] <= {2'b0,abs[y0][4*x0]}+{2'b0,abs[y0][4*x0+1]}
                              +{2'b0,abs[y0][4*x0+2]}+{2'b0,abs[y0][4*x0+3]};
      end
    end
  end
endgenerate

//4---16*4-->4*4
reg [DWIDTH+3: 0] acc_4_4[3:0][3:0];
generate
  genvar y1,x1;
  for (y1 = 0 ; y1<=3 ; y1=y1+1 ) begin: acc1_y
    for ( x1 = 0 ; x1<=3 ; x1=x1+1 ) begin : acc1_x
      always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
          acc_4_4[y1][x1] <= 'b0;
        end
        else if (cal_en_d[2])
          acc_4_4[y1][x1] <= {2'b0,acc_16_4[4*y1][x1]}+{2'b0,acc_16_4[4*y1+1][x1]}
                             +{2'b0,acc_16_4[4*y1+2][x1]}+{2'b0,acc_16_4[4*y1+3][x1]};
      end
    end
  end
endgenerate

//5-----4*4---->4*1
reg [DWIDTH+5: 0] acc_4_1[3:0];
generate
  genvar y2;
  for (y2 = 0 ; y2<=3 ; y2=y2+1 ) begin: acc2_y
      always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
          acc_4_1[y2] <= 'b0;
        end
        else if (cal_en_d[3])
          acc_4_1[y2] <= {2'b0,acc_4_4[y2][0]}+{2'b0,acc_4_4[y2][1]}
                        +{2'b0,acc_4_4[y2][2]}+{2'b0,acc_4_4[y2][3]};
      end
    end
  
endgenerate
//6---4*1-->1*1

always @(posedge clk or negedge rstn) begin
  if (~rstn) begin
    sad<= 'b0;
  end
  else if(cal_en_d[4]) 
    sad <= {2'b0,acc_4_1[0]}+{2'b0,acc_4_1[1]}
           +{2'b0,acc_4_1[2]}+{2'b0,acc_4_1[3]};
end
 
//out
always @(posedge clk or negedge rstn) begin
  if (~rstn) begin
    sad_vld<=1'b0;
  end
  else
    sad_vld <= cal_en_d[4];
end


endmodule //sad_cal