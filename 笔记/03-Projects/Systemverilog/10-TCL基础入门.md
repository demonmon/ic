### Tcl基础入门
### 引言
-   TCL（Tool Command Language）是一种解释执行的脚本语言（Scripting Language）。它提供了通用的编程能力：支持变量、过程和控制结构；同时TCL还拥有一个功能强大的固有的核心命令集。
-   由于TCL的解释器是用一个C\C++语言的过程库实现的，因此在某种意义上我们又可以把TCL看作一个C库，这个库中有丰富的用于扩展TCL命令的C\C++过程和函数，每个应用程序都可以根据自己的需要对TCL语言进行扩展。
-   扩展后的TCL语言将可以继承TCL核心部分的所有功能，包括核心命令、控制结构、数据类型、对过程的支持等；TCL良好的可扩展性使得它能很好地适应产品测试的需要，目前已成为自动测试中事实上的标准。
### 脚本学习核心

-   TCL脚本执行依赖于解释器（逐行执行）。
-   TCL有效命令行以命令+字符串（结合空格间隔符）形成。
-   明白置换（$、[]、\）和引用（””，{}）的差别和联系。
-   理解命令eval、expr、source、exec的差别。
-   掌握{* } 配合glob等返回list后的操作 

## 基础语法
一个TCL脚本可以包含一个或多个命令。命令之间必须用**换行符或分号隔开**，下面的两个脚本都是合法的：
```tcl
set a 1  
set b 2  
或set a 1; set b 2
```
- TCL的每一个命令包含一个或几个单词，第一个单词代表命令名，另外的单词则是这个命令的参数，单词之间必须用空格或TAB键隔开。

### 置换
-   TCL解释器在分析命令时，把所有的命令参数都当作**字符串**看待，例如
```tcl
%set x 10        //定义变量x，并把x的值赋为10   
10  
%set y x+100  //y的值是x+100，而不是我们期望的110  
x+100
```

-   上例的第二个命令中，x被看作字符串x+100的一部分，如果我们想用x的值’10’，就必须告诉TCL解释器：我们在这里期望的是变量x的值，而非字符x’。怎么告诉TCL解释器呢，这就要用到TCL语言中提供的置换功能。
-  TCL提供三种形式的置换：**变量置换**、**命令置换**和**反斜杠置换**。


### 变量置换
-   变量置换由一个$符号标记，变量置换会导致变量的值插入一个单词中。例如：
``` tcl
%set y $x+100  
// y的值是10+100，这里x被置换成它的值10+100
```
-   这时，y的值还不是我们想要的值110，而是10+100，因TCL解释器把10+100看成是一个字符串而不是表达式，y要得到值110，还必须用命令置换，使得TCL会把10+100看成个表达式并求值。

### 命令置换

-   命令置换是由[]括起来的TCL命令及其参数，命令置换会导致某一个命令的所有或部分单词被另一个命令的结果所代替。
```tcl
%set y [expr $x+100]
110
```
-   y的值是110，这里当TCL解释器遇到字符'[]'时，它就会把随后的expr作为一个命令名，从而激活与expr对应的C/C++过程，并把’expr’和变量置换后得到的’10+110’传递给该命令过程进行处理。

-   如果在上例中我们去掉’[]’，那么TCL会报错。因为在正常情况下，TCL解释器**只把命令行中的第一个单词作为看作命令**，其他的单司都作为普通字符串处理，看作是命令的参数。

### 反斜杠置换
-   TCL语言中的反斜杠置换类似于C语言中反斜杠的用法，主要用于在单词符号中插入诸如换行符、空格、[、$等，被TCL解释器当作特殊符号对待的字符。例如：
```tcl
%set msg multiple\ space           //msg的值为multiple space.
multiple space
```
-   如果没有\ 的话，TCL会报错，因为解释器会把这里最后两个单词之间的空格认为是分隔符，于是发现set命令有多于两个参数，从而报错。加入了”后，空格不被当作分隔符，’multiple space’被认为是一个单词（word）

### 双引号和花括号
-   除了使用反斜杠外，TCL提供另外两种方法来使得**解释器把分隔符和置换符等特殊字符当作普通字符，而不作特殊处理**，这就要使用双引号和花括号（}）。
-   TCL解释器对双引号中的**各种分隔符将不作处理，但是对换行符及$和[]两种置换符会照常处理**。、
```tcl
%set y "$x ddd"  
100 ddd
```

