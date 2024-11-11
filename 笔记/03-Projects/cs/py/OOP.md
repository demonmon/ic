
## 类(Class)和实例(Instance)

面向对象设计思想来自自然界，主要概念是：类(Class)和实例(Instance)

Class 是一种抽象的概念，例如 鸟类 ; Instance 是根据类抽象的模版创建的具体的，比如 大雁 就是鸟类中具体的实例

### 1.类的定义
```python
class Student(object):
  pass

```
Student 是类名— 通常大写开头
object 是表示继承的类，如果没有，一般使用 object
继承和不继承object的区别—详见[参考](https://www.jianshu.com/p/6b3cc4de599a)
```python

```

**在 python 3 中，括号没不加 object，也会默认 继承 object**

### 2.创建实例

```python
liu = Student()
>>> liu
<__main__.Student object at 0x106a03358>
>>> Student
<class '__main__.Student'>

```
### 3.绑定属性
**可以在实例中绑定属性**
由于类的作用就是一个模版，对于一些共有的属性可以写入类之中。 例如定义一个鸟的类，共性就是会飞，这个属性就可以写进,而这个 通过 init 实现

```python
class Student(object):

    def __init__(self, name, score):
      """
      前后各有两个下划线
      """
        self.name = name
        self.score = score

```
第一个参数永远是 self，self 是创建的实例本身—详见[参考](http://python.jobbole.com/81921/)

```python
class Test():
 def prt(self):
   print(self)
   print(self.__class__)

>>> T = Test()
>>> T.prt()
<__main__.Test object at 0x106a035c0>
<class '__main__.Test'>

```

观察上面的测试代码，self 代表的是 类的实例，并且直接指向 Test 类
self 之后加入其他的参数，在定义类的时候需要传入，**self 不需要传入**

## 数据封装

由于 Student 实例 本身就包含了 name 和 score 等数据，我们访问这些数据，可以直接在类的内部定义访问数据的函数

```python
class Student(object):

    def __init__(self, name, score):
        self.name = name
        self.score = score

    def print_score(self):
        print('%s: %s' % (self.name, self.score))

```

## 访问限制

在Class内部，可以有属性和方法，而外部代码可以通过直接调用实例变量的方法来操作数据，这样，就隐藏了内部的复杂逻辑。

但是，从前面Student类的定义来看，外部代码还是可以自由地修改一个实例的`name`、`score`属性：
![[Pasted image 20221015150130.png]]

如果要让内部属性不被外部访问，可以把属性的名称前加上两个下划线`__`，在Python中，实例的变量名如果以`__`开头，就变成了一个私有变量（private），只有内部可以访问，外部不能访问，所以，我们把Student类改一改：

![[Pasted image 20221015150221.png]]


## 继承和多态


当我们定义一个class的时候，可以从某个现有的class继承，新的class称为子类（Subclass），而被继承的class称为基类、父类或超类（Base class、Super class）
对于`Dog`来说，`Animal`就是它的父类，对于`Animal`来说，`Dog`就是它的子类。`Cat`和`Dog`类似。
继承有什么好处？最大的好处是子类获得了父类的全部功能。由于`Animial`实现了`run()`方法，因此，`Dog`和`Cat`作为它的子类，什么事也没干，就自动拥有了`run()`方法：

```python
#父类
class Animal(object):
  def run(self):
    print('Animal is running...')
## 子类继承了父类所有的属性和方法，同时定义自己的属性和方法        
class Dog(Animal):
  def run(self):
    print('Dog is running...')
  def eat(self): #增加自己方法
    print('Eating meat...')
class Cat(Animal):
  def run(self):
    print('Cat is running...')
dog = Dog()
dog.eat()
```

当子类和父类都存在相同的`run()`方法时，我们说，子类的`run()`覆盖了父类的`run()`，在代码运行的时候，总是会调用子类的`run()`。这样，我们就获得了继承的另一个好处：`多态`。

要理解什么是多态，我们首先要对数据类型再作一点说明。当我们定义一个class的时候，我们实际上就定义了一种数据类型。我们定义的数据类型和Python自带的数据类型，比如str、list、dict没什么两样：
```python
a = list() # a是list类型
b = Animal() # b是Animal类型
c = Dog() # c是Dog类型
```

```python
>>> isinstance(a, list)
True
>>> isinstance(b, Animal)
True
>>> isinstance(c, Dog)
True
```

但是等等，试试:
```python
 isinstance(c, Animal)
True
```

看来`c`不仅仅是`Dog`，`c`还是`Animal`！

不过仔细想想，这是有道理的，因为`Dog`是从`Animal`继承下来的，当我们创建了一个`Dog`的实例`c`时，我们认为`c`的数据类型是`Dog`没错，但`c`同时也是`Animal`也没错，`Dog`本来就是`Animal`的一种！

所以，在继承关系中，如果一个实例的数据类型是某个子类，那它的数据类型也可以被看做是父类。但是，反过来就不行：

```python
b = Animal()
>>> isinstance(b, Dog)
False
```


```python

def run_twice(animal):
    animal.run()
    animal.run()

run_twice(Animal())
run_twice(Dog())
class Tortoise(Animal):
    def run(self):
        print('Tortoise is running slowly...')
run_twice(Tortoise())
```
你会发现，新增一个`Animal`的子类，不必对`run_twice()`做任何修改，实际上，任何依赖`Animal`作为参数的函数或者方法都可以不加修改地正常运行，原因就在于多态。

由于Animal类型有run()方法，因此，传入的任意类型，只要是Animal类或者子类，就会自动调用实际类型的run()方法

多态的好处就是，当我们需要传入`Dog`、`Cat`、`Tortoise`……时，我们只需要接收`Animal`类型就可以了，因为`Dog`、`Cat`、`Tortoise`……都是`Animal`类型，然后，按照`Animal`类型进行操作即可。由于`Animal`类型有`run()`方法，因此，传入的任意类型，只要是`Animal`类或者子类，就会自动调用实际类型的`run()`方法，这就是多态的意思：

对于一个变量，我们只需要知道它是`Animal`类型，无需确切地知道它的子类型，就可以放心地调用`run()`方法，而具体调用的`run()`方法是作用在`Animal`、`Dog`、`Cat`还是`Tortoise`对象上，由运行时该对象的确切类型决定，这就是多态真正的威力：调用方只管调用，不管细节，而当我们新增一种`Animal`的子类时，只要确保`run()`方法编写正确，不用管原来的代码是如何调用的。这就是著名的“开闭”原则：

- 对扩展开放：允许新增`Animal`子类；
- 对修改封闭：不需要修改依赖`Animal`类型的`run_twice()`等函数。

继承还可以一级一级地继承下来，就好比从爷爷到爸爸、再到儿子这样的关系。而任何类，最终都可以追溯到根类object，这些继承关系看上去就像一颗倒着的树。比如如下的继承树：


```ascii
┌───────────────┐
                │    object     │
                └───────────────┘
                        │
           ┌────────────┴────────────┐
           │                         │
           ▼                         ▼
    ┌─────────────┐           ┌─────────────┐
    │   Animal    │           │    Plant    │
    └─────────────┘           └─────────────┘
           │                         │
     ┌─────┴──────┐            ┌─────┴──────┐
     │            │            │            │
     ▼            ▼            ▼            ▼
┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐
│   Dog   │  │   Cat   │  │  Tree   │  │ Flower  │
└─────────┘  └─────────┘  └─────────┘  └─────────┘
```

##  静态语言 vs 动态语言
对于静态语言（例如Java）来说，如果需要传入`Animal`类型，则传入的对象必须是`Animal`类型或者它的子类，否则，将无法调用`run()`方法。
对于Python这样的动态语言来说，则不一定需要传入`Animal`类型。我们只需要保证传入的对象有一个`run()`方法就可以了：
```python
class Timer(object):
    def run(self):
        print('Start...')
```

这就是动态语言的“鸭子类型”，它并不要求严格的继承体系，一个对象只要“看起来像鸭子，走起路来像鸭子”，那它就可以被看做是鸭子。

Python的“file-like object“就是一种鸭子类型。对真正的文件对象，它有一个`read()`方法，返回其内容。但是，许多对象，只要有`read()`方法，都被视为“file-like object“。许多函数接收的参数就是“file-like object“，你不一定要传入真正的文件对象，完全可以传入任何实现了`read()`方法的对象。

## 获取对象信息

当我们拿到一个对象的引用时，如何知道这个对象是什么类型、有哪些方法呢？

### 使用type()

首先，我们来判断对象类型，使用`type()`函数：
基本类型都可以用`type()`判断：
```python
>>> type(123)
<class 'int'>
>>> type('str')
<class 'str'>
>>> type(None)
<type(None) 'NoneType'>

a=Animal()
print(type(a))
>>> <class '__main__.Animal'>

```


但是`type()`函数返回的是什么类型呢？它返回对应的Class类型。如果我们要在`if`语句中判断，就需要比较两个变量的type类型是否相同:

```
>>> type(123)==type(456)
True
>>> type(123)==int
True
>>> type('abc')==type('123')
True
>>> type('abc')==str
True
>>> type('abc')==type(123)
False
```


### 使用isinstance()

对于class的继承关系来说，使用`type()`就很不方便。我们要判断class的类型，可以使用`isinstance()`函数。

我们回顾上次的例子，如果继承关系是：
```
object -> Animal -> Dog -> Husky
```
那么，`isinstance()`就可以告诉我们，一个对象是否是某种类型。先创建3种类型的对象：
```
>>> a = Animal()
>>> d = Dog()
>>> h = Husky()
>>isinstance(h, Husky)
True
>>isinstance(h, Dog)
True
>>> isinstance(h, Animal)
True

```

能用`type()`判断的基本类型也可以用`isinstance()`判断：

```
>>> isinstance([1, 2, 3], (list, tuple))
True
>>> isinstance((1, 2, 3), (list, tuple))
True
```

### 使用dir()

如果要获得一个对象的所有属性和方法，可以使用`dir()`函数，它返回一个包含字符串的list，比如，获得一个str对象的所有属性和方法：

```
>>> dir('ABC')
['__add__', '__class__',..., '__subclasshook__', 'capitalize', 'casefold',..., 'zfill']
```

类似`__xxx__`的属性和方法在Python中都是有特殊用途的，比如`__len__`方法返回长度。在Python中，如果你调用`len()`函数试图获取一个对象的长度，实际上，在`len()`函数内部，**它自动去调用该对象的`__len__()`方法**，所以，下面的代码是等价的： ^jpjy1k

```
>>> len('ABC')
3
>>> 'ABC'.__len__()
3
```

我们自己写的类，如果也想用`len(myObj)`的话，就自己写一个`__len__()`方法：
```python
>>> class MyDog(object):
...     def __len__(self):
...         return 100
...
>>> dog = MyDog()
>>> len(dog)
100
```

仅仅把属性和方法列出来是不够的，配合`getattr()`、`setattr()`以及`hasattr()`，我们可以直接操作一个对象的状态：
```python
obj = MyObject()
print(hasattr(obj, 'x')) # 有属性'x'吗？
print(hasattr(obj, 'y')) # 有属性'y'吗？
setattr(obj, 'y', 19) # 设置一个属性'y'
print(hasattr(obj, 'y')) # 有属性'y'吗？
print(getattr(obj, 'y')) # 获取属性'y'
print(obj.y) # 获取属性'y'

```

```
>>> getattr(obj, 'z') # 获取属性'z'
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
AttributeError: 'MyObject' object has no attribute 'z'
```


可以传入一个default参数，如果属性不存在，就返回默认值：

```
>>> getattr(obj, 'z', 404) # 获取属性'z'，如果不存在，返回默认值404
404
```

```python
>>> hasattr(obj, 'power') # 有属性'power'吗？
True
>>> getattr(obj, 'power') # 获取属性'power'
<bound method MyObject.power of <__main__.MyObject object at 0x10077a6a0>>
>>> fn = getattr(obj, 'power') # 获取属性'power'并赋值到变量fn
>>> fn # fn指向obj.power
<bound method MyObject.power of <__main__.MyObject object at 0x10077a6a0>>
>>> fn() # 调用fn()与调用obj.power()是一样的
81
```


假设我们希望从文件流fp中读取图像，我们首先要判断该fp对象是否存在read方法，如果存在，则该对象是一个流，如果不存在，则无法读取。`hasattr()`就派上了用场。

请注意，在Python这类动态语言中，**根据鸭子类型，有`read()`方法，不代表该fp对象就是一个文件流，它也可能是网络流，也可能是内存中的一个字节流，但只要`read()`方法返回的是有效的图像数据，就不影响读取图像的功能。**
```
def readImage(fp):
    if hasattr(fp, 'read'):
        return readData(fp)
    return None
```

## 实例属性和类属性

给实例绑定属性的方法是通过实例变量，或者通过`self`变量
```python
class Student(object):
    def __init__(self, name):
        self.name = name

s = Student('Bob') #self
s.score = 90
```

但是，如果`Student`类本身需要绑定一个属性呢？可以直接在class中定义属性，这种属性是类属性，归`Student`类所有：

```
class Student(object):
    name = 'Student'
```

```python
>>> class Student(object):
...     name = 'Student'
...
>>> s = Student() # 创建实例s
>>> print(s.name) # 打印name属性，因为实例并没有name属性，所以会继续查找class的name属性
Student
>>> print(Student.name) # 打印类的name属性
Student
>>> s.name = 'Michael' # 给实例绑定name属性
>>> print(s.name) # 由于实例属性优先级比类属性高，因此，它会屏蔽掉类的name属性
Michael
>>> print(Student.name) # 但是类属性并未消失，用Student.name仍然可以访问
Student
>>> del s.name # 如果删除实例的name属性
>>> print(s.name) # 再次调用s.name，由于实例的name属性没有找到，类的name属性就显示出来了
Student
```

从上面的例子可以看出，在编写程序的时候，千万不要对实例属性和类属性使用相同的名字，因为相同名称的实例属性将屏蔽掉类属性，但是当你删除实例属性后，再使用相同的名称，访问到的将是类属性。



- 实例属性属于各个实例所有，互不干扰；

- 类属性属于类所有，所有实例共享一个属性；

- 不要对实例属性和类属性使用相同的名字，否则将产生难以发现的错误
















