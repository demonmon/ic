## 寄存器文件
寄存器文件：

寄存器文件
```verilog

//link list 的信息 r/w, 一个link list代表一个2D cmd
reg [31:0] cfg_sar;
reg [31:0] cfg_dar;
reg [15:0] cfg_trans_xsize;
reg [15:0] cfg_trans_ysize;
reg [15:0] cfg_sa_step;
reg [15:0] cfg_da_step;
reg [31:0] cfg_ll_addr;//cfg_llr

// dma 状态寄存器
reg  [7:0]   dma_cmd_num;
reg  dma_busy;
reg  dma_intr;//结束--1  SW写0清除（来自APB 对应地址的写数据）
reg  intr_en;//中断寄存器，1：就可以允许结束时候发生中断
reg  dma_halt;//1:暂停AXI BUS接口数据传输；
reg  dma_sof;//1:启动一个DMA传输
```





## 读命令产生


buffer 接口  寄存器接口  BUS接口
缓存有效数据


整个burst传输完以后，要注意是否有额外的fifo写
有额外的写的话就需要多一个或一个写使能
![[Pasted image 20230621154953.png]]


![[af2ea39531fda98ddad4c80bb59e9027.jpeg]]
![[40764c93bc8ef82bdea770cbcda98659.jpeg]]
```verilog
//buf_byte : 有几个buffer存了数据
if(rbe[0] & (buf_byte[1:0] == 0))
	buf0 <= rdata[7:0];
else if (rb[1] & (buf_byte[1:0] == 0) & (!rbe[0]))
	buf0 <= rdata[15:8]

if(rbe[0] & (buf_byte[1:0] == 1))
	buf1 <= rdata[7:0];
else if (rb[1] & (buf_byte[1:0] + rbe[0] == 1))
	buf1 <= rdata[15:8]
else if (rb[2] & (buf_byte + {2'b00,rbe[0]} + {2'b00rbe[1] == 1))
	buf1 <= rdata[23:16]	   
```



![[Pasted image 20230621161255.png]]




![[Pasted image 20230621154908.png]]


## bug



![[Pasted image 20230829104449.png]]

![[Pasted image 20230829104530.png]]
写数据有两拍错误












