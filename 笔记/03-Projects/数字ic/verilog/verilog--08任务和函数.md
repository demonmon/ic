
在 Verilog 中，可以利用任务（关键字为 task）或函数（关键字为 function），将重复性的行为级设计进行提取，并在多个地方调用，来避免重复代码的多次编写，使代码更加的简洁、易懂。
# 函数--funtion
函数只能在模块中定义，位置任意，并在模块的任何地方引用，作用范围也局限于此模块。函数主要有以下几个特点：
-  不含有任何延迟、时序或时序控制逻辑
-  至少有一个输入变量
-  只有一个返回值，且没有输出
-  不含有非阻塞赋值语句
-  函数可以调用其他函数，但是不能调用任务

Verilog 函数声明格式如下：
>function [range-1:0]     function_id ;
>input_declaration ;
 >other_declaration ;
>procedural_statement ;
endfunction

函数在声明时，**会隐式的声明一个宽度为 range、 名字为 function_id 的寄存器变量**，函数的返回值通过这个变量进行传递。当该寄存器变量没有指定位宽时，默认位宽为 1。函数通过指明函数名与输入变量进行调用。函数结束时，返回值被传递到调用处。

**注：函数在综合的时候被理解为具有独立运算功能的电路，每调用一次函数，相当于改变此电路输入**

下面用函数实现一个数据大小端转换的功能。
当输入为 4'b0011 时，输出可为 4'b1100。例如：
```verilog
module endian_rvs  
    #(parameter N = 4)  
        (  
            input             en,     //enable control  
            input [N-1:0]     a ,  
            output [N-1:0]    b  
    );  
           
        reg [N-1:0]          b_temp ;  
        always @(*) begin  
        if (en) begin  
                b_temp =  data_rvs(a);  
            end  
            else begin  
                b_temp = 0 ;  
            end  
    end  
        assign b = b_temp ;  
           
    //function entity  
        function [N-1:0]     data_rvs ;  
            input     [N-1:0] data_in ;  
            parameter         MASK = 32'h3 ;  
            integer           k ;  
            begin //begin end 包括住 
                for(k=0; k<N; k=k+1) begin  
                    data_rvs[N-k-1]  = data_in[k] ;    
                end  
            end  
    endfunction  
           
endmodule

```

函数里的参数也可以改写，例如：
> defparam data_rvs.MASK = 32'd7 ;

但是仿真时发现，此种写法编译可以通过，仿真结果中，函数里的参数 MASK 实际并没有改写成功，仍然为 32'h3。这可能和编译器有关，有兴趣的学者可以用其他 Verilog 编译器进行下实验。
函数在声明时，也可以在函数名后面加一个括号，将 input 声明包起来。
例如上述大小端声明函数可以表示为：
```verilog
function [N-1:0]     data_rvs（
input     [N-1:0] data_in 
    ......
    ） ;
```

函数使用规则
- 函数定义下**不能包含任何时间控制语句**（# @ wait等）
- 不能调用任务
-  **至少有一个输入变量**，并且不能有任何输出 或 输入输出双变量
-  **函数定义中必须有一条赋值语句，给函数内部寄存器赋以函数的结果值，该内部寄存器与函数同名** 

实例：
数码管译码：

每位数码显示端有 8 个光亮控制端（如图中 a-g 所示），可以用来控制显示数字 0-9 。
而数码管有 4 个片选（如图中 1-4），用来控制此时哪一位数码显示端应该选通，即应该发光。倘若在很短的时间内，依次对 4 个数码显示端进行片选发光，同时在不同片选下给予不同的光亮控制（各对应 4 位十进制数字），那么在肉眼不能分辨的情况下，就达到了同时显示 4 位十进制数字的效果。
下面，我们用信号 abcdefg 来控制光亮控制端，用信号 csn 来控制片选，4 位 10 进制的数字个十百千位分别用 4 个 4bit 信号 single_digit, ten_digit, hundred_digit, kilo_digit 来表示，则一个数码管的显示设计可以描述如下：

![[Pasted image 20220613213020.png]]


