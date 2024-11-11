## SOC概述
![[Pasted image 20221017210824.png]]
![[Pasted image 20221017210740.png]]
![[Pasted image 20221017211140.png]]
### 发展与挑战
- 集成密度
- 时序收敛
- 信号完整性
- 低功耗设计
- 可制造性设计以及良品率
### SOC设计流程
![[Pasted image 20221017211456.png]]


![[Pasted image 20221017211550.png]]

## 系统互联架构

![[Pasted image 20221017211658.png]]

![[Pasted image 20221017211844.png]]


![[Pasted image 20221017211952.png]]

交叉的地方是开关，不能同时连
比较占面积，早期的架构。


### NOC互联架构



![[Pasted image 20221017212314.png]]


二维mesh架构 定死的路线，本质做仲裁


![[Pasted image 20221017212720.png]]



![[Pasted image 20221017212926.png]]

改进之后每个router都是四个方向+一个本地ip方向

![[Pasted image 20221017213029.png]]


- 又增加ip
![[Pasted image 20221017213137.png]]


一个router
![[Pasted image 20221017213207.png]]

四个router
![[Pasted image 20221017213231.png]]

![[Pasted image 20221017213302.png]]
优点
- 数据传输可靠，采用基于报文交换的思想
- 可拓展性强
- 功耗低 采用GALS


## IP

![[Pasted image 20221017213423.png]]

前端设计常用软核和固核

## 综合
![[Pasted image 20221017213517.png]]

![[Pasted image 20221017213903.png]]
![[Pasted image 20221017213916.png]]

![[Pasted image 20221017213936.png]]


## [[DFT]] 


![[Pasted image 20221017214223.png]]


## 低功耗设计 

![[Pasted image 20221017214319.png]]



![[Pasted image 20221017214353.png]]
![[Pasted image 20221017214500.png]]
静态：
- 多阈值
- 电源门控
动态：
- 多电压域
- 预计算


## 计算机体系架构

软硬件交互的过程
![[Pasted image 20221017214656.png]]


cpu和内存交互
x86冯诺依曼架构指令数据一体


![[Pasted image 20221017214815.png]]


ARM架构是哈佛架构 ，指令数据分开存
![[Pasted image 20221017215057.png]]



数据一致性？存储架构是分层的，寄存器？SRAM还是占面积-->多级cache



![[Pasted image 20221017215152.png]]





































