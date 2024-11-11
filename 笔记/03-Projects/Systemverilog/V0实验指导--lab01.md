---
title: V0实验指导--lab01
updated: 2022-04-22T16:00:23
created: 2022-04-22T14:23:14
---

Lab1
**关于test**
理解repeat(15) @(rtr_io.cb);
首先是概念的理解。这里给出一个实例
clocking dram @(posedge phi1);
inout data;
output negedge #1 address;
endclocking
时钟的上升沿表示为
@(dram); 等于 @(posedge phi1)
测试平台可以使用@rtr_io.cb来等待时钟，而省略了时钟的边沿。这里其实可以理解@rtr_io.cb的作用为向前推进仿真时间到一个时钟的上升沿。
我们可以进行下面几个测试实例来理解该功能。这里的系统时钟周期为100ns，时间单位为1ns，时钟无shew，默认时钟起始电平为低
测试程序首先修改为如下，先将仿真时间向前推进五个时钟周期,然后对相关变量进行赋值，注意这里的赋值方式。对于异步，进行阻塞赋值，同步的信号，或者是想要进行同步的信号，使用非阻塞赋值。
文件test.sv如下

/\`timescale 1ns/100ps
program automatic test(router_io.TB rtr_io);
 initial begin
  //$vcdpluson; //don't need in questasim enviroment
 reset();
 end
task reset();
 repeat(5) @(rtr_io.cb);
 rtr_io.reset_n = 1'b0;
 rtr_io.cb.frame_n \<= '1;
 rtr_io.cb.valid_n \<= '1;
 #95 rtr_io.cb.reset_n \<= 1'b1;
 repeat(5) @(rtr_io.cb);//将仿真时间向前推进一个时钟上升沿。这里重复十次
endtask: reset
endprogram: test
该对应波形为：
![image1](image1-15.png)
分析波形来看，首先时钟推进了5个上升沿。这之前所有接口的变量均为X态。信号都是logic类型，它是4值变量，初始态为x。当第五个上升沿到来之后，开始对信号进行赋值。执行rtr_io.reset_n = 1'b0;由于恰好是上沿，执行rtr_io.cb.frame_n \<= '1;rtr_io.cb.valid_n \<= '1;然后延时95ns，由于这时不是上升沿，不会执行赋值，然后继续执行下一个命令（repeat(5) @(rtr_io.cb);）：仿真再向前推进5个时钟周期，在第一个上升沿对reset_n进行拉高操作。因为此时的restn是同步的，因为通过cb时钟块索引（只有上升沿才赋值），一共有十个上升沿。
接下来将赋值延时时间修改为105ns
得到的仿真图如下

task reset();
 rtr_io.reset_n = 1'b0;//此时是异步复位
 rtr_io.cb.frame_n \<= '1;//也是在时钟上升沿赋值
 rtr_io.cb.valid_n \<= '1;//同步。。
 #2 rtr_io.cb.reset_n \<= 1'b1;同步释放（和时钟上升沿）
 repeat(15) @(rtr_io.cb); 总共仿真15个上升沿
endtask: reset
仿真波形图如图：
![image2](image2-12.png)

rtr_io.reset_n在0时刻复位 而rtr_io.reset_n，rtr_io.cb.valid_n需要在时钟上升沿赋值，因为.cb说明是时钟块中，在时钟块中是同步信号。
TOP文件中的$timeformat
$timeformat(-9, 1, “ns”, 10);
$timeformat的语法如下：

$timeformat(units_number, precision_number, uffix_string, minimum_field_wdith);

**units_number** 是 0 到-15 之间的整数值，**表示打印的时间值的单位**：0 表示秒，-3 表示毫秒，-6 表示微秒，-9 表示纳秒， -12 表示皮秒， -15 表示飞秒；中间值也可以使用：例如-10表示以100ps为单位。其默认值为**\`timescalse**所设置的仿真时间单位。
**precision_number** 是在打印时间值时，**小数点后保留的位数**。其默认值为0。
**suffix_string** 是在时间值后面打印的一个后缀字符串。其默认值为空字符串。
**MinFieldWidth** 是时间值字符串与后缀字符串合起来的这部分字符串的最小长度，若这部分字符串不足这个长度，则在这部分字符串之前补空格。其默认值为20。
举例：
时间值单位为ns 小数点保留位数为1位 后缀字符串位ns 时间值＋后缀字符串最小长度为10
**$timeformat不会更改\`timescale设置的的时间单位与精度，它只是更改了$write、$display、$strobe、$monitor、$fwrite、$fdisplay、$fstrobe、$fmonitor等任务在%t格式下显示时间的方式。**

lab1中添加了输入输出延时 ：default input # 1ns output # 1ns;
**

![image3](image3-11.png)
去除

input # 1ns 指的是采样时间相对时钟上升沿提前1ns，但不在波形上显示。用来模拟真实电路中的建立时间。 output # 1ns指的是驱动时间相对时钟上升沿推后1ns，会在波形上显示出来。用来模拟真实电路中的传播延时。

![image4](image4-9.png)

**输出显示出来一个相对时钟上升沿1ns的延时驱动**