```verilog
module digital_tube  
     (  
      input             clk ,  
      input             rstn ,  
      input             en ,  
   
      input [3:0]       single_digit ,  
      input [3:0]       ten_digit ,  
      input [3:0]       hundred_digit ,  
      input [3:0]       kilo_digit ,  
   
      output reg [3:0]  csn , //chip select, low-available  
      output reg [6:0]  abcdefg        //light control  
      );  
   
    reg [1:0]            scan_r ;  //scan_ctrl  
    always @ (posedge clk or negedge rstn) begin  
        if(!rstn)begin  
            csn            <= 4'b1111;  
            abcdefg        <= 'd0;  
            scan_r         <= 3'd0;  
        end  
        else if (en) begin  
            case(scan_r)  
            2'd0:begin  
                scan_r    <= 3'd1;  
                csn       <= 4'b0111;     //select single digit  
                abcdefg   <= dt_translate(single_digit);  
            end  
            2'd1:begin  
                scan_r    <= 3'd2;  
                csn       <= 4'b1011;     //select ten digit  
                abcdefg   <= dt_translate(ten_digit);  
            end  
            2'd2:begin  
                scan_r    <= 3'd3;  
                csn       <= 4'b1101;     //select hundred digit  
                abcdefg   <= dt_translate(hundred_digit);  
            end  
            2'd3:begin  
                scan_r    <= 3'd0;  
                csn       <= 4'b1110;     //select kilo digit  
                abcdefg   <= dt_translate(kilo_digit);  
            end  
            endcase  
        end  
    end  
   
    /*------------ translate function -------*/  
    function [6:0] dt_translate;  
        input [3:0]   data;  
        begin  
        case(data)  
            4'd0: dt_translate = 7'b1111110;     //number 0 -> 0x7e  
            4'd1: dt_translate = 7'b0110000;     //number 1 -> 0x30  
            4'd2: dt_translate = 7'b1101101;     //number 2 -> 0x6d  
            4'd3: dt_translate = 7'b1111001;     //number 3 -> 0x79  
            4'd4: dt_translate = 7'b0110011;     //number 4 -> 0x33  
            4'd5: dt_translate = 7'b1011011;     //number 5 -> 0x5b  
            4'd6: dt_translate = 7'b1011111;     //number 6 -> 0x5f  
            4'd7: dt_translate = 7'b1110000;     //number 7 -> 0x70  
            4'd8: dt_translate = 7'b1111111;     //number 8 -> 0x7f  
            4'd9: dt_translate = 7'b1111011;     //number 9 -> 0x7b  
        endcase  
        end  
    endfunction  
   
endmodule
```

# 任务--task

和函数一样，任务（task）可以用来描述共同的代码段，并在模块内任意位置被调用，让代码更加的直观易读。函数一般用于组合逻辑的各种转换和计算，而任务更像一个过程，不仅能完成函数的功能，还可以包含时序控制逻辑。下面对任务与函数的区别进行概括
![[Pasted image 20220609215335.png]]


**任务声明**
任务在模块中任意位置定义，并在模块内任意位置引用，作用范围也局限于此模块。
模块内子程序出现下面任意一个条件时，则必须使用任务而不能使用函数。

- 子程序中包含时序控制逻辑，例如延迟，事件控制等
-  没有输入变量
-  没有输出或输出端的数量大于 1


Verilog 任务声明格式如下：
>task       task_id ;
    port_declaration ;
    procedural_statement ;
endtask

任务中使用关键字 input、output 和 inout 对端口进行声明。input 、inout 型端口将变量从任务外部传递到内部，output、inout 型端口将任务执行完毕时的结果传回到外部。

进行任务的逻辑设计时，可以把 input 声明的端口变量看做 wire 型，把 output 声明的端口变量看做 reg 型。但是不需要用 reg 对 output 端口再次说明。
输入端连接的模块内信号可以是 wire 型，也可以是 reg 型。输出端连接的模块内信号要求一定是 reg 型，这点需要注意
一个任务可以调用其他任务和函数 
任务调用时，端口必须按顺序对应。
**实例**：对上述异或功能的 task 进行一个调用，完成对异或结果的缓存。
```verilog
task xor_oper_iner;  
    input [N-1:0]   numa;  
    input [N-1:0]   numb;  
    output [N-1:0]  numco ;  
    //output reg [N-1:0]  numco ; //无需再注明 reg 类型，虽然注明也可能没错  
    #3  numco = numa ^ numb ;  
    //assign #3 numco = numa ^ numb ; //不用assign，因为输出默认是reg  
endtask
//端口声明也可以用括号括起来
task xor_oper_iner（  
    input [N-1:0]   numa,  
    input [N-1:0]   numb,  
    output [N-1:0]  numco  ） ;  
    #3  numco       = numa ^ numb ;  
endtask
```

**任务调用**

任务可单独作为一条语句出现在 initial 或 always 块中，调用格式如下：
>task_id(input1, input2, …,outpu1, output2, …); 


