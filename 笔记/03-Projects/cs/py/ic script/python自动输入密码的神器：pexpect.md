
> 有时候我们需要，  
> 自动ssh登陆到远程服务器，并执行某个任务，  
> 或者用putty通过ssh协议与服务器来回传文件

最麻烦的是什么？就是每次都要输入密码......

这种重复性的活儿应该交给脚本来做。我们今天就来介绍python的自动输入密码的神器——pexpect。


```python
import sys
import pexpect

child = pexpect.spawn("ssh chenfeng@linuxserver 'ls'", logfile = sys.stdout, encoding="utf-8")

try:
    if(child.expect([pexpect.TIMEOUT, 'password'])):
    child.sendline('12345678')
except:
    print(str(child))

try:
    child.expect([pexpect.TIMEOUT, pexpect.EOF])
except:
    print(str(child))
```

-   第4行：
    -   spawn作用是运行子程序，比如ssh登陆命令：ssh chenfeng@linuxserver 'ls'，其中ls是ssh登陆后的命令，执行完命令自动退出自动执行。
    -   logfile = sys.stdout的作用是把ssh执行的输出结果实时打印到当前终端。默认情况是看不到ssh的执行结果的。encoding=“utf-8”，是指定把ssh的byte类型自动转换成string类型。
-   第7、8行：
    -   expect是作用检测ssh的输出，是否包含'password'字符串。一旦检测到了'password'，就调用sendline来发送密码'12345678'。
-   第13行：
    -   EOF是检测ssh命令退出。





