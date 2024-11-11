![[Pasted image 20220808211814.png]]

![[Pasted image 20220808212128.png]]

DDR行为 -- 类似央行 所有数据都需要经过
cahce -- 类似于手机 -- 不需要从终端取数据

为什么需要总线？
1.统一标准 --- 很多ip不是自己做的。
2.互联很好，增加master，bus改一下增加一个口就行。不需要增加那么多线
带宽：
每秒传输多少数据量  100M -- 每秒传输100byte数据 
和时钟频率 线宽有关系

### DDR行为
先分bank 再分行 再看列 
![[Pasted image 20220808214347.png]]

ddr要给一个bank地址和row地址 再发cloum选中该列进行读写
一次ddr需要发两次地址。
某一时刻 只能打开一个ROW。 想打开另外一个需要关闭（pre），再act
双沿传输

![[Pasted image 20220809111915.png]]   
![[Pasted image 20220809111952.png]]

效率太低，有效带宽小？？

![[Pasted image 20220809112114.png]]

把不同bank指令掺和在一起，这样可以充分利用dq输出，输出可以靠得很近。
bank所有指令都是串行

cache
降低带宽 提高效率
![[Pasted image 20220809114506.png]]

hit：访问地址在cache有
miss得去获取
miss为什么有两种行为
read through的必要性：
1.容量有限，有些数据不是经常访问的（读一下，写一下）所以没有必要写进去cache
2.如果地址不是ddr 是uart的tx传输来的数据， 就不能read allocate


![[Pasted image 20220809114727.png]]

write back:最后更新到终端  100次最后就相当于写了一次
write through : 一致性问题 对于一个地址空间不只是cpu再用，共享的一段数据。写进去其他的master还要去看，大家都要从这去读或者去写，所以不能仅仅写在cpu的cache。浪费写的带宽，节省读的带宽。
miss为什么有no write allocate 
和read不需要allocate 是一样，写给uart数据，不能把最后一个写的数据给uart

![[Pasted image 20220809131229.png]]

为什么需要这些操作：
inva：比如微信切换到qq 微信的占用缓存空间可以清除掉
flush：比如图片的像素点先算好然后一下推送给终端


![[Pasted image 20220809133058.png]]


cache line ： cache最小单元


![[Pasted image 20220809134944.png]]



![[Pasted image 20220809135327.png]]















