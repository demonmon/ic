## time check
### DFF setup / hold
### Async Reset / set 
**recovery/ removal**
为什么time检查只检查释放的check 也就是只做reset到set的check 
reset是复位 q端变成确定值，即假设有100个寄存器 检查reset到set（0到1）  有40个reset 60个set.如果检查1-->0.最终都是复位，即使之前没有复位掉，后面0会一直拉着，导致最终还是会是复位掉。
### signal pluse width
高电平宽度是否大于需求
![[Pasted image 20220729161645.png]]

### Clock gate setup / hold 
![[Pasted image 20220729161902.png]]
保证clk_gate出来的时候没有毛刺，太窄就会出现毛刺。


## 什么是综合 
![[Pasted image 20220729162342.png]]

标准单元库

名字：slow

![[Pasted image 20220729163328.png]]

![[Pasted image 20220729164040.png]]


7 * 1 的查找表
![[Pasted image 20220729164124.png]]

![[Pasted image 20220729164413.png]]

![[Pasted image 20220729164437.png]]


index1 ---transi  代表横轴
index 2 ---代表 y轴
离散的 不在点上delay怎么算 他是找出周围四个点的值 通过公式计算
一个点的某个值出界，他会进行往外扩展 外差，，精确度会很差
![[Pasted image 20220729164529.png]]

rise fall 是不一样的 因为管子不一样 
为什么要加上transition，反相器延时是前一级的tran和loading加起来的，所以也要tran 

### clock 描述


![[Pasted image 20220729165703.png]]

jitter：真实值和我标称值的差异的最大值 
duty cycle: 占空比 
transition  ： 爬升时间
phase： 第一个时钟的上升沿和下降沿 相当于0时刻的时间
long-term transition  ： 任意1000（数值不唯一）的cycle相当于理论差多少


![[Pasted image 20220729170205.png]]


![[Pasted image 20220729170904.png]]

**clock input latency**
**clock uncertainty**：jitter （抖动）+ pessimistic  **留一些裕量** 综合没有线延迟信息 
**clock skew**  ： 同一个时钟的同一个沿到不同的DFF/sequential Cell CK PIN 的时间差异

2n个inv和buffer
buffer延迟更大，falldelay一直累加

![[Pasted image 20220729171337.png]]

![[Pasted image 20220729171932.png]]



