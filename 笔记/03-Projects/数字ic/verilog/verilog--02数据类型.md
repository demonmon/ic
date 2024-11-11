#verilog
# verilog 
## 变量
变量共有19种常用的就只有三种：
网络型（nets ），寄存器型(register)，数组型(mem)
### nets型变量
始终随输入变化而变化的的变量，

![[Pasted image 20220606212447.png]]

## register变量
具有**状态保持作用**的电路元件 (触发器，寄存器)
常用于过程块语句（initial，always，task function）内指定信号

![[Pasted image 20220606212857.png]]

## reg wire
verilog 最常用的 2 种数据类型就是线网（wire）与寄存器（reg），其余类型可以理解为这两种数据类型的扩展或辅助。
### wire
wire 类型表示硬件单元之间的物理连线，由其连接的器件输出端连续驱动。如果没有驱动元件连接到 wire 型变量，缺省值一般为 "Z"。
常用assign语句赋值的**组合逻辑信号**
举例如下：
```verilog
wire   interrupt ;  
wire   flag1, flag2 ;  
wire   gnd = 1'b0 ;
```
### reg 
往往代表**触发器**，但**不一定**是触发器（也可以是组合逻辑信号）
寄存器（reg）用来表示存储单元，它会保持数据原有的值，直到被改写。
声明举例如下：
```verilog
reg rstn ;  
initial begin  
    rstn = 1'b0 ;  
    #100 ;  
    rstn = 1'b1 ;  
end
```
### 向量
当位宽大于1时，wire 或 reg 即可声明为向量的形式。例如：
```verilog
reg [3:0]      counter ;   //声明4bit位宽的寄存器counter
wire [32-1:0]  gpio_data;  //声明32bit位宽的线型变量gpio_data
```
### memmory变量--数组

![[Pasted image 20220606214152.png]]

在 Verilog 中允许声明 **reg, wire, integer, time, real 及其向量类型**的数组。
数组维数没有限制。线网数组也可以用于连接实例模块的端口。数组中的每个元素都可以作为一个标量或者向量，以同样的方式来使用，形如：<数组名>[<下标>]。对于多维数组来讲，用户需要说明其每一维的索引。例如：
```verilog
integer        flag [7:0] ; //8个整数组成的数组  
reg  [3:0]     counter [3:0] ; //由4个4bit计数器组成的数组  
wire [7:0]     addr_bus [3:0] ; //由4个8bit wire型变量组成的数组  
wire           data_bit[7:0][5:0] ; //声明1bit wire型变量的二维数组  
reg [31:0]     data_4d[11:0][3:0][3:0][255:0] ; //声明4维的32bit数据变量数组
```

**mem与reg区别**
1. 含义不同:
n位寄存器就是向量

![[Pasted image 20220606214540.png]]
2. 赋值方式不同 

![[Pasted image 20220606214556.png]]

mem赋值 ：
```verilog
lag [1]   = 32'd0 ; //将flag数组中第二个元素赋值为32bit的0值  
counter[3] = 4'hF ;  //将数组counter中第4个元素的值赋值为4bit 十六进制数F，等效于counter[3][3:0] = 4'hF，即可省略宽度;  
assign addr_bus[0]        = 8'b0 ; //将数组addr_bus中第一个元素的值赋值为0  
```

