 
![[Pasted image 20220817144853.png]]

读回应和data绑定在一块就不需要读回应通道
![[Pasted image 20220817145420.png]]


![[Pasted image 20220817145439.png]]

![[Pasted image 20220818202035.png]] 



![[Pasted image 20220818202235.png]]

BUFFER Cache 


![[Pasted image 20220819095820.png]] 

原子操作：
多个master进行读改写就会冲突--原子操作
读改写都是一个master完成的
读操作--改数据--写操作 
    
![[Pasted image 20220819101458.png]]
 

![[Pasted image 20220819103458.png]]





![[Pasted image 20220819104026.png]]




![[Pasted image 20220819104355.png]]


CMD outstanding
![[Pasted image 20220819104637.png]]

如果不同命令的地址对应不同bank 可以把不同bank打开
cmd 0 1 2的数据 可以先回2的数据再回1的数据。。。
ARID相同就必须按顺序，不同可以不按顺序
Out-of-order可针对于多个从机，返回的response可以不按master访问的顺序，慢的可以快，快的可以慢。如果master要求返回的数据必须按照他们访问的顺序来返回，则必须使用相同的ID。如果master不要求按顺序返回数据，则可以通过使用不同的ID来实现乱序传输。 也就是说乱序不乱序的实现是通过master的访问ID来进行控制的，同一个ID必须按照顺序，不同ID可以乱序。
对读命令效果更大 写是单向数据流动
![[Pasted image 20220819104809.png]]

![[Pasted image 20220819105238.png]]

RID与ARID对应

1000 0000
![[Pasted image 20220819110856.png]]



![[Pasted image 20220819111658.png]]

AXI 传输效率更高 综合速度更快 复杂度也更高
![[Pasted image 20220819112526.png]]

burst类型写传输的时序图

![[Pasted image 20220826161122.png]]

INCR

![[Pasted image 20220826161824.png]]


![[Pasted image 20220826162202.png]]


![[Pasted image 20220826162454.png]]

![[Pasted image 20220826162803.png]]

AXI-lite总线信号
![[Pasted image 20220826162850.png]]













