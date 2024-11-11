
![[Pasted image 20221012212928.png]]

A0-A12==只能区分行，在区分列地址位就太多了== 先给行地址再给列地址
 BA0 BA1 区分哪个bank
**缓存** --- 可以先缓存四个bank的不同行不同列，同时打开bank的某一行某一列需要时间。
DRAM -- 定时刷新，一个电容存高电平，低电平，定期访问
SRAM -- 六个晶体管存一位数据了，占面积
读出来，电位发生变化，再写进去，
写操作也会有precharge操作

## 控制状态寄存器

![[Pasted image 20221012230412.png]]

burst传输方式：
还有一个full page（整行）
![[Pasted image 20221012231009.png]]

## 命令


 ![[Pasted image 20221013095506.png]]

**行操作** ： ==NO OPERATION （NOP）==， 激活命令
**列操作**： READ and WRITE
BURST TERMINATE ：读和写的过程可以cancel掉
PRECHARGE ： 把bank下面的行缓冲里面读过那一行再写进去 
LOAD MODE REGISTER --修改控制寄存器

## 时序图

- 激活命令

![[Pasted image 20221013100546.png]]
- 打开某一行之后需要时间所以等几拍再去发读写命令（列命令）

![[Pasted image 20221013100825.png]]
- 读命令：
注意A10作用：A10拉高就自带自动关闭（充电），拉低
![[Pasted image 20221013101120.png]]
- 发完读命令之后也不是立马下一拍操作 ，需要列选通延迟；根据频率等两拍或者三拍
![[Pasted image 20221013102318.png]]

**如果连续读就可以不带自动关闭**，因为有可能你读这一行的不同起始列不同的数据
![[Pasted image 20221013102554.png]]


- 也可以随机读--每次只读一个数据 同一行的不同列

![[Pasted image 20221013103116.png]]


- 读命令没做完，新来命令把它中断，做新的命令 
![[Pasted image 20221013103220.png]]


![[Pasted image 20221013103408.png]]

- 读完关闭 ，关闭之后可以马上新的bank，**关闭需要等一会才可以打开新的行**

![[Pasted image 20221013103546.png]]


- 读中断 更多用在fullpage，从某一列开始读，不一定全读 读的差不多了可以中止。

![[Pasted image 20221013103838.png]]

## 写时序
- 先打开某一行 
![[Pasted image 20221013104200.png]]
- 写数据当拍就放进去


![[Pasted image 20221013104328.png]]

- 连续写
![[Pasted image 20221013104436.png]]


- 随机写
![[Pasted image 20221013104512.png]]
- 写完就马上读
![[Pasted image 20221013104547.png]]


- 写完关闭也是不能立马关闭（Trp）
要根据你Twr去等待多久再执行关闭操作 
![[Pasted image 20221013104617.png]]

![[Pasted image 20221013104745.png]]

- 写中断
![[Pasted image 20221013105334.png]]

- 关闭操作
![[Pasted image 20221013105502.png]]





![[Pasted image 20221013105710.png]]



上电操作
**上来先等100微秒**发一个NOP 再发PRECHARGE（这个关闭是关闭所有bank的操作，A10必须拉高） 等**延时之后** 再发AUTO FLASH命令等待FLASH周期 再发AUTO FLASH命令在等FLASH周期 至少两个AUTO FLASH 。然后再发 LOAD MODE REGISTER，也是需要等一段时间（两拍做完）。之后才可以进行读写操作

![[Pasted image 20221013110053.png]]

状态机或者计数器都可以做
- 断电操作
![[Pasted image 20221013110825.png]]

- 自动刷新操作
不需要地址，
![[Pasted image 20221013110914.png]]


![[Pasted image 20221013112909.png]]



![[Pasted image 20221013113029.png]]


不同bank交织去读


![[Pasted image 20221013113041.png]]





![[Pasted image 20221013113313.png]]





![[Pasted image 20221013113427.png]]


![[Pasted image 20221013113542.png]]




![[Pasted image 20221013113620.png]]




![[Pasted image 20221013113805.png]]



![[Pasted image 20221013113833.png]]
![[Pasted image 20221013113902.png]]















































