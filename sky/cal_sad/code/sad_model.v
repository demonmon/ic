module sad_model (
  clk,
  rstn,

  din ,
  refi,
  cal_en,

  sad,
  sad_vld,
);
parameter  DWIDTH = 8;
parameter  PIPE_STAGE = 5;

input  wire  clk,rstn;
input  wire  [16*16*DWIDTH - 1 : 0] din,refi;
input  wire  cal_en;
output wire   sad_vld;
output wire [8+DWIDTH-1:0] sad;

integer cnt ;

wire [DWIDTH : 0] diff [255:0];
wire [DWIDTH-1 : 0] abs_val [255:0];
reg [DWIDTH+8-1 : 0] acc;

generate
  genvar i;
  for ( i=0 ; i <= 255 ; i=i+1 ) begin
    assign  diff[i] = {1'b0,din[i*DWIDTH +: DWIDTH]} - {1'b0,refi[i*DWIDTH +: DWIDTH]} ;
    assign  abs_val[i] = (diff[i][DWIDTH]) ? (~{diff[i][DWIDTH-1:0]}+1) : diff[i][DWIDTH-1:0] ;
  end
endgenerate


always @(*) begin
  if (cal_en) begin
    for ( cnt = 0 ; cnt <= 255 ; cnt = cnt +1 ) begin
      if(cnt == 0) 
        acc = abs_val[cnt];  //初值
      else
        acc = acc + abs_val[cnt];//计算求和
    end
  end
  else
    acc = 0;    
end
reg [DWIDTH+7 : 0] acc_d [PIPE_STAGE:0];
reg              cal_en_d [PIPE_STAGE:0];

generate
  genvar j;
  for ( j=0 ; j<=PIPE_STAGE ; j=j+1 ) begin
    if (j == 0) begin
      always @(posedge clk or negedge rstn) begin
        if(~rstn) begin
          acc_d[j] <= 'd0;
          cal_en_d[j] <= 'd0;
        end
        else begin
          acc_d[j] <= acc;
          cal_en_d[j] <= cal_en;
        end    
      end
    end
    else begin
      always @(posedge clk or negedge rstn) begin
        if(~rstn) begin
          acc_d[j] <= 'd0;
          cal_en_d[j] <= 'd0;
        end
        else begin
          acc_d[j] <= acc_d[j-1];
          cal_en_d[j] <= cal_en_d[j-1];
        end
      end
    end

  end

  assign sad_vld = cal_en_d[PIPE_STAGE];
  assign sad = acc_d[PIPE_STAGE];




endgenerate







endmodule //sad_model