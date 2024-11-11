#仲裁器 #FixedPriorityArbiter

# Arbiter设计 
## Arbiter 设计 specification
![[Pasted image 20220610220024.png]]

![[Pasted image 20220610220116.png]]

![[Pasted image 20220610220316.png]]

![[Pasted image 20220610220536.png]]

传一次数据，仲裁一次 不一定一个周期

![[Pasted image 20220610220951.png]]

control flow设计


## 常用Arbiter 算法与电路结构

![[Pasted image 20220610221454.png]]

要从电路结构出发，先有电路再有rtlcode

![[Pasted image 20220610222336.png]]

![[Pasted image 20220610224919.png]]

分别四个固定优先级coding再用多路选择器选择四个固定循环的一种

## 严格的循环优先级Arbiter 电路结构介绍
![[Pasted image 20220612165941.png]]
![[Pasted image 20220612170035.png]]

每两个bit去选择req，req0123永远和mux4to1 ，但每个cur_pri的结果要不一样
后面再接一个固定优先级仲裁器，最后输出端口也要进行转换，固定优先级的输出的id是固定优先级的 输入端口的id，而输入端口真正id是cur_pri 所以mux里面输入不是req0123，而是cur_pri 的每两bit


## 电路结构推广到支持多种仲裁算法
![[Pasted image 20220612171203.png]]
基于带宽分配能否match到我们电路结构。
