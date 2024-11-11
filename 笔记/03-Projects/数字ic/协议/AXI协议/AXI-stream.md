### Keep 与 strobe的区别

### Axi stream中的Byte类型
为了理解keep和strobe之间的关系，需要了解axi stream中的字节类型。
-   Data byte
顾名思义，数据字节，其对应字节为有效数据，既然是有效数据，就必然需要在数据流（stream）中传输。
-   Position byte
位置字节，可以理解为一个占位，比如座位上放一个书包，这个座位上不一定是“有用”的人，但是这个椅子也不能扔（因为要放书包）。所以position byte需要在数据流中传输，但是不需要有有效数据。
-   Null byte
空字节，就是连椅子都可以扔掉，浪费空间的东西。所以在数据流中不传输该比特。

![[Pasted image 20220904165657.png]]

![[Pasted image 20220904165707.png]]

### 区别
区别就是下面表格所示：
![[Pasted image 20220904165718.png]]
如果keep为低，那其实就不能用对应的data了，因为数据流中不包含这一位置对应的字节数据；如果keep为高，那么可以再看strobe，如果strobe为高，那么这个就是数据字节，也就是正常握手信号可以读取和发送的字节，如果strobe为低，那么这个字节位置对应的就是一个position byte，作用就是占位，比如为了packet或者frame对齐。

-   Transfer
一次握手过程对应的信号传输。
-   Packet
一组transfer，类似于axi4的burst，多个transfer的组成。
-   Frame
最高级完整数据，数量大，比如一帧视频数据。

fork
![[Pasted image 20220904184947.png]]

join
![[Pasted image 20220904185546.png]]

## remove

![[Pasted image 20220920190646.png]]


![[Pasted image 20220920192423.png]]


![[Pasted image 20220920192650.png]]

![[Pasted image 20220920193538.png]]


![[Pasted image 20220920200142.png]]




## insert

![[Pasted image 20220922104856.png]]

![[Pasted image 20220922173156.png]]

![[Pasted image 20220922105816.png]]






![[Pasted image 20220922110148.png]]




![[Pasted image 20220922110207.png]]








