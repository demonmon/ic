#include 
# 常用编译预处理语句
反引号 `   开始的某些标识符是 Verilog 系统编译指令。
编译指令为 Verilog 代码的撰写、编译、调试等提供了极大的便利。


## `define 语句
### `define, `undef
在编译阶段，define 用于文本替换，类似于 C 语言中的 **#define**。
一旦 define 指令被编译，其在整个编译过程中都会有效。例如，在一个文件中定义：
``` verilog
`define    DATA_DW     32
```
则在另一个文件中也可以直接使用 DATA_DW。
```verilog
`define    S     $stop;   
//用`S来代替系统函数$stop; (包括分号)
`define    WORD_DEF   reg [31:0]       
//可以用`WORD_DEF来声明32bit寄存器变量
```
undef 用来取消之前的宏定义，例如:
```verilog
define    DATA_DW     32
……
reg  [DATA_DW-1:0]    data_in   ;
……
`undef DATA_DW

`ifdef, `ifndef, `elsif, `else, `endif
```
这些属于条件编译指令。例如下面的例子中，如果定义了 MCU51，则使用第一种参数说明；如果没有定义 MCU、定义了 WINDOW，则使用第二种参数说明；如果 2 个都没有定义，则使用第三种参数说明。
```verilog
`ifdef       MCU51
    parameter DATA_DW = 8   ;
`elsif       WINDOW
    parameter DATA_DW = 64  ;
`else
    parameter DATA_DW = 32  ;
`endif
```

**` elsif, `else 编译指令对于 `ifdef 指令是可选的，即可以只有 `ifdef 和 endif 组成一次条件编译指令块。**
当然，也可用 `ifndef 来设置条件编译，表示如果没有相关的宏定义，则执行相关语句。
下面例子中，如果定义了 WINDOW，则使用第二种参数说明。如果没有定义 WINDOW，则使用第一种参数说明。

```verilog
`ifndef     WINDOW  
    parameter DATA_DW = 32 ;    
 `else  
    parameter DATA_DW = 64 ;  
 `endif//可以不需要elsif 
```



## `include 语句

使用 include 可以在编译时将一个 Verilog 文件内嵌到另一个 Verilog 文件中，作用类似于 C 语言中的 include 结构。该指令通常用于将全局或公用的头文件包含在设计文件里。
**文件路径既可以使用相对路径，也可以使用绝对路径**

```verilog
`include         "../../param.v"
`include         "header.v"
```
![[Pasted image 20220609231641.png]]
## `timescale语句
在 Verilog 模型中，时延有具体的单位时间表述，并用 `timescale 编译指令将时间单位与实际时间相关联。
该指令用于定义时延、仿真的单位和精度，格式为：
`timescale      time_unit / time_precision

```verilog
`timescale 1ns/100ps    //时间单位为1ns，精度为100ps，合法  
//`timescale 100ps/1ns  //不合法  
module AndFunc(Z, A, B);  
    output Z;  
    input A, B ;  
    assign #5.207 Z = A & B  //经过5.2ns时间
endmodule
```
在编译过程中，`timescale 指令会影响后面所有模块中的时延值，直至遇到另一个 `timescale 指令或 `resetall 指令。

由于在 Verilog 中没有默认的 `timescale，如果没有指定 `timescale，Verilog 模块就有会继承前面编译模块的 `timescale 参数。有可能导致设计出错。

如果一个设计中的多个模块都带有 `timescale 时，模拟器总是定位在所有模块的最小时延精度上，并且所有时延都相应地换算为最小时延精度，时延单位并不受影响。例如:
```verilog
`timescale 10ns/1ns  //精度最大0.1 #1代表经过1个10ns的时间单位
module test;  
    reg        A, B ;  
    wire       OUTZ ;  
   
    initial begin  
        A     = 1;  
        B     = 0;  
        # 1.28    B = 1;  
        # 3.1     A = 0;  
    end  
   
    AndFunc        u_and(OUTZ, A, B) ;  
endmodule
```
在模块 AndFunc 中，5.207 对应 **5.21ns。**
在模块 test 中，1.28 (1.3个时间单位)对应 13ns，3.1 对应 31ns。

但是，当仿真 test 时，由于 AndFunc 中的最小精度为 100ps，因此 test 中的时延精度将进行重新调整。13ns 将对应 130*100ps，31ns 将对应 310*100ps。仿真时，时延精度也会使用 100ps。仿真时间单位大小没有影响。
如果有并行子模块，子模块间的 `timescale 并不会相互影响。

例如在模块 test 中再例化一个子模块 OrFunc。仿真 test 时，OrFunc 中的 #5.207 延时依然对应 52ns。

```verilog
//子模块：  
`timescale 10ns/1ns      //时间单位为1ns，精度为100ps，合法  
module OrFunc(Z, A, B);  
    output Z;  
    input A, B ;  
    assign #5.207 Z = A | B  
endmodule  
   
//顶层模块：  
`timescale 10ns/1ns        
module test;  
    reg        A, B ;  
    wire       OUTZ ;  
    wire       OUTX ;  
   
    initial begin  
        A     = 1;  
        B     = 0;  
        # 1.28    B = 1;  
        # 3.1     A = 0;  
    end  
   
    AndFunc        u_and(OUTZ, A, B) ;  
    OrFunc         u_and(OUTX, A, B) ;  
   
endmodule
```


## `default_nettype

该指令用于为隐式的线网变量指定为线网类型，即将没有被声明的连线定义为线网类型。

```verilgo
`default_nettype wand
```
该实例定义的缺省的线网为线与类型。因此，如果在此指令后面的任何模块中的连线没有说明，那么该线网被假定为线与类型。

>`default_nettype none

该实例定义后，将不再自动产生 wire 型变量。
例如下面第一种写法编译时不会报 Error，第二种写法编译将不会通过。
```verilog
//Z1 无定义就使用，系统默认Z1为wire型变量，有 Warning 无 Error  
module test_and(  
        input      A,  
        input      B,  
        output     Z);  
    assign Z1 = A & B ;    
endmodule 

//Z1无定义就使用，由于编译指令的存在，系统会报Error，从而检查出书写错误  
`default_nettype none  
module test_and(  
        input      A,  
        input      B,  
        output     Z);  
    assign Z1 = A & B ;    
endmodule
```
