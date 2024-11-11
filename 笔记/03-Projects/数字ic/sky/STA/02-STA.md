![[Pasted image 20220827205557.png]]


[[时序参数与分析#时序分析]]

- start point

![[Pasted image 20220827213821.png]]

A--combin--B
setup：A在0号上升沿 发出的数据要被B在1号上升沿看到
hold ：A在0号上升沿数据不能被B 0号抓到
画个时序图很容易理解

![[Pasted image 20221026163855.png]]

![[Pasted image 20220827222928.png]]

![[Pasted image 20220827223234.png]]

这是一个临界点


工具检查setup违例
![[Pasted image 20220827223449.png]]

假设芯片已经生产，测试怀疑setup 违例 。如何检查？
![[Pasted image 20220827223711.png]]

1.可以降低时钟频率 周期变大 不等式更容易满足，就可以确定setup有问题
2.还有clk-q 和logic 变小也可以更满足。怎么做小：PVT，把电压提高一点，这样延时就变小 

hold 是大于等于required time
![[Pasted image 20220828145105.png]]
![[Pasted image 20220828145153.png]]

![[Pasted image 20220828145142.png]]



setup是走的上面那条组合逻辑大的线 hold是下面那条组合逻辑小的线，
找的是时序最差的那条路线，保证其可以工作。

![[Pasted image 20220828150209.png]]


增大clk-q logic delay -->PVT ---> 电压 温度降低 
hold 是同一个沿 不能被抓到 和时钟周期没关系


![[Pasted image 20220828150718.png]]

两个时钟频率不一样，直接找沿，两个clock最近的地方。

 ![[Pasted image 20220828151352.png]]

hold检查 要clk1 提前一个沿，然后不能被看到
![[Pasted image 20220828151717.png]]


检查时序时候会把latency关掉，rtl不管tree的delay

对于工具来说，
![[Pasted image 20220828152554.png]]


![[Pasted image 20220828152747.png]]


外部逻辑的delay，内部只有T-d0

![[Pasted image 20220828154824.png]]


![[Pasted image 20220828155129.png]]

然后就是可以脑补前一步逻辑 也就是clk-q+logic 最大是0.6 min ： 0.2 有点类似hold




![[Pasted image 20220828155520.png]]

**注意为什么是-2??**
首先clk-out 至少2 至多6，所以外部逻辑可以为负数但也只能最小-2，要保证总共还是要大于等于0
其实本质就是setup hold
![[Pasted image 20220828161449.png]]


[2.3.5.2. 输出约束(set_output_delay) (intel.cn)](https://www.intel.cn/content/www/cn/zh/docs/programmable/683068/18-1/output-constraints-set-output-delay.html)




![[Pasted image 20220828153112.png]]

![[Pasted image 20220828153146.png]]

例如跨时钟域就需要设置

下面两条命令加起来是右边，
只有上面那条就是左边
![[Pasted image 20220828165009.png]]



![[Pasted image 20220828170246.png]]





![[Pasted image 20220828153619.png]]


![[Pasted image 20220828154116.png]]

0.5-0.3+10ns-0.55-0.65 ？>= 0.25


![[Pasted image 20220828154750.png]]

## setup / hold  计算


![[Pasted image 20220828161803.png]]


data time ： 1+2+2* 3 + Tsu
required  : 1+1+T
required  >=  data time 
2+T >= 12


![[Pasted image 20220828163925.png]]




