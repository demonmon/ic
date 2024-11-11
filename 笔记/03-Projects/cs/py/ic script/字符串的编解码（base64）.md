# 字符串的编解码（base64）

有时候，字符串里含有特殊字符，比如[/]、[@]、[']，或者不可见字符，如Tab，换行。这种特殊字符串不便于直接存储（写到文本或数据库）。

在Python里有一个库，可以把任意字符串编码成可见字符串。这个库就是base64。

## bytes类型与str类型

先做个准备，了解下bytes类型，因为后面的编解码函数用的是这个类型。

bytes是一种字节型数据流，在网络协议包、读写二进制文件等地方应用非常普遍。那bytes与str是怎么转换的呢？下面是一个例子：

```python
b = '123我是ICer'.encode('utf-8')
print(b)
print(type(b))

s = b.decode('utf-8')
print(s)
print(type(s))
```

运行结果如下：

```bash
b'123\xe6\x88\x91\xe6\x98\xafICer'
<class 'bytes'>
123我是ICer
<class 'str'>
```

## base64编码和解码

函数定义：输入是bytes类型，输出也是bytes型。

```python
bytes = base64.b64encode(bytes)
bytes = base64.b64decode(bytes)
```

## 一个例子

直接看例子：

```python
import base64

s0 = '123我是ICer'

# str to bytes
b0 = s0.encode('utf-8')
print(b0)

# 编码
b1 = base64.b64encode(b0)
print(b1)

# 解码
b2 = base64.b64decode(b1)
print(b2)

# bytes to str
s2 = b2.decode('utf-8')
print(s2)
```

实验结果如下：

```bash
b'123\xe6\x88\x91\xe6\x98\xafICer'
b'MTIz5oiR5pivSUNlcg=='
b'123\xe6\x88\x91\xe6\x98\xafICer'
123我是ICer
```