```verilog
module xor_oper  
    #(parameter         N = 4)  
     (  
      input             clk ,  
      input             rstn ,  
      input [N-1:0]     a ,  
      input [N-1:0]     b ,  
      output [N-1:0]    co  );  
   
    reg [N-1:0]          co_t ;  
    always @(*) begin          //任务调用  
        xor_oper_iner(a, b, co_t);  
    end  
   
    reg [N-1:0]          co_r ;  
    always @(posedge clk or negedge rstn) begin  
        if (!rstn) begin  
            co_r   <= 'b0 ;  
        end  
        else begin  
            co_r   <= co_t ;         //数据缓存  
        end  
    end  
    assign       co = co_r ;  
   
   /*------------ task -------*/  
    task xor_oper_iner;  
        input [N-1:0]   numa;  
        input [N-1:0]   numb;  
        output [N-1:0]  numco ;  
        #3  numco       = numa ^ numb ;   //阻塞赋值，易于控制时序  
    endtask  
   
endmodule
```

## 任务操作全局变量

因为任务可以看做是过程性赋值，所以任务的 output 端信号返回时间是在任务中所有语句执行完毕之后。

任务内部变量也只有在任务中可见，如果想具体观察任务中对变量的操作过程，**需要将观察的变量声明在模块之内、任务之外，可谓之"全局变量"。**

例如有以下 2 种尝试利用 task 产生时钟的描述方式。
**实例**
```verilog
//way1 to decirbe clk generating, not work  
task clk_rvs_iner ;  
        output    clk_no_rvs ;  
        # 5 ;     clk_no_rvs = 0 ;  
        # 5 ;     clk_no_rvs = 1 ;  
endtask  
reg          clk_test1 ;  
always clk_rvs_iner(clk_test1);  
  
//way2: use task to operate global varialbes to generating clk  
reg          clk_test2 ;  
task clk_rvs_global ;  
        # 5 ;     clk_test2 = 0 ;  //全局变量
        # 5 ;     clk_test2 = 1 ;  
endtask // clk_rvs_iner  
always clk_rvs_global;
```

第一种描述方式，虽然任务内部变量会有赋值 0 和赋值 1 的过程操作，但中间变化过程并不可见，最后输出的结果只能是任务内所有语句执行完毕后输出端信号的最终值。**所以信号 clk_test1 值恒为 1，此种方式产生不了时钟。**
第二种描述方式，虽然没有端口信号，**但是直接对"全局变量"进行过程操作，因为该全局变量对模块是可见的，所以任务内信号翻转的过程会在信号 clk_test2 中体现出来。**

## automatic 任务 
和函数一样，Verilog 中任务调用时的局部变量都是静态的。可以用关键字 automatic 来对任务进行声明，那么任务调用时各存储空间就可以动态分配，每个调用的任务都各自独立的对自己独有的地址空间进行操作，而不影响多个相同任务调用时的并发执行
**如果一任务代码段被 2 处及以上调用，一定要用关键字 automatic 声明。**
当没有使用 automatic 声明任务时，任务被 2 次调用，可能出现信号间干扰，例如下面代码描述：
```verilog
task test_flag ;  
        input [3:0]       cnti ;  
        input             en ;  
        output [3:0]      cnto ;  
        if (en) cnto = cnti ;  
endtask  
  
reg          en_cnt ;  
reg [3:0]    cnt_temp ;  
initial begin  
        en_cnt    = 1 ;  
        cnt_temp  = 0 ;  
        #25 ;     en_cnt = 0 ;  
end  
always #10 cnt_temp = cnt_temp + 1 ;  
  
reg [3:0]             cnt1, cnt2 ;  
always @(posedge clk) test_flag(2, en_cnt, cnt1);       //task(1)  
always @(posedge clk) test_flag(cnt_temp, !en_cnt, cnt2);//task(2)
```

**仿真结果如下。**
en_cnt为高时，任务 (1) 中信号 en 有效， cnt1 能输出正确的逻辑值；
此时任务 (2) 中信号 en 是不使能的，所以 cnt2 的值被任务 (1) 驱动的共用变量 cnt_temp 覆盖。
en_cnt 为低时，任务 (2) 中信号 en 有效，所以任务 (2) 中的信号 cnt2 能输出正确的逻辑值；而此时信号 cnt1 的值在时钟的驱动下，一次次被任务 (2) 驱动的共用变量 cnt_temp 覆盖。
可见，任务在两次并发调用中，共用存储空间，导致信号相互间产生了影响。
![[Pasted image 20220609221606.png]]

**其他描述不变，只在上述 task 声明时加入关键字 automatic，如下所以。**
>task automatic test_flag ;

![[Pasted image 20220609221723.png]]
