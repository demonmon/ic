#行为级建模

# 顺序块
顺序块用关键字 begin 和 end 来表示。
顺序块中的语句是一条条执行的。当然，非阻塞赋值除外。
顺序块中每条语句的时延总是与其前面语句执行的时间相关。
每条语句的延迟时间都是**相对于前一条语句**仿真时间而言

# 并行块
并行块有关键字 fork 和 join 来表示。（不可综合）
并行块中的语句是并行执行的，即便是阻塞形式的赋值。
并行块中每条语句的时延都是与块语句**开始执行的时间相关**。
块内每条语句的延迟时间都是相对于**程序流程控制进入到块内的时间**
当按时间排序在最后的语句执行完 或 **一个disable语句执行**时，程序流控制跳出该并行块

# 嵌套块
顺序块和并行块还可以嵌套块 


# 命名块
我们可以给块语句结构命名。
命名的块中可以声明局部变量，通过**层次名引用的方法**对变量进行访问。

```verilog
`timescale 1ns/1ns  
   
module test;  
   
    initial begin: runoob   //命名模块名字为runoob，分号不能少  
        integer    i ;       //此变量可以通过test.runoob.i 被其他模块使用  
        i = 0 ;  
        forever begin  
            #10 i = i + 10 ;        
        end  
    end  
   
    reg stop_flag ;  
    initial stop_flag = 1'b0 ;  
    always begin : detect_stop  
        if ( test.runoob.i == 100) begin //i累加10次，即100ns时停止仿真  
            $display("Now you can stop the simulation!!!");  
            stop_flag = 1'b1 ;  
        end  
        #10 ;  
    end  
   
endmodule
```
命名的块也可以被禁用，用关键字 disable 来表示。
disable 可以终止命名块的执行，可以用来从循环中退出、处理错误等。
与 C 语言中 break 类似，但是 break 只能退出当前所在循环，而 disable 可以禁用设计中任何一个命名的块。


# 结构语句

## initial语句
initial 语句从 0 时刻开始执行，只执行一次，多个 initial 块之间是相互独立的。
如果 initial 块内包含多个语句，需要使用关键字 begin 和 end 组成一个块语句。
如果 initial 块内只要一条语句，关键字 begin 和 end 可使用也可不使用。
initial 理论上来讲是不可综合的，**用于初始化、信号检测等**。

```VERILOG
initial begin  
        ai         = 0 ;  
        #25 ;      ai        = 1 ;  
        #35 ;      ai        = 0 ;        //absolute 60ns  
        #40 ;      ai        = 1 ;        //absolute 100ns  
        #10 ;      ai        = 0 ;        //absolute 110ns  
    end
```

## always语句 
与 initial 语句相反，always 语句是重复执行的。always 语句块从 0 时刻开始执行其中的行为语句；当执行完最后一条语句后，便再次执行语句块中的第一条语句，如此循环反复。
由于循环执行的特点，always 语句多用于仿真时钟的产生，信号行为的检测等。
```verilog
`timescale 1ns/1ns  
   
module test ;  
   
    parameter CLK_FREQ   = 100 ; //100MHz  
    parameter CLK_CYCLE  = 1e9 / (CLK_FREQ * 1e6) ;   //switch to ns  
   
    reg  clk ;  
    initial      clk = 1'b0 ;      //clk is initialized to "0"  
    always     # (CLK_CYCLE/2) clk = ~clk ;       //generating a real clock by reversing  
   
    always begin  
        #10;  
        if ($time >= 1000) begin  
            $finish ;  
        end  
    end  
   
endmodule
```
always 常常是综合过程最有用的语句之一，但常常是不可总综合。为了得到最好综合效果，严格按照以下模板编写。
![[Pasted image 20220607101151.png]]
时序过程：
![[Pasted image 20220607101235.png]]

**always 通常采用异步清0**，只有在时钟周期很小或清零信号为电平信号时（很容易捕捉到清0信号）采用同步清0