### 变量
-   一个TCL的简单变量包含两个部分：**名字和值（都可以是任意字符）**。
-   TCL解释器在分析一个变量置换时，只**把从$符号往后直到第一个不是字母、数字或下划线的字符之间的单词符号**作为要被置换的变量的名字。
```tcl
%set a 2     //2
%set a.1 4   //4
%set b $a.1  //2.1
%set b ${a.1} //4
%set a {kdfj kjdf}  //kdfj kjdf
%set a              //kdfj kjdf 读取变量
```
-   在最后一个命令行，我们希望把变量a.1的值付给b，但是TCL解释器在分析时只把符号之后直到第一个不是字母、数字或下划线的字符（这里是.）之间的单词符号（这里是’a）当作要被置换的变量的名字，所以TCL解释器把a置换成2，然后把字符串“2.1”付给变量b。这显然与我们的初衷不同。
-   如果变量名中有**不是字母、数字或下划线的字符**，又要用置换，可以用**花括号把变量名括起来**。
-   TCL中的set命令**能生成一个变量、也能读取或改变一个变量的。**

### 数组

-   数组是一些元素的集合。TCL的数组和普通计算机语言中的数组有很大的区别。在TCL中，**不能单独声明一个数组，数组只能和数组元素一起声明**。数组中，数组元素的名字包含两部分：**数组名和数组中元素的名字**，TCL中数组元素的名字（下**标）可以为任何字符串**。
```tcl
%set day(monday) 1     //第一个命令生成一个名为day的数组，同时在数组中生成一个名为monday的数组元素，并把值置为1
%set day(tuesday) 2    //第二个命令生成一个名为tuesday的数组元素，并把值置为2
```
### 相关命令
-   unset这个命令从解释器中删除变量，它后面可以有任意多个参数，每个参数是一个变量名，可以是简单变量，也可以是数组或数组元素。
```tcl
%unset a b day(monday)
```
append命令把文本加到一个变量的后面
```tcl
%set txt hello                   //Hello
%append txt "！How are you"      //hello！How are you

```
incr命令把一个变量值加上一个整数。incr要求变量原来的值和新加的值都必须是整数。
```tcl
%set b 2 
incr b 3     //结果为5
```

### 表达式
-   TCL支持常用的数学函数，表达式中数学函数的写法类似于C\C++语言的写法，数学函数的参数可以是任意表达式，**多个参数之间用逗号隔开**。
```tcl
%set x 2    //2
%expr 2*sin($x<3)   //1.68294196962
```

-   其中**expr是TCL的一个命令**，语法为：expr arg ？arg…？，两个？之间的参数表示可省，后面介绍命令时对于可省参数都使用这种表示形式。 
-   需要注意的一点是，数学函数并不是命令，只在表达式中出现才有意义，即**出现在expr之后才有意义。**

### List
-   TCL中list是由一堆元素组成的有序集合，list可以嵌套定义，**list每个元素可以是任意字符串，也可以是list。**
```tcl
{}  //空list
{a b c d}
{a {b c} d}//list可以嵌套

语法：list ？value value...？  //这个命令生成1个list，list的元素就是所有的value
%list 1 2 {3 4}
1 2 {3 4}

语法：concat list ？list..？  //整合两个list
%concat {123} {456}
{1 2 3 4 5 6}

语法：lindex list index       //返回list的第index个元素
%lindex {12{3 4}} 2 
3 4

语法：llength list            //返回list的元素个数
%llength {1 2 {3 4}}
3
语法：linsert list index value ？value...？    //list插入元素
%linsert {1 2 5 6} 1 7 8
1 7 8 2 5 6

语法：lappend varname value ？value...？       //把每个value的值作为一个元素附加到变量varname后面
%lappend a 1 2 3
1 2 3
```

## 控制命令

### 控制流： if命令
-   语法：if test1 body1 ？else bodyn？
-   TCL先把test1当作一个表达式求值，如果值非0，则把body1当作一个脚本执行并返回所得值，否则把test2当作一个表达式求值，如果值非0，则把body2当作一个脚本执行并返回所得值。
```tcl
if {$x>0}{      //注意{一定要写在上一行，因为不这样，TCL解释器会认为if命令在换行符已经结束了；
.....}elseif {$x==1}{  //同时if和{之间应该有一个空格，否则TCL解释器会会把'if{'作为一个整体命令导致出错
.....}elseif {$x==2}{
.....}else {
.....}
```

