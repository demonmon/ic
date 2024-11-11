  #选择器
# 条件语句

条件（if）语句用于控制执行语句要根据条件判断来确定是否执行。
条件语句用关键字 if 和 else 来声明，条件表达式必须在圆括号中。
```verilog
if (condition1)       true_statement1 ;
else if (condition2)        true_statement2 ;
else if (condition3)        true_statement3 ;
else
```

![[Pasted image 20220607104513.png]]

![[Pasted image 20220607104550.png]]

# 多路分支语句
### case 语句
case 语句格式如下：

>case(case_expr)
 condition1     :             true_statement1 ;
condition2     :             true_statement2 ;
……
default        :             default_statement ;
endcase



### casex/casez 语句

casex、 casez 语句是 case 语句的变形，用来表示条件选项中的无关项。

casex 用 "x" 来表示无关值，casez 用问号 "?" 来表示无关值。

两者的实现的功能是完全一致的，语法与 case 语句也完全一致。

但是 casex、casez 一般是不可综合的，多用于仿真。

![[Pasted image 20220607104813.png]]


```verilog
module mux4to1(  
    input [3:0]     sel ,  
    input [1:0]     p0 ,  
    input [1:0]     p1 ,  
    input [1:0]     p2 ,  
    input [1:0]     p3 ,  
    output [1:0]    sout);  
   
    reg [1:0]     sout_t ;  
    always @(*)  
        casez(sel)  
            4'b???1:     sout_t = p0 ;  
            4'b??1?:     sout_t = p1 ;  
            4'b?1??:     sout_t = p2 ;  
            4'b1???:     sout_t = p3 ;    
        default:         sout_t = 2'b0 ;  
    endcase  
    assign      sout = sout_t ;  
   
endmodule
```
这里“？”表示的是高阻态

# 条件语句注意事项
- 应注意列出所有条件，否则不满足时候，会产生一个锁存器保持原值
- 可用于设计时序电路 满足加1 不满足保持
- 设计组合逻辑电路时候，避免生成锁存器。记得if后加else case最后加上default 项

![[Pasted image 20220607105415.png]]