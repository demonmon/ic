# 循环语句
Verilog 循环语句有 4 种类型，分别是 while，for，repeat，和 forever 循环。循环语句只能在 always 或 initial 块中使用，但可以包含延迟表达式。

**语句的顺序执行**
- 在always 模块内，按逻辑书写的顺序执行 
- 顺序语句---always 模块内的语句 
**语句的并行执行 **
- always 模块 assign 、实例元件都是**并行执行**

## for循环
for 循环语法格式如下：
>for(initial_assignment; condition ; step_assignment)  begin
   …
end


一般来说，因为初始条件和自加操作等过程都已经包含在 for 循环中，所以 for 循环写法比 while 更为紧凑，但也不是所有的情况下都能使用 for 循环来代替 while 循环。
需要注意的是，**i = i + 1 不能像 C 语言那样写成 i++ 的形式**，i = i -1 也不能写成 i -- 的形式。

```verilog
// for 循环语句  
integer      i ;  
reg [3:0]    counter2 ;  
initial begin  
    counter2 = 'b0 ;  
    for (i=0; i<=10; i=i+1) begin  
        #10 ;  
        counter2 = counter2 + 1'b1 ;  
    end  
end
```
例 可以用for循环初始化memory
![[Pasted image 20220608153300.png]]
可以实现八位二进制乘法
![[Pasted image 20220608153510.png]]

## repeat语句
连续执行一条或多条语句n次

>repeat (loop_times) begin
	 …
end

```verilog
// repeat 循环语句  
reg [3:0]    counter3 ;  
initial begin  
    counter3 = 'b0 ;  
    repeat (11) begin  //重复11次  
        #10 ;  
        counter3 = counter3 + 1'b1 ;  
    end  
end
```
## while语句
>while (condition) begin
    …
end 

while 循环中止条件为 condition 为假。
如果开始执行到 while 循环时 condition 已经为假，那么循环语句一次也不会执行
```verilog
`timescale 1ns/1ns  
   
module test ;  
   
    reg [3:0]    counter ;  
    initial begin  
        counter = 'b0 ;  
        while (counter<=10) begin  
            #10 ;  
            counter = counter + 1'b1 ;  
        end  
    end  
   
   //stop the simulation  
    always begin  
        #10 ;  if ($time >= 1000) $finish ;  
    end  
   
endmodule
```

## forever语句
不同于always语句 一般放在initial语句中

>forever begin
    …
end 

forever 语句表示永久循环，不包含任何条件表达式，一旦执行便无限的执行下去，系统函数 $finish 可退出 forever。forever 相当于 while(1) 。

通常，forever 循环是和时序控制结构配合使用的。
例如，使用 forever 语句产生一个时钟：
```verilog
reg          clk ;  
initial begin  
    clk       = 0 ;  
    forever begin  
        clk = ~clk ;  
        #5 ;  
    end  
end
```


