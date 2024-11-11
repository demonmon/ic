# SAD计算
![[Pasted image 20220604210230.png]]
![[Pasted image 20220607111543.png]]



![[Pasted image 20220604210051.png]]


256个数的累加分成 行加之后再 列加 256 --> 16 --> 1(SAD) 
   每一级同时计算16个

16 * 16 对半分开
![[Pasted image 20220604210929.png]]

第一级同时计算8个
第二级横着对半分 
第三级计算4个  是一个三级pipeline

![[Pasted image 20220604211331.png]]

四级pipeline 并且每一级计算数据个数都是4个

pipeline结构：
![[Pasted image 20220604211430.png]]





![[Pasted image 20220604211658.png]]



测试点分析
![[Pasted image 20220604212534.png]]
需要有model去跟rtl自动对比
