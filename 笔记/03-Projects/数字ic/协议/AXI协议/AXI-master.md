![[Pasted image 20221008212016.png]]


## master_read

![[Pasted image 20221004111217.png]]



![[Pasted image 20221004130849.png]]

拆成至少三拍来做

![[Pasted image 20221005125631.png]]


![[Pasted image 20221004192044.png]]

![[Pasted image 20221004203914.png]]


**只在第一次会去处理4k的burst的长度，后面256是刚刚好对齐到4k边界也就是说不会跨域并且长度也不需要再去根据4K边界去该长度len**
只要第一次burst的len对齐到1k 则后面再发256beat也是1k
 


![[Pasted image 20221004205658.png]]


![[Pasted image 20221004205822.png]]


![[Pasted image 20221004210700.png]]


![[Pasted image 20221004212114.png]]



![[Pasted image 20221004222311.png]]
 

![[Pasted image 20221004222448.png]]


![[Pasted image 20221004223006.png]]

 
![[Pasted image 20221004223307.png]]

![[Pasted image 20221004223321.png]]

![[Pasted image 20221004224132.png]]


![[Pasted image 20221005122819.png]]



![[Pasted image 20221005124253.png]]



  ![[Pasted image 20221005124506.png]]
![[Pasted image 20221005131027.png]]


outstanding

![[Pasted image 20221005131130.png]]

![[Pasted image 20221005131459.png]]


![[Pasted image 20221005131927.png]]

![[Pasted image 20221005132254.png]]



![[Pasted image 20221005132840.png]]

![[Pasted image 20221005132802.png]]

需要地址对齐
![[Pasted image 20221005125157.png]]

busy的第一拍

![[Pasted image 20221005125705.png]]


 ![[Pasted image 20221005132955.png]]


![[Pasted image 20221005130646.png]]


![[Pasted image 20221005133345.png]]


![[Pasted image 20221005133508.png]]


![[Pasted image 20221005133707.png]]

![[Pasted image 20221005133733.png]]






























## master_write
写请求没有outstanding 

![[Pasted image 20230329165813.png]]

![[Pasted image 20221008210834.png]]

![[Pasted image 20221008210921.png]]

同样需要三拍操作：
![[Pasted image 20221008211143.png]]


cmd_addr 一定是处理好的对齐的
![[Pasted image 20221008211744.png]]

![[Pasted image 20221008211920.png]]




![[Pasted image 20221008224508.png]]



![[Pasted image 20221008225403.png]]

![[Pasted image 20221008225847.png]]

![[Pasted image 20221008230520.png]] 

这里因为写操作没有outstanding 所以只能一个写请求完成之后再进行下一个写请求，那么你如果需要这个写请求完成再去发awvalid的时候，只要不是写数据最后一拍握手那么前面都得是0，或者写请求阻塞也得是0
![[Pasted image 20221008231617.png]]



![[Pasted image 20221008230850.png]]


![[Pasted image 20221008231841.png]]


![[Pasted image 20221009111321.png]]


![[Pasted image 20221009111425.png]]


![[Pasted image 20221009111740.png]]


![[Pasted image 20221009114221.png]]

计算剩下多少拍没发
![[Pasted image 20221009114410.png]]


![[Pasted image 20221009120243.png]]


![[Pasted image 20221009122657.png]] 

![[Pasted image 20221009122743.png]]

![[Pasted image 20221009122755.png]]


![[Pasted image 20221009122945.png]]

![[Pasted image 20221009123118.png]]


![[Pasted image 20221009124220.png]]

![[Pasted image 20221009124303.png]]

![[Pasted image 20221009124358.png]]



![[Pasted image 20221009124657.png]]


![[Pasted image 20221009124755.png]]



