![[Pasted image 20220809151732.png]]

地址路由


![[Pasted image 20220809151835.png]]

addr 加1相当于加4字节
 
![[Pasted image 20220809152213.png]]
![[Pasted image 20220809153331.png]]

slave通过地址低位路由，arbiter用高位路由


![[Pasted image 20220809153448.png]]

![[Pasted image 20220809153543.png]]

0x8000_C000 并没有分配到slave上按道理应该报error，但是通过高位译码会选择sram
![[Pasted image 20220809155846.png]]

## APB




 