### 循环：while命令
-   语法：while test body
-   参数test是一个表达式，body是一个脚本，如果表达式的值非0，就运行脚本，直到表达式为0才停止循环，此时while命令中断并返回一个空字符串。此处是一个脚本：
```tcl
set b ""
set i [expr [llength $a]-1]
while {$i>=0}{
  lappend b [lindex $a $i]
  incr i-1 }               //变量a是一个链表，脚本把a的值复制到b
```

### 循环：for命令
-   语法：for init test reinit body
-   参数init是一个初始化脚本，第二个参数test是一个表达式，用来决定循环什么时候中断，第三个参数reinit是一个重新初始化的脚本，第四个参数body也是脚本，代表循环体；
```tcl
//假设变量a是一个链表，下面的脚本把a的值复制到b：
set b "" 
for{set i [expr [llength $a]-1]}{$i>=0}{incr i-1}{
  lappend b[lindex $a $i]}
//作用和上面的例子是相同的
```

### 循环：foreach命令

语法：foreach  varName  list  body  
第一个参数varName是一个变量，第二个参数list是一个表（有序集合），第三个参数body是循环体。每次取得链表的一个元素，都会执行循环体一次。
```tcl
set b ""
foreach i $a{
  set b [linsert $b 0 $i]
}
//变量a是一个链表，脚本把a的值复制到b,顺序刚好相反
```
### 控制：switch命令
-   语法：switch ？options？ string { pattern body ？pattern body…？}
-   第一个是可选参数options，表示进行匹配的方式。TCL支持三种匹配方式：**-exact方式，-glob方式，-regexp方式**，缺省情况表示-glob方式。-exact方式表示的是精确匹配，-glob方式的匹配方式和string match命令的匹配方式相同，-regexp方式是正规表达式的匹配方式。第二个参数string是要被用来作测试的值，第三个参数是括起来的一个或多个元素

```tcl
%switch $x{         //一旦switch命令找到一个模式匹配
  b{incr t1}        //就执行相应的脚本，并返回脚本的
  c{incr t2}}       //值，作为switch命令的返回值。
```

### 跳出循环

-   在循环体中，可以用break和continue命令中断循环。其中break命令结束整个循环过程，并从循环中跳出，continue只是结束本次循环。
-   source命令读一个文件并把这个文件的内容作为一个脚本进行求值``
-   `%source e:/tcl&c/hello.tcl`
-   eval命令是一个用来构造和执行TCL脚本的命令，其语法为：`eval arg ？arg...`
```tcl
%eval set a 2;
set b 4 4   //它可以接收一个或多个参数，然后把所有的参数以空格隔开组合到一起成为一个脚本，然后对这个脚本进行求值。
```
### 过程

-   TCL支持过程的定义和调用，在TCL中，过程可以看作是用TCL脚本实现的命令，效果与TCL的固有命令相似。
```tcl
%proc add {x y} {expr $x+$y}   //TCL中过程是由proc命令产生的：
%add 1 2           3           //proc生成一个新的命令，可以象固有命令一样调用
```
### 局部变量和全局变量
```tcl
%set a 4
4
%proc sample{x}{
  global a       //全局变量声明
  incr a         //a+1 默认＋1
  return[expr $a+$x}
%sample 3
8
%set a
5
```
### 字符串操作
-   因为TCL把所有的输入都当作字符串看待，所以TCL提供了较强的字符串操作功能。
-   语法：**format** formatstring ？vlue value…？
-   format命令类似于ANSIC中的sprintf函数，按formatstring提供的格式，把各个value的值组合到formatstring中形成一个新字符串返回
```tcl
%set name john            //John
%set age 20               //20
%set msg[format "%s is %d years old" $name $age]     //john is 20 years old

```

-   语法：**scan** string format varName ？varName…？
-   scan命令可以认为**是format命令的逆**，其功能类似于ANSIC中的sscanf函数。它按format提供的格式分析string字符串，然后把结果存到变量varName中，**注意除了空格和TAB键之外，string和format中的字符和’%’必须匹配**。
```tcl
%scan"some 26 34""some %d %d" a b     //2
%set a                                //26
%set b                                //34 
```

-   语法：regexp ？switchs？ ？–？ Exp string ?matchVar？\ ?subMatchVar subMatchVar…？
-   regexp命令用于判断正规表达式exp是否全部或部分匹配字符串string，匹配返回1，否则0
![[Pasted image 20220601204136.png]]

