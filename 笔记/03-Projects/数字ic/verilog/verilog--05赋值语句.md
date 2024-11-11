# 过程赋值语句  
#行为级建模 
assign语句，用于对wire变量赋值，描述组合逻辑


# 连续赋值语句
#数据流建模
对reg进行赋值，有两种：阻塞，非阻塞

## 非阻塞赋值
非阻塞赋值属于**并行执行语句**，即下一条语句的执行和当前语句的执行是同时进行的，它不会阻塞位于同一个语句块中后面语句的执行。块结束才完成赋值
非阻塞赋值语句使用小于等于号 **<=** 作为赋值符。

## 阻塞赋值 
阻塞赋值属于**顺序执行**，即下一条语句执行前，当前语句一定会执行完毕。
阻塞赋值语句使用等号 = 作为赋值符。
前面的仿真中，initial 里面的赋值语句都是用的阻塞赋值

利用下面代码，对阻塞、非阻塞赋值进行仿真，来说明 2 种过程赋值的区别。
```verilog
`timescale 1ns/1ns  
   
module test ;  
    reg [3:0]   ai, bi ;  
    reg [3:0]   ai2, bi2 ;  
    reg [3:0]   value_blk ;  
    reg [3:0]   value_non ;  
    reg [3:0]   value_non2 ;  
   
    initial begin  
        ai            = 4'd1 ;   //(1)  
        bi            = 4'd2 ;   //(2)  
        ai2           = 4'd7 ;   //(3)  
        bi2           = 4'd8 ;   //(4)  
        #20 ;                    //(5)  
   
        //non-block-assigment with block-assignment  
        ai            = 4'd3 ;     //(6)  
        bi            = 4'd4 ;     //(7)  
        value_blk     = ai + bi ;  //(8)  
        value_non     <= ai + bi ; //(9)  
   
        //non-block-assigment itself  
        ai2           <= 4'd5 ;           //(10)  
        bi2           <= 4'd6 ;           //(11)  
        value_non2    <= ai2 + bi2 ;      //(12)  
    end  
   
   //stop the simulation  
    always begin  
        #10 ;  
        if ($time >= 1000) $finish ;  
    end  
   
endmodule

```

仿真结果如下：
语句（1）-（8）都是阻塞赋值，按照顺序执行。
20ns 之前，信号 ai，bi 值改变。由于过程赋值的特点，value_blk = ai + bi 并没有执行到，所以 20ns 之前，value_blk 值为 X（不确定状态）。
20ns 之后，信号 ai，bi 值再次改变。执行到 value_blk = ai + bi，**信号 value_blk 利用信号 ai，bi 的新值得到计算结果 7。**
语句（9）-（12）都是非阻塞赋值，并行执行。
首先，（9）-（12）虽然都是并发执行，但是执行顺序也是在（8）之后，所以信号 value_non = ai + bi 计算是也会使用信号 ai，bi 的新值，结果为 7。
其次，（10）-（12）是并发执行，**所以 value_non2 = ai2 + bi2 计算时，并不关心信号 ai2，bi2 的最新非阻塞赋值结果。** 即 value_non2 计算时使用的是信号 ai2，bi2 的旧值，结果为 4'hF。

## 使用非阻塞赋值避免竞争冒险
实际 Verilog 代码设计时，切记不要在一个过程结构中混合使用阻塞赋值与非阻塞赋值。两种赋值方式混用时，时序不容易控制，很容易得到意外的结果
更多时候，在设计电路时，**always 时序逻辑块中多用非阻塞赋值，always 组合逻辑块中多用阻塞赋值；在仿真电路时，initial 块中一般多用阻塞赋值。**

因为 2 个 always 块中的语句是同时进行的，但是 a=b 与 b=a 是无法判定执行顺序的，这就造成了竞争的局面。

但不管哪个先执行（和编译器等有关系），不考虑 timing 问题时，他们执行顺序总有先后，**最后 a 与 b 的值总是相等的。没有达到交换 2 个寄存器值的效果。**

```verilog
always @(posedge clk) begin  
    a = b ;  
end  
   
always @(posedge clk) begin  
    b = a;  
end
```
但是，如果在 always 块中使用非阻塞赋值，则可以避免上述竞争冒险的情况。
如下所示，2 个 always 块中语句并行执行，赋值操作右端操作数使用的是上一个时钟周期的旧值，此时 a<=b 与 b<=a 就可以**相互不干扰的执行，达到交换寄存器值的目的**





![[Pasted image 20220622104550.png]]

