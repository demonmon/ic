# 系统任务
## 监控任务 
监控任务 -- $monitor 连续监控指定参数--只要参数表中参数值发生变化。参数表中就在当前时刻结束时显示
参数可以是$time系统函数 
例如：对D clk Q进行监控
```verilog
$monitor("At%t,D=%d,clk=%d",$time,D,clk,"and Q is %d",Q);
```
![[Pasted image 20220609222651.png]]

$monitoroff--停止监控任务
$monitoron--启动监控任务
$monitor往往在initial语句中调用
仿真控制任务 ：$finish $stop
![[Pasted image 20220609223001.png]]
## 文件输出任务
$readmemb : 读取二进制格式数
$readmemh :  
格式如下：
> $readmemb ("<数据文件名>"，<存储器名>，<起始地址>，<结束地址>) 

其中起始地址 结束地址是可选项 如果没有则从存储器最低位开始加载数据直到最高位。
如果有，从起始地址到结束地址
```verilog
reg [7:0] mem [256:1];

initial $readmemh("mem.dat",mem);
initial $readmemh("mem.dat",mem,16);
initial $readmemh("mem.dat",mem,128,1);

```

![[Pasted image 20220609224036.png]]

## 仿真输出任务


## 仿真时间函数
仿真时间函数 
$time 返回64位整型时间
$realtime 返回实型时间 
![[Pasted image 20220609224116.png]]

![[Pasted image 20220609224449.png]]

![[Pasted image 20220609224507.png]]

## 随机函数
```verilog
$random%b   //(b-1) ~b-1

reg [23:0] rand ;
rand = $random%60 //-59~59
rand = {$random}%60 //0~59
   
```