### 文件访问
-   TCL提供了丰富的文件操作的命令。通过这些命令你可以对文件名进行操作（查找匹配某一模式的文件）、以顺序或随机方式读写文件、检索系统保留的文件信息（如最后访问时间）
-   TCL中文件名和我们熟悉的windows表示文件的方法有一些区别：`在表示文件的目录结构时它使用'/'，而不是'\'`。  
-   语法：open name ?access？
-   open命令以access方式打开文件name，返回供其他命令（gets，close等）使用的文件标识。
```tcl
文件的打开方式和我们熟悉的C语言类似，有以下方式：
r  只读方式打开。文件必须已经存在。这是默认方式。
r+ 读写方式打开，文件必须已经存在。
w  只写方式打开文件，如果文件存在则清空文件内容，否则创建一新的空文件。
w+ 读写方式打开文件，如文件存在则清空文件内容，否则创建新的空文件。
a  只写方式打开文件，文件必须存在，并把指针指向文件尾。
a+ 读写方式打开文件，并把指针指向文件尾。如文件不存在，创建新的空文件
```

-   open命令返回一个字符串用于表识打开的文件。当调用别的命令（如：gets，puts，close）]对打开的文件进行操作时，就可以使用这个文件标识符。TCL有三个特定的文件标识：**stdin，stdout和stderr**，分别对应标准输入、标准输出和错误通道，任何时候你都可以使用这三个文件标识。
-   gets fileld ?varName?读fileld标识的文件的下一行，忽略换行符。如果命令中有varName就把该行赋给它，并返回该行的字符数（文件尾返回-1），如果没有varName参数，返回文件的下一行作为命令结果（如果到了文件尾，就返回空字符串）
-   put ?-nonewline？?fileld？string puts命令把string写到fileld中，如果没有nonewline开关的话，添加换行符。fileld默认是stdout，命令返回值为一空字符串。
-   flush fileld把缓冲区内容写到fileld标识的文件中，命令返回值为空字符串。
-   flush命令迫使缓冲区数据写到文件中。flush直到数据被写完才返回。当文件关闭时缓冲区数据会首动flush.
```tcl
proc tgrep {pattern filename}{     
  set f [open $filename r]               
  while {[gets $f line]}{ 
    if {regexp $pattern $line]}{ 
        puts stdout $line  
    } 
close $f 
}//TCL文件I/O的基本特点示例
```

CL提供两个命令来管理当前工作目录：pwd和cd.
>pwd和UNIX下的pwd命令完全一样，没有参数，返回当前目录的完整路径。
cd命令也和UNIX命令也一样，使用一个参数，可以把工作目录改变为参数提供的目录。如果cd没使用参数，UNIX下，会把工作目录变为启动TCL脚本的用户的工作目录。

-   TCL提供了两个命令进行文件名操作：glob和file，用来操作文件或获取文件信息。
- 
 > glob命令采用一种或多种模式作为参数，并返回匹配这个（些）模式的所有文件的列表
 

-   语法为：glob ?switches？ pattern ?pattern…？
-   glob命令的模式采用string match命令的匹配规则。例如：
```tcl
%glob *.c *.h 
main.c hash.c hash.h 
file delete *.tmp             //不生效不执行通配符展开

//先使用glob命令返回文件列表，在使用参数展开语法{*}把列表元素作为独立参数提供给指令。
file delete {*}[glob*.tmp]    //必须加{}，否则不同元组之间的空格会将所有元素合为一个
//也可以选择使用eval 
eval file delete [glob*.tmp]
```

-   file是有许多选项的常用命令，可以用来进行文件操作也可以检索文件信息
	
    > file atime name返回一个十进制的字符串，表示文件name最后被访问的时间。时间是以秒为单位从1970年1月1日12：00AM开始计算。如果文件name不存在或查询不到访问时间就返回错误。例：`%file atime license.txt 975945600`
    > 
-   语法：file copy ?-force？ ?–？source target 

    > 这个命令把source中指明的文件或目录递归的拷贝到目的地址targetDir，只有当存在-force选项时，已经存在的文件才会被覆盖。试图覆盖一个非空的目录或以一个文件覆盖一个目录或以一个目录覆盖一个文件都会导致错误。
``` tcl
file mkdir dir  ？dir..？        //创建dir中指明的目录
file owned name                  //如果name被当前用户拥有，返回1，否则返回0
file executable name             //如果name对当前用户是可以执行的，就返回1，否则返回0。
```



