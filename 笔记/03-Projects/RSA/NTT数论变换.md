---
title: NTT数论变换
updated: 2022-05-29T21:16:45.0000000+08:00
created: 2022-05-27T20:41:57.0000000+08:00
---

现在的主要问题是如何快速的将多项式的系数表示法转为点表示法进行运算，然后快速的转为系数表示法，DFT可以在O(nlog2n)时间内将系数表示法转为为点表示法，IDFT可以在O(nlog2n)时间内将点表示法转为系数表示法。

背景知识DFT

为了方便求解n，一般取2的整次幂。如果暴力的找n个点带入多项式求解，复杂度将达到O(x2),但如果带入一些特殊的点将大大运算。

![image1](image1.jpg)

记编号为k的点代表的复数值为 \[公式\] ,根据模长相乘，极角相加可知 \[公式\] ，其中 \[公式\] 称为n次单位根，每个 \[公式\] 都可以求出：
![image2](image2-24.png)
用图表示为：
![image3](image3-21.png)

![image4](image4-19.png)

简化运算证明

DFT

![image5](image5.jpg)
![image6](image6.jpg)

![image7](image7-12.png)
那这里如何转化为点的表示法？

因为可以选取任意n个不同点所构成的集合，所有一个多项式可以有**很多不同的点值表达** 把任意n个点构成的集合叫做**点值表达的基**
从点值表达的基入手，选取适当的xk来优化多项式乘法效率，为此，我们选取单位复数根作为多项式的基
![image8](image8-10.png)

利用下面两个公式去求 因为A1 A2都是已知的

![image9](image9-10.png)

![image10](image10-10.png)
![image11](image11-9.png)
![image12](image12-9.png)

![image13](image13-8.png)

![image14](image14-5.png)

![image15](image15-4.png)
![image16](image16.jpg)

以上就是傅里叶变换，，

![image17](image17-3.png)
**IDFT**
将点值表示的多项式转化为系数表示，同样可以使用快速傅里叶变换，这个过程称为**傅里叶逆变换**。
设(y0,y1,…,yn−1),(y0,y1,…,yn−1)为(a0,a1,…,an−1)(a0,a1,…,an−1)的傅里叶变换。

![image18](image18-2.png)

![image19](image19-2.png)

![image20](image20-2.png)

![image21](image21-2.png)

![image22](image22.png)

![image23](image23.png)

![image24](image24.png)

![image25](image25.png)

![image26](image26.png)


