#抽象级
# verilog 硬件语言

抽象层次：系统级，算法级，RTL级（由上到下）
![[Pasted image 20220606144521.png]]


verilog在抽象级建模 --> 混合描述


![[Pasted image 20220606144708.png]]

![[Pasted image 20220606144843.png]]

自顶向下的结构 与 数字系统抽象层次 
系统级 --> 算法级 --> RTL级 --> 逻辑门级 --> 开关级 版图级

```verilog
assign #2 sum = a^b;
```
上面是 **不可综合**
  参数传递
  1. 利用defparam 定义参数声明语句 （不常用
   defparam  例化模块名.参数名1 = 常数表达式
   ![[Pasted image 20220606154902.png]]
2.    # 后跟参数
![[Pasted image 20220606155237.png]]

```verilog
ram #(.AW(4), .DW(4))  
    u_ram  
    (  
        .CLK    (clk),  
        .A      (a[AW-1:0]),  
        .D      (d),  
        .EN     (en),  
        .WR     (wr),    //1 for write and 0 for read  
        .Q      (q)  
     );

module  ram  
    #(  parameter       AW = 2 ,  
        parameter       DW = 3 )  
    (  
        input                   CLK ,  
        input [AW-1:0]          A ,  
        input [DW-1:0]          D ,  
        input                   EN ,  
        input                   WR ,    //1 for write and 0 for read  
        output reg [DW-1:0]     Q  
     );  
   
    reg [DW-1:0]         mem [0:(1<<AW)-1] ;  
    always @(posedge CLK) begin  
        if (EN && WR) begin  
            mem[A]  <= D ;  
        end  
        else if (EN && !WR) begin  
            Q       <= mem[A] ;  
        end  
    end  




ram #(4, 4)  
 u_ram  
   
module  ram  
    (  
        input                   CLK ,  
        input [AW-1:0]          A ,  
        input [DW-1:0]          D ,  
        input                   EN ,  
        input                   WR ,    //1 for write and 0 for read  
        output reg [DW-1:0]     Q  
     ); 
      
    parameter       AW = 2 ,  
    parameter       DW = 3  
   
    reg [DW-1:0]         mem [0:(1<<AW)-1] ;  
    always @(posedge CLK) begin  
        if (EN && WR) begin  
            mem[A]  <= D ;  
        end  
        else if (EN && !WR) begin  
            Q       <= mem[A] ;  
        end  
    end      


endmodule
```
