# 二进制转bcd码
![[MM%$PDS7YG4`MDJ[DYVZVDB.png]]

设计要求 11位的有符号转化为17位BCD码
 算法：大于4就加3
Shift and Add-3 Algorithm (consider 8-bit binary) 
1. Shift the binary number left one bit. 
2. 2. If 8 shifts have taken place, the BCD number is in the Hundreds, Tens, and Units column.
3.  3. If the binary value in any of the BCD columns is 5 or greater, add 3 to that value in that BCD column.
4.  4. Go to 1

![[Pasted image 20220604205543.png]]





![[Pasted image 20220604205610.png]]



