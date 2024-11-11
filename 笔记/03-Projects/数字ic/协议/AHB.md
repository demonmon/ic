## AHB

**sram片选信号cs为高的条件为什么读写不同呢？熟悉sram口的的知道，真正的写时刻时wdata有效的上升沿，所以cs_write和wdata保持一致。真正的读时刻发生在addr有效的时钟沿，所以cs_read需要和addr保持一致。**

-   **sram写，地址使用haddr_r，sram_cs使用真正的wdata phase，什么是真正的hwdata_phase呢？那就是本次写传输的haddr的下一个cycle如果此时hready_i为0，那么hwdata_phase就需要delay到hready_i拉高。**
-   **sram读，地址使用haddr_i肯定是最快的，但是有特殊情况，那就是ahb读紧跟在ahb写之后，那么地址怎么处理呢？其实就是加上优先级，读写同时发生是写优先于读，就可以了，这会导致整个背靠背过程因为写的delay延后一个cycle，但是只要burst够长，就不会影响性能，类似于pipeline。**
[(7条消息) 【AHB协议解读 三】传输（Transfers）_ahb burst_芯际玩家的博客-CSDN博客](https://blog.csdn.net/qq_41849447/article/details/116902245)

## hready_in 与hready_out

[soc进阶-AHB lite的hreadyin和hreadyout - 知乎 (zhihu.com)](https://zhuanlan.zhihu.com/p/610532763)

## hreadyin和hreadyout的区别是什么？

hreadyout：data_phase时，slave是否已经准备进行真正的数据传输，例如写操作时，slave是否可以将数据存下来。

hreadyin：用于通知这个slave设备，其他slave是否有未完成的传输。


### 如果没有hready_in:
由于AHB是支持pipeline传输的，所以当前的cycle会是上一个slave的data phase，也是下一个slave的addr phase。上面这张时序图表明master有两笔写传输，第一笔传输为slave1(s1)，传输类型为SEQ，在第一笔传输的第二个周期，也就是第一笔传输的data phase，此时slave1没有准备好被写数据，因此把s1_hreadyout拉低，但此时slave2已经看到自己的NONSEQ传输了，而且slave2已经是准备好了的。如下图所示：

![[Pasted image 20230424153359.png]]

如果master那边只能看到一个hreadyout，那到底是看s1的还是s2的呢？

-   如果看s1的话，那么master会在下一个周期维持NONSEQ,那么s2会认为，我已经在上一个周期接收了一个NONSEQ,现在**又来了一个NONSEQ并且addr还没有递增**。在s2会发生protocol fail。如下图1所示：![[Pasted image 20230424153752.png]]

- 如果看s2的话，那么s1的**写数据就会失败，数据还没准备好**，因为当前s1还没有准备好。如下图2所示：![[Pasted image 20230424153941.png]]



也就是说不管看s1还是s2，都会导致slave出现异常，也就是说，如果只靠slave反压master，不管怎样都会导致slave出现异常。

### 有了hreadyin会怎么样？

通常ahb 1ton bridge会接收所有slave的hreadyout，然后进行以下两种处理：

-   通过一个mux,把在data phase的slave的hreadyout作为输入连接到所有的slave。
-   把所有的slave的hreadyout相与，然后再连接到所有的slave。

![[Pasted image 20230424154351.png]]

slave必须看到自己的hreadyin&hreadyout，才认为一次addr phase/data phase的成功。

而且slave必须等到hreadyin为高电平时才进行addr以及控制信号的采样:
```verilog
if(hreadyin&hsel) 
begin
	addr_reg <= haddr;
	htrans_reg <= htrans;
	hwrite_reg <= hwrite;
end
```

重新拿上面的仿真图看一下，由于前一个周期的s1_hreadyout为低电平，所以s2的hreadyin也为低电平，那么该周期s2不会对addr以及控制信号进行采样。在下一个周期s1以及准备好了，s1_hreadyout拉为高电平，s2的hreadyin也为高电平，表示上一笔传输以及结束了，可以开始下一笔传输，也就是s2的传输，此时s2就可以对addr以及控制信号进行采样了，就不会出现上面S2 error或者S1数据丢失的问题。

![[Pasted image 20230424160411.png]]

有两种情况：

1.  多个slave：将master的hreadyout送给所有slave的hreadyin。
2.  单个slave：自己的hreadyout送给自己的hreadyin。

























![[Pasted image 20220809172212.png]]



![[Pasted image 20220809172337.png]]

HCLK/HRESETn（时钟与复位信号）
HSEL（指明当前被访问的从设备，来自译码器）
HADDR[31:0] (32位系统地址总线)
HWDATA[31:0] (写数据总线，从主设备写到从设备）
HRDATA[31:0] (读数据总线，从从设备读到主设备）
HTRANS （传输的状态有：NONSEQ、SEQ、IDLE、BUSY)
HSIZE(传输的数据宽度 8 、16 、32）
HBURST(传输的burst类型，single，incr4/8/16，wrap4/8/16)
HRESP(从设备发给主设备的总线传输状态：OKAY、ERROR、RETRY、SPLIT)
HREADY（高-从设备传输结束；低-从设备需延迟传输周期）

![[Pasted image 20230331193943.png]]
HTRANS = SEQ USEQ IDLE BUSY 
IDLE : 给了grat但没request
BUSY：**把总线拖长，传输五个数据就没数据，差三个，就得传BUSY 等有数据再NONSEQ
HTRANS[1:0] :**
00:IDLE(**主设备占用总线，但没有进行传输；两次burst传输中间主设备发送IDLE**)
01:BUSY（主设备占用总线，但是在burst传输过程中还没有准备好进行下一次传输；一次burst传输中间主设备发BUSY)
10:NONSEQ (表明一个单个数据的传输或者一个burst传输的第一个数据；其地址与控制信号与上一次传输无关）
11：SEQ(表明burst传输接下来的数据；地址与上一次传输的地址是相关的）


### 传输类型（Transfer types）
传输可以被分为四种类型，它们由信号HTRANS[1:0]来表征。

IDLE（b00）：表示不需要数据传输。master在不想执行数据传输时，会使用IDLE类型的传输。一般建议master通过IDLE传输来终止锁定的传输。**slave必须始终为IDLE类型传输提供零等待状态的OKAY响应，并且slave必须忽略该传输**。
BUSY（b01）：BUSY类型传输使得master可以在burst中间插入空闲周期。这种传输表示master正在继续进行突发操作，但下一次传输无法立即进行。当master用BUSY传输 类型时，地址和控制信号必须反映突发中的下一次传输。只有未定义长度的突发可以将BUSY传输作为突发的最后一个cycle，**slave必须始终对BUSY传输提供零等待状态的OKAY响应，并且slave必须忽略该传输**。
NONSEQ（b10）：表示单次传输或突发（burst）的首次传输。地址和控制信号与之前的传输无关。总线上的单次传输可以被视为长度为1的突发，因此传输类型为NONSEQUENTIAL
SEQ（b11）：突发中的其余传输是SEQUNENTIAL，并且地址与上一次传输相关。控制信息与前一传输相同，该地址等于前一次传输的地址加上传输数据大小（以字节为单位，通过HSIZE[2:0]表征）。在wrapping类型突发的情况下，传输的地址在地址边界自动跳转。





data比控制晚一个周期
![[Pasted image 20220809173825.png]]

为什么需要HSIZE？
有可能只更新一个byte（一个char 类型更改），还有就是一个系统兼容不同位宽的
![[On-Chip-Bus精讲_2截图__2023-03-31-21-08-48.png]]


![[Pasted image 20220809210248.png]]

![[Pasted image 20220817124533.png]]



![[Pasted image 20220817125426.png]]


hready 始终是对data对齐  1 2的hready对其的数据所在的slave可能是不一样的
![[Pasted image 20220817130107.png]]

burst第一个地址不是自己的hready的控制收不收，是上一个slave的hready控制 

![[Pasted image 20220817130515.png]] 
输入输出都有Hready 
输入是来自于bus 切换slave的很重要

[soc进阶-AHB lite的hreadyin和hreadyout - 知乎 (zhihu.com)](https://zhuanlan.zhihu.com/p/610532763)



![[Pasted image 20220817131850.png]]

![[Pasted image 20220817132210.png]]

不能搞：sram从ck2Q的延时比较大，setup hold 更大，
![[Pasted image 20220817132349.png]]

要做高速设计该怎么做？ 
![[Pasted image 20220817132903.png]]


只看第一个地址 后面地址自己产生。**pre fetch思想**
![[Pasted image 20220817133326.png]]

多个master 多个slave 
![[Pasted image 20220817133726.png]]















