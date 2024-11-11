# Design for test

![[Pasted image 20221008153549.png]]
![[Pasted image 20221008153718.png]]
自测电路：通常上电时候测试一下 然后转化成正式模式
memory macro ： memory BIST（测mem）
IO PAD ：JTAG / scan chain

![[Pasted image 20221008153942.png]]

要求：
![[Pasted image 20221008154953.png]]

## 缺陷模型

- stuck at 0 一直是0 
	//往mem全写1 如果读出来有1就有这种错误，
- cell delay 
- memo

![[Pasted image 20221008154351.png]]
### STUCK
**D-notation**
左侧是期待值，右侧是观测值
![[Pasted image 20221008155054.png]]

### CELL delay 

测试方法：At speed test 
![[Pasted image 20221008155315.png]]


![[Pasted image 20221008203021.png]]





##  theory of MBIST
如何工作
- 增加一个选择器在用户和BIST选择一个去读写
- 产生测试激励
- 读出来的数据和写进去的比较
![[Pasted image 20221008155615.png]]

结构：
![[Pasted image 20221008155756.png]]



固定addr fail 可以去替换？？
通过烧写把addr的替换方式固定下来
为了提高良率
![[Pasted image 20221008162803.png]]


## scan 原理
- 可控制
- 可观测
- 可对比

 
![[Pasted image 20221008163709.png]]
其实就是shift
可控制 将scan in 移位进去
可观测 将内部值移位出来
![[Pasted image 20221008164445.png]]
**难点怎么生成测试pattern**
![[Pasted image 20221008164234.png]]


推断组合逻辑中间节点的值
中间节点的force 和 观测
**右图没法推断y节点**
![[Pasted image 20221008165110.png]]


ATPG自动测试向量产生工具
![[Pasted image 20221008194943.png]]



接test mode

![[Pasted image 20221008200539.png]]

![[Pasted image 20221008200920.png]]



![[Pasted image 20221008202957.png]]

## 边界扫描

![[Pasted image 20221008203254.png]]


![[Pasted image 20221008203539.png]]

![[Pasted image 20221008203659.png]]


![[Pasted image 20221008204129.png]]



