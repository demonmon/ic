[ubuntu 22.04 lts 换源报warning - 知乎 (zhihu.com)](https://zhuanlan.zhihu.com/p/545562681)
[(42条消息) 给libc6降级 debian11（安装软件一直碰到depends错误）_西海固子的博客-CSDN博客_libc6 降级](https://blog.csdn.net/AFANTI_JK/article/details/122649163)
[(42条消息) Ubuntu桌面没有图标的解决方案_南上还是北上的博客-CSDN博客_ubuntu桌面图标不见了](https://blog.csdn.net/m0_51100801/article/details/109366128)

## 定义组合体



![[Pasted image 20220925195135.png]]

strtok(  )函数

strtok(  )函数包含于头文件string.h

语法：char *strtok( char *str1, const char *str2 ); 

功能：**函数返回字符串str1中紧接“标记”的部分的指针, 字符串str2是作为标记的分隔符**。如果分隔标记没有找到，函数返回NULL。为了将字符串转换成标记，第一次调用str1 指向作为标记的分隔符。之后所以的调用str1 都应为NULL
说明：首次调用时，s必须指向要分解的字符串，**随后调用要把s设成NULL**。  
strtok在s中查找包含在delim中的字符并用NULL(’\0’)来替换，直到找遍整个字符串。  
返回指向下一个标记串。当没有标记串时则返回空字符NULL。

函数strtok()实际上修改了有str1指向的字符串。  
**每次找到一个分隔符后，一个空（NULL）就被放到分隔符处，函数用这种方法来连续查找该字符串**。


```C
#include <string.h>
#include <stdio.h>

int main()
{
    char *p;
    char str[100]="This is a test ,and you can use it";
    p = strtok(str," "); // 注意，此时得到的 p为指向字符串:"This"，即在第一个分隔  符前面的字符串，即每次找到一个分隔符后，一个空（NULL）就被放到分隔符处，所以此时NULL指针指向后面的字符串："is a test ,and you can use it"。
    
    printf("%s\n",p);  // 此时显示：This
    
    do
    {
        p = strtok(NULL, ",");  // NULL 即为上面返回的指针，即字符串:
                                // "is a test ,and you can use it"。
        if(p)
            printf("|%s",p);
    }while(p);
    
    system("pause");
    return 0;
} 



int main()

{

    char str[80] = "This is - www.runoob.com - website";
    const char s[2] = "-";
    char *token;
    /* 获取第一个子字符串 */
    token = strtok(str, s);
    /* 继续获取其他的子字符串 */
    while (token != NULL)
    {
        printf("%s\n", token);
        token = strtok(NULL, s);
    }
    printf("\n");
    for (int i = 0; i < 80;i++)
       printf("%c", str[i]);
    return (0);

}
```




