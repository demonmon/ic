## 该学哪个编辑器？

程序员对自己使用的编辑器都有[固执的感情](https://link.zhihu.com/?target=https%3A//en.wikipedia.org/wiki/Editor_war)。

现在最流行的编辑器有哪些？可以参考[Stack Overflow调查](https://link.zhihu.com/?target=https%3A//insights.stackoverflow.com/survey/2019/%23development-environments-and-tools)（结果可能会有些偏差，因为Stack Overflow用户并不能代表全体程序员）。[Visual Studio Code](https://link.zhihu.com/?target=https%3A//code.visualstudio.com/) 是当下最流行的编辑器，而 [Vim](https://link.zhihu.com/?target=https%3A//www.vim.org/) 则是最流行的_基于命令行的_编辑器。

## Vim

这节课的所有导师都将Vim作为自己的编辑器。它有着丰富的历史：从1976年的Vi编辑器发源，直到现在还在不断更新。Vim的背后有着非常简洁的思想，因此，许多工具都支持模拟Vim模式（举个例子，有140万人安装了 [Vim emulation for VS code](https://link.zhihu.com/?target=https%3A//github.com/VSCodeVim/Vim) ）。即使你最后换用别的文本编辑器，Vim大概也是值得一学的。

50分钟内肯定讲不完Vim的所有功能，所以我们将重点解释Vim的理念，教授基础操作，展示一些高级应用并且给出掌握Vim所需的其他资源。

## Vim的理念

编写程序时，我们大多数时间都花在阅读与编辑上，而不是单纯的写。因此，Vim是一个_多模式_编辑器：它在插入文本和操作文本时对应不同的模式。Vim是可编程的（通过Vimscript和其他语言比如Python），它的接口本身就是一种程序语言：按键（有助记名）就是命令，同时这些命令是可以组合的。Vim尽可能避免鼠标的使用，因为太慢了；它甚至避免方向键的使用，因为那需要做很多次移动。

于是就诞生了Vim这个能跟上你思考速度的编辑器。

## 编辑模式

Vim的设计以大多数时间都花在阅读、浏览和稍加改动上为基础，因此有这几种操作模式：

-   **正常模式**：在文件中四处移动光标，做些修改
-   **插入模式**：插入文本
-   **替换模式**：替换文本
-   **可视**（一般，行，块）**模式**：选中文本块
-   **命令模式**：运行命令

不同模式下的按键有不同的功能。例如字母 **x** 在插入模式中就只是插入了一个字符 'x'，而在正常模式中则会删除光标下的字符，在可视化模式下，它会删除被选中的所有内容。

在默认配置下，Vim会在左下角显示当前所处的模式。初始/默认为正常模式，一般来说大多数时间你都会使用正常模式与插入模式。

在任何模式下按 **<ESC>**（左上角退出键）会切换回正常模式。正常模式中，输入 **i** 进入插入（**i**nsert）模式，输入 **R** 进入替换（**R**eplace）模式， 输入 **v** 进入可视（**V**isual）模式，输入 **V** 进入可视行模式，输入 **<C-v>** （Ctrl+V，有时也写作 **^V**）进入可视块模式，命令模式则通过 **:** 进入。

使用Vim时会经常用到 **<ESC>** 键，你可以考虑把 Caps Lock 键映射成退出键（[macOS上的操作指南](https://link.zhihu.com/?target=https%3A//vim.fandom.com/wiki/Map_caps_lock_to_escape_in_macOS)）。

## 基本操作

**插入文本**

在正常模式中，按 **i** 进入插入模式。现在，Vim会表现得像其他大多数文本编辑器一样，直到你按下 **<ESC>** 返回正常模式为止。其实你只需要知道这些就可以开始用Vim编辑文件了（不过只通过插入模式来编辑的话效率不高）。

**Buffer，选项卡和窗口**

Vim维护着一组打开的文件，并称它们为“Buffers（暂存，缓冲）”。一个Vim会话下有数个分页，每个分页中则有数个窗口（分屏的窗格），每个窗口中显示一个buffer。和其他你熟悉的程序，比如网页浏览器不同的是，buffer与窗口之间并没有一一对应的关系，窗口只是用来显示。一个特定的buffer可以在_多个_窗口中被打开，甚至是同一分页下的窗口。这一点有时会很方便，例如，需要同时查看一个文件的两个部分时。

默认情况下，Vim打开时有一个分页，其中包含一个窗口。

**命令行**

命令模式由正常模式下输入 : 进入，你的光标同时会跳转到屏幕底部的命令行。这一模式有许多功能，包括打开、保存和关闭文件，以及[退出Vim](https://link.zhihu.com/?target=https%3A//twitter.com/iamdevloper/status/435555976687923200)。

-   **:q** 退出（关闭窗口）
-   **:w** 保存（“**W**rite”）
-   **:wq** 保存并退出
-   **:e {文件名}** 打开文件以编辑
-   **:ls** 显示目前打开的所有buffer
-   **:help {主题}** 打开帮助

-   **:help :w** 打开 **:w** 命令的帮助
-   **:help w** 打开 **w** 移动的帮助

## Vim的接口就是一种程序语言

Vim中最重要的一个概念就是，Vim的接口本身是一种程序语言。按键（有助记名）即命令，而且它们相互_组合_。这使得高效地移动与编辑成为可能，尤其是当这些命令成为肌肉记忆时。

**移动**

在正常模式下的大多数时间里，你都应该在使用移动命令浏览buffer。Vim中的移动命令也被称为“nouns（名词）”，因为它们本质上指的是某种文字区块。

-   基础移动：**hjkl** （左，下，上，右）
-   词：**w** （下一个词，**w**ord）， **b** （单词开头，**b**eginning），**e** （单词结尾，**e**nd）
-   行：**0** （行的开头），**^** （第一个非空字符）， **$** （行的结尾）
-   屏幕： **H** （屏幕顶端，**H**igh）， **M** （屏幕中央，**M**iddle），**L** （屏幕底端，**L**ow）
-   滚动： **Ctrl-u** （向上，**u**p），**Ctrl-d** （向下，**d**own）
-   文件： **gg** （文件开头）， **G** （文件结束）
-   行数： **:{number}<CR>** 或 **{number}G** (number即行数）
-   多功能： **%** （对应的功能）
-   查找：**f{character}** ， **t{character}** ， **F{character}** ， **T{character}**

-   在当前行中 向前/向后 查找（**f**ind/**F**ind）/前往（**t**o/**T**o）{character}的位置
-   **,** / **;** 在多个匹配结果中切换

-   搜索：**/{regex}** ，用 **n** / **N** 在结果中切换

**选择**

可视模式：

-   可视
-   可视 行
-   可视 块

可以用移动按键来选中文本。

**编辑**

之前所有由鼠标完成的操作，现在你都可以通过键盘将编辑命令与移动命令组合来完成。从这里开始，Vim的接口就开始像程序语言了。Vim的编辑命令被称为“动词”，因为动词对名词进行操作。

-   **i** 进入插入模式

-   但对于操作/删除文本，除了退格之外还有更多方法

-   **o** / **O** 在下一行/上一行插入
-   **d{motion}** 删除{motion}

-   例如， **dw** 是删除单词， **d$** 删除到行尾， **d0** 删除到行首

-   **c{motion}** 修改{motion}

-   例如， **cw** 是修改单词
-   相当于 **d{motion}** 之后接 **i**

-   **x** 删除字符（相当于 **dl** ）
-   **s** 替换（**s**ubstitute）字符（相当于 **xi** ）
-   可视模式+操作

-   选中文本后，用 **d** 来删除或用 **c** 来修改

-   **u** 撤销（**u**ndo），**<C-r>** 恢复（**r**edo）
-   **y** 复制，把文本“拽（**y**ank）”到寄存器里（有些其他的指令比如 **d** 也会复制）
-   **p** 粘贴（**p**aste）
-   还有很多要学的：像是 **~** 会反转字符的大/小写

**计数**

你可以把名词动词与数字结合起来，这会让给定的操作执行一定次数。

-   **3w** 向前移动3个单词
-   **5j** 向下移动5行
-   **7dw** 删除7个单词

**修饰语**

你可以使用修饰语来改变名词的意思。一些修饰语像是 **i** 表示“内部（**i**nner）”或是“里面（**i**nside）”， **a** 则表示“围绕（**a**round）”。

-   **ci(** 修改当前圆括号对中的内容
-   **ci[** 修改当前方括号对中的内容
-   **da'** 删除单引号内的字符串，包括两边的单引号

## 示例

这是一个失败的 [fizz buzz](https://link.zhihu.com/?target=https%3A//en.wikipedia.org/wiki/Fizz_buzz) 实现：

_译注：简单来说就是从1往上数，遇到3的倍数就说fizz，5的倍数就说buzz，15的倍数就说fizz buzz。_

```python
def fizz_buzz(limit):
    for i in range(limit):
        if i % 3 == 0:
            print('fizz')
        if i % 5 == 0:
            print('fizz')
        if i % 3 and i % 5:
            print(i)

def main():
    fizz_buzz(10)
```

我们将要修复如下的问题：

-   Main从未被调用
-   从 0 而不是从 1 开始
-   对于15的倍数“fizz”和“buzz”会分两行输出
-   对5的倍数也输出了“fizz”
-   直接把10写死了，无法接受命令行输入的参数

具体演示在[讲座视频](https://link.zhihu.com/?target=https%3A//www.youtube.com/watch%3Fv%3Da6Q8Na575qc)中（37分30秒开始）。比较用Vim实现这些改动和你用其他的编辑器来做有什么不同。在Vim中只需要很少的按键，这让你编辑的速度和思考一样快。

## 自定义Vim

Vim通过 **~/.vimrc** 中的一个文本配置文件（包括一些Vimscript命令）来自定义。其中可能有一大堆基本选项你都想打开。

我们已经准备了一份写好文档的基础配置，你可以一开始先用着。我们推荐你使用这份配置，因为它修复了Vim本身一些奇怪的默认行为。在[此处](https://link.zhihu.com/?target=https%3A//missing.csail.mit.edu/2020/files/vimrc)下载我们的配置，并保存到 **~/.vimrc** 。

Vim是高度可自定义的，值得花些时间研究一下这些选项。你可以在Github上查看别人的配置文件来找些灵感，比如说，这门课导师们的配置文件（[Anish](https://link.zhihu.com/?target=https%3A//github.com/anishathalye/dotfiles/blob/master/vimrc)，[Jon](https://link.zhihu.com/?target=https%3A//github.com/jonhoo/configs/blob/master/editor/.config/nvim/init.vim)（他用的是[neovim](https://link.zhihu.com/?target=https%3A//neovim.io/)），[Jose](https://link.zhihu.com/?target=https%3A//github.com/JJGO/dotfiles/blob/master/vim/.vimrc)）。这一主题下还有很多优秀的博文。尽量不要直接复制粘贴整个配置文件，而是阅读，理解，然后取你需要的部分。

## 扩展Vim

有非常多的插件可以用来扩展Vim。与你可能在网上找到的那些过时的建议相反，从Vim8.0开始，你_不再_需要一个插件管理器。作为替代，你可以使用内置的包管理系统。只需要新建一个文件夹 **~/.vim/pack/vendor/start/** ，然后把插件放进去（例如通过 **git clone**）就可以了。

这是一些我们最爱的插件：

-   [ctrlp.vim](https://link.zhihu.com/?target=https%3A//github.com/ctrlpvim/ctrlp.vim) ： 文件模糊查询
-   [ack.vim](https://link.zhihu.com/?target=https%3A//github.com/mileszs/ack.vim) ： 代码查找
-   [nerdtree](https://link.zhihu.com/?target=https%3A//github.com/preservim/nerdtree) ： 文件浏览器
-   [vim-easymotion](https://link.zhihu.com/?target=https%3A//github.com/easymotion/vim-easymotion) ：更好的移动

我们尽可能避免在这里列出太长的插件列表。你可以通过导师们的配置文件来查看他们用了哪些插件（[Anish](https://link.zhihu.com/?target=https%3A//github.com/anishathalye/dotfiles)，[Jon](https://link.zhihu.com/?target=https%3A//github.com/jonhoo/configs)，[Jose](https://link.zhihu.com/?target=https%3A//github.com/JJGO/dotfiles)）。查看 [Vim Awesome网站](https://link.zhihu.com/?target=https%3A//vimawesome.com/) 来寻找更多好用的插件。同时也有无数的博客文章：只需要搜索“best Vim plugins（最好用的Vim插件）”就可以。

## 其他程序的Vim模式

许多其他工具都支持模拟Vim。虽说质量参差不齐，取决于具体的工具，不一定支持所有的Vim特性，但大多数都很好的覆盖了基本功能。

**Shell**

如果你是Bash用户，**set -o vi** 。如果你是Zsh用户， **bindkey -v** 。Fish用户使用 **fish_vi_key_bindings**。此外，不管你使用何种shell，都可以使用 **export EDITOR=vim** 。这个环境变量决定了启动编辑器时默认启动哪一个。举例来说， **git** 就会调用编辑器来编辑提交信息。

**Readline**

许多程序都使用 [GNU Readline](https://link.zhihu.com/?target=https%3A//tiswww.case.edu/php/chet/readline/rltop.html) 库作为命令行接口。Readline支持（基础）Vim模拟，可通过将以下内容加入 **~/.inputrc** 文件来启用：

```bash
set editing-mode vi
```

有了这一设置，像 Python REPL 等就会支持Vim键位。

**其他**

甚至[网页浏览器](https://link.zhihu.com/?target=https%3A//vim.fandom.com/wiki/Vim_key_bindings_for_web_browsers)（）都有vim键位扩展，其中一些比较流行的有 Google Chrome 的 [Vimium](https://link.zhihu.com/?target=https%3A//chrome.google.com/webstore/detail/vimium/dbepggeogbaibhgnhhndojpepiihcmeb%3Fhl%3Den) 和 Firefox的 [Tridactyl](https://link.zhihu.com/?target=https%3A//github.com/tridactyl/tridactyl) 。 连 [Jupyter notebooks](https://link.zhihu.com/?target=https%3A//github.com/lambdalisue/jupyter-vim-binding) 都有Vim键位支持。

## 进阶Vim

接下来的一些例子展示了Vim的强大之处。我们无法教给你全部，但你会随着使用慢慢学到。有种启发式学习法：使用编辑器时，每当你觉得“一定有什么更好的方法来做这件事”，就去网上查一下是不是真的有。

**查找与替换**

**:s** （替换，**s**ubstitute）命令 （[文档](https://link.zhihu.com/?target=https%3A//vim.fandom.com/wiki/Search_and_replace)）

-   **%s/foo/bar/g**

-   把文件中所有的foo替换成bar

-   **%s/[._]((._))/\1/g**

-   将所有Markdown文字链接换成地址

**多窗口**

-   **:sp** / **:vsp** 拆分窗口
-   同一个buffer可以被多个窗口查看

**宏命令**

-   **q{character}** 开始录制宏，并保存在寄存器 **{character}** 中
-   **q** 停止录制
-   **@{character}** 运行录制好的宏
-   宏命令遇到错误会中止
-   **{number}@{character}** 将宏执行{number}次
-   宏可以是递归的

-   首先用 **q{character}q** 将宏清空
-   录制宏时，使用 **@{character}** 来递归使用宏（在录制完成前不会执行）

-   举例：将xml转换为json （[文件](https://link.zhihu.com/?target=https%3A//missing.csail.mit.edu/2020/files/example-data.xml)）

-   一个对象数组，键为“name”和"email"
-   要使用Python吗？
-   还是用sed/regexes？

-   **g/people/d**
-   **%s/<person>/{/g**
-   **%s/<name>\(.*\)<\/name>/"name": "\1",/g**
-   ...

-   使用Vim命令/宏

-   **Gdd**，**ggdd** 删除首位行
-   录制格式化一个元素的宏（使用寄存器 **e**）

-   前往有 **<name>** 的行
-   **qe^r"f>s": "<ESC>f<C"<ESC>q**

-   录制格式化一个人物对象的宏

-   前往有 **<person>** 的行
-   **qpS{<ESC>j@eA,<ESC>j@ejS},<ESC>q**

-   录制格式化完成跳转到下一个对象的宏

-   前往有 **<person>** 的行
-   **qq@pjq**

-   执行宏直到文件尾

-   **999@q**

-   手动删除最后的 **,** 并加上 **[ ]** 分隔符

## 资源

-   **vimtutor** Vim安装时自带的教程
-   [Vim Adventures](https://link.zhihu.com/?target=https%3A//vim-adventures.com/) 一个用来学习Vim的游戏
-   [Vim Tips Wiki](https://link.zhihu.com/?target=https%3A//vim.fandom.com/wiki/Vim_Tips_Wiki)
-   [Vim Advent Calendar](https://link.zhihu.com/?target=https%3A//vimways.org/2019/) 有各种Vim小提示
-   [Vim Golf](https://link.zhihu.com/?target=http%3A//www.vimgolf.com/) 是 [code golf](https://link.zhihu.com/?target=https%3A//en.wikipedia.org/wiki/Code_golf) 的Vim UI版
-   [Vi/Vim Stack Exchange](https://link.zhihu.com/?target=https%3A//vi.stackexchange.com/)
-   [Vim Screencasts](https://link.zhihu.com/?target=http%3A//vimcasts.org/)
-   [Practical Vim](https://link.zhihu.com/?target=https%3A//pragprog.com/book/dnvim2/practical-vim-second-edition)（实体书）
-   既然是中文翻译，我自己加一个[中文手册](https://link.zhihu.com/?target=https%3A//sourceforge.net/projects/vimcdoc/files/pdf-manual/)，感谢 Nek_in 的翻译。

## 习题

1.  完成 **vimtutor**。注：在 [80x24](https://link.zhihu.com/?target=https%3A//en.wikipedia.org/wiki/VT100) 尺寸（80列，24行）的终端窗口下显示效果最好。
2.  下载我们的 [basic vimrc](https://link.zhihu.com/?target=https%3A//missing.csail.mit.edu/2020/files/vimrc) 并将其保存到 **~/.vimrc**。使用Vim阅读全文，寻找使用新配置的Vim与之前的不同之处。
3.  安装并配置插件：[ctrlp.vim](https://link.zhihu.com/?target=https%3A//github.com/ctrlpvim/ctrlp.vim)。

1.  使用 **mkdir -p ~/.vim/pack/vendor/start** 创建插件目录
2.  下载插件：**cd ~/.vim/pack/vendor/start; git clone [https://github.com/ctrlpvim/ctrlp.vim](https://link.zhihu.com/?target=https%3A//github.com/ctrlpvim/ctrlp.vim)**
3.  阅读[插件文档](https://link.zhihu.com/?target=https%3A//github.com/ctrlpvim/ctrlp.vim/blob/master/readme.md)。尝试使用它来定位某个文件：进入项目目录，打开Vim，命令行 **:CtrlP**。
4.  通过给 **~/.vimrc** 添加配置来自定义CtrlP，使得按下Ctrl-P就能打开它。

5.  在自己的机器上重现课上的示例（fizz buzz）。
6.  下个月_所有_的文本编辑都用Vim完成。当你发现有不方便的地方，或者你觉得“这肯定有更好的办法”，就去搜索可能的解决方案。如果还有难处，可以给我们发邮件。
7.  把你其他的工具配置成Vim键位（参见上面的说明）。
8.  进一步定制你的 **~/.vimrc** 并安装其他插件。
9.  （进阶）使用Vim宏完成XML到JSON的转换（[示例文件](https://link.zhihu.com/?target=https%3A//missing.csail.mit.edu/2020/files/example-data.xml)）。尝试独立完成，如果遇到困难，可以查看宏那一节。