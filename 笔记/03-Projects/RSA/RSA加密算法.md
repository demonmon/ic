---
title: RSA加密算法
updated: 2022-04-27T12:34:42.0000000+08:00
created: 2022-04-16T11:43:06.0000000+08:00
---

![image1](image1-27.png)

![image2](image2-23.png)

**计算n的欧拉函数**
欧拉函数：指的是小于n的与n互质的数目
例如n=6 则欧拉函数就为2 （1，5）
若n为质数则欧拉函数为n-1
![image3](image3-20.png)
![image4](image4-18.png)

**第四步计算模反元素d**
![image5](image5-16.png)

![image6](image6-13.png)
![image7](image7-11.png)
例如3，11互质 那么3的模反元素可以取4 3\*4-1=11 模反元素是4+k\*11都是模反元素
![image8](image8-9.png)
由于n非常大 所以计算d也很复杂，需要用到扩展欧几里得算法
公钥：（e，n）
私钥： （d，n）
![image9](image9-9.png)
![image10](image10-9.png)

要证明解密等于M
![image11](image11-8.png)
![image12](image12-8.png)
![image13](image13-7.png)
M的k次 与 n互质才成立

M是明文不会很大 小于pq 故与n互质
举例：
1，p=3 q = 11
2，故n=33
![image14](image14-4.png)
4，取一个e =3
5，取一个d 要满足 3dmod20=1 可以取d等于7
6，公钥：（3，33） 私钥（7，33）

假设M是20
![image15](image15-3.png)
![image16](image16-3.png)

![image17](image17-2.png)

![image18](image18-1.png)

![image19](image19-1.png)

![image20](image20-1.png)
![image21](image21-1.png)

