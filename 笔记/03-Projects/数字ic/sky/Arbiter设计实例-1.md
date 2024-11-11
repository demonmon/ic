#仲裁器设计
# 仲裁器的设计
## 仲裁器介绍
仲裁器Arbiter是数字设计中非常常见的模块，应用也非常广泛。定义就是当有两个或两个以上的模块需要占用同一个资源的时候，我们需要由仲裁器arbiter来决定哪一个模块来占有这个资源。
一般来说，提出占有资源的模块要产生一个请求(request)，所有的请求送给仲裁器之后，仲裁器要返回一个许可(grant)。
仲裁器很重要的一点是只能让一个模块得到许可，因为这个资源某一时刻只能由**一个模块**占用。在数字电路中，**总线仲裁**是一个常见的例子，比如多个master要占用总线来去写数据，那么需要仲裁器来许可哪个master来占用总线。

## 固定优先级仲裁器（fixed priority)
固定优先级，顾名思义，就是说每个模块的优先级是固定的，是提前分配好的，如果有两个模块同时产生request，那么优先级高的模块可以获得grant

那如果我们要设计一个fixed priority 输入则是multibit request，每一个bit代表一个模块的request， 输出一个multibit grant，每个bit代表给对应的模块的grant信号。我们可以把优先级这样安排，**最低位优先级最高，最高位优先级最低。**
对应的电路则是具有优先级的选择器。
以四个模块产生request 为例 ：
```verilog
module fixed_pri_arb(
			input [3:0] req;
			output reg [3:0] grant
			);
			
			
	always@(*)begin
		case(1'b1)
			req[0]:grant = 4'b0001;
			req[1]:grant = 4'b0010;
			req[2]:grant = 4'b0100;
			req[3]:grant = 4'b1000;
			default: grant = 3'b0000;
		endcase
	end
    //if else if 
	always @(*)begin
		if(req [0] ) grant = 4'b0001;
		else if(req[1]) grant = 4'b0010;
		else if(req[2]) grant = 4'b0100;
		else if(req[3]) grant = 4'b1000;
		else grant = 4'b0000;
	end
	
endmodule

```
这里的技巧是利用[verilog](https://so.csdn.net/so/search?q=verilog&spm=1001.2101.3001.7020)中的case语句，可以比用if else简洁，而且利用了**case里的按顺序evaluate语法规则**来实现了优先级。
也可以用if else if 去写

![[Pasted image 20220610221454.png]]

**那如何设计一个参数化模块呢**
因为参数化的话，不能使用case语句，因此首先想到的是**for循环语句**。  
思路其实非常直接，**从低位到高位依次去判断**，借助一个pre_req来记录低位是否已经有了request， 如果第i位有了request，那么第i+1位一直到最高位的pre_req都是1。
**pre_req是为了记录低位是否已经有了request,例如当pre_req[4]=1时，即说明req的低五位已经有了request，即此时grant[5] = 0;**
pre_req 如何记录呢？req=10010
pre=xxx10-->...-->pre=**11110** grant=00010
......pre=11110 `0表示低位没有req，1表示低位或者当位有req`
......req=00110
......gnt=00010 
如果是后面的写法 
> pre_req[i] = pre_req [i-1] | req[i-1]
这样会使1那一位的pre不是1
req = 00110 
pre = 11100
gnt = grant[i] = req[i]&!pre_req[i-1];不能适用
也就是改成：
gnt[i] = req[i] & !pre[i]

```verilog
module fixed_pri_arb#(
			parameter REQ_WIDTH = 16)
		(
			input [ REQ_WIDTH-1:0] req;
			output reg [ REQ_WIDTH-1:0] grant
			);
			
			
	reg [REQ_WIDTH-1] pre_req;//为了记录低位是否已经有了request。


	always@(*)begin
		pre_req[0] = req[0];
		grant[0] = req[0];
		for(int i = 1;i<REQ_WIDTH;i = i+1)begin	
			grant[i] = req[i]&!pre_req[i-1];
			pre_req[i] = req[i] | pre_req[i-1];
			//或上之后可以使pre_req有1之后一直保持1
			grant[i] = req[i]&!pre_req[i-1];
		//注意这两种写法区别
		end
	end
		
	
endmodule

```
有没有更简洁的办法呢？下面老李介绍两种实现方式，code非常简洁，先来上面的设计的变体，但是不用for循环，本质上是一样的，只有3行code。
>利用该种写法衍生位操作 grant[i] = req[i]&!pre_req[i-1];
>等价与：pre_req[REQ_WIDTH-1:1] = req[REQ_WIDTH-2:0]|pre_req[REQ_WIDTH-2:0];
>gnt[i] = req[i] & !pre[i]改成：
>gnt = req& ~pre_req;


例如req = 10010  --->  pre_req=xxxx0  -->  pre_req=xxx00(req[0] | pre[0]=0)   --->....--->pre_req=**11100**(后面利用这个可以mask)
00011 & 10010 =
```VERILOG
module fixed_pri_arb#(
			parameter REQ_WIDTH = 16)
		(
			input [ REQ_WIDTH-1:0] req;
			output reg [ REQ_WIDTH-1:0] grant
			);
			
			
	reg [REQ_WIDTH-1] pre_req;//为了记录低位是否已经有了request。
	
	assign pre_req[0] = 1'b0;
	assign pre_req[REQ_WIDTH-1:1] = req[REQ_WIDTH-2:0]|pre_req[REQ_WIDTH-2:0];
	assign gnt = req& ~pre_req;
		
	
endmodule

```

下面的这种实现方式就更夸张了，就一行实现
```verilog
module fixed_pri_arb#(
			parameter REQ_WIDTH = 16)
		(
			input [ REQ_WIDTH-1:0] req;
			output reg [ REQ_WIDTH-1:0] grant
			);
			

	assign gnt = req & (~(req-1));
		
	
endmodule

```

个人理解：其实我们本质上就是去找req中第一次出现的1（从低到高），先让req-1 可以使前面所有的0变成1 第一次出现的1 变成0，假设第i位第一次出现1，那么0到（i-1）位，肯定是0。若是减一，0到i位则类似于进行取反操作，因为我们只是要找到第一个出现1（也就是grant输出），而后面出现的1肯定去掉，那么再去取反则是使i后面的位与req本身相反，而0-i位正好又回到与原来一样了，**而我们目的就是为了保留0-i位，使i后面的变成原来的相反位。** 

本质上，我们要做的是找req这个信号里从低到高第一个出现的1，那么我们给req减去1会得到什么？假设req的第i位是1，第0到第i-1位都是0，那么减去1之后我们知道低位不够减，得要向高位借位，直到哪一位可以借到呢？就是第一次出现1的位，即从第i位借位，第0到i-1位都变成了1，而第i位变为了0，更高位不变。然后我们再给减1之后的结果取反，然后把结果再和req本身按位与，可以得出，**只有第i位在取反之后又变成了1，而其余位都是和req本身相反的，按位与之后是0**，这样就提取出来了第一个为1的那一位，也就是我们需要的grant。再考虑一下特殊情况req全0，很明显，按位与之后gnt依然都是全0，没有任何问题。



>bin + (~bin + 1) = 0 
>~bin+1=A --> ~(A-1) + A = 0
> 故~(A-1)操作也是进行求补码操作

减1再取反，这不是计算2的补码的算法吗？只不过我们书本上学到的给一个数求2的补码的方法是取反再加1，这里倒过来，减1再取反，本质上是一样的。这其实是2的补码的一个特性，即**一个数和它的补码相与，得到的结果是一个独热码，独热码为1的那一位是这个数最低的1**。所以这个仲裁器的设计方法用一句话概括：**request和它的2的补码按位与**。
**一个数和它的补码相与，得到的结果是一个独热码，独热码为1的那一位是这个数最低的1**。
**request和它的2的补码按位与**。

个人理解：既然一个数和它的补码相与，得到的结果是一个独热码，那是不是也可以
> req & （~req+1)
> req + （~req + 1）= 0

逻辑也和减一取反一样，只是这次是进位

##  Round Robin Arbiter（循环优先级仲裁器）
Round Robin就是考虑到公平性的一种仲裁算法。其基本思路是，当一个requestor 得到了grant许可之后，**它的优先级在接下来的仲裁中就变成了最低**，也就是说每个requestor的优先级不是固定的，而是会在最高（获得了grant)之后变为最低，并且根据其他requestor的许可情况进行相应的调整。这样当有多个requestor的时候，grant可以依次给每个requestor，即使之前高优先级的requestor再次有新的request，也会等前面的requestor都grant之后再轮到它。

**Round Robin arbiter(循环优先级仲裁器)**，使用Round Robin的逻辑实现优先级。RR优先级的含义，包括两个层次：
1）**基于次序的优先级** ：小号输入口的优先级高于大号输入口；
2）**最高优先级是循环的**：与严格优先级不同的是，RR逻辑中，最高优先级并不总是0，而是根据上一次选择的输入口而变化的。上一次选择的输入口的下一个输入口具有最高的优先级。

3210，0321，1032，2103，相当于四个固定优先级仲裁器 
![[Pasted image 20220610224919.png]]
cur_pri 为i就选择i优先级最高的固定优先级。例如在cycle1中，0的优先级最高，但此时0没有req，而1req了，所以grant  id是1。所以下个cyc需要将cur_ pri 调到2，因为1032让1处于优先级最低。后面cyc也是如此。即从0001-->0100

下面这个表格Req[3:0]列表示实际的request，为1表示产生了request；**RR Priority这一列为当前的优先级，为0表示优先级最高，为3表示优先级最低；** RR Grant这一列表示根据当前Round Robin的优先级和request给出的许可；Fixed Grant表示如果是固定优先级，即按照3210，给出的grant值。

![[Pasted image 20220614170438.png]]


round robin的RTL 实现。直接介绍几种参数化的写法。
首先看第一种思路，即优先级是变化的，回想一下我们之前讲的Fixed Priority Design，我们都假定了从LSB到MSB优先级是由高到低排列的。现在优先级是变化的，那么我们有没有办法先设计一个fixed priority arbiter，它的优先级是一个输入呢？看下面的RTL

```verilog
module arb_base #(parameter num_req = 4)

(
    input [num_req-1 : 0] req,
    input  [num_req-1 : 0] base,
    output [num_req-1 : 0] gnt

);

  
    wire [2*num_req-1:0] d_req;
    wire [2*num_req-1:0] d_gnt;

    assign d_req = {req,req};
    assign d_gnt = d_req & (~(d_req-base));
    assign gnt = d_gnt[num_req-1:0] | d_gnt[2*num_req-1:num_req];
  
endmodule

```

在这个里面base是一个独热码的信号，它为1的那一位表示这一位的优先级最高，然后其次是它的高位即左边的位，直到最高位后回到第0位绕回来，优先级依次降低，直到为1那一位右边的这位为最低。咱们以4位为例，如果base = 4’b0100, 那么优先级是bit[2] > bit[3] > bit[0] > bit[1]。而上面fixed priority arbiter的设计就是base固定为0001的情况。

**这个设计的思路和前面说的优先级仲裁器 – Fixed Priority Arbiter最后那个1行设计的思路很像**，**里面double_req & ~(double_req-base)其实就是利用减法的借位去找出base以上第一个为1的那一位**，**只不过由于base值可能比req值要大，不够减，所以要扩展为{req, req}来去减。当base=4‘b0001的时候就是咱们上一篇里面的最后的算法。当然base=4’b0001的时候不存在req不够减的问题，所以不用扩展。**

例如req为0110，而base=1000，则req不够减。 但是为啥是拓展req？dub={req,req}
req为0110，而base=1000,我们要得到gnt为0010， 关键问题在于req不够减进行req拓展、
   **01100**110 
  -00001000 --> 01**011**110 --> 10**100**001（取反）-->  00100000 -->0010 | 0000--> 0010
  如果够减，取决于前面四位（后四位为0），如果不够减，取决于后四位（前四位为0） 

那么好了，既然有了可以根据输入给定优先级的固定优先级仲裁器（这句话有点绕，你仔细琢磨一下），那么接下来的任务就简单了，每次grant之后，我把我的优先级调整一下就可以了呗。而且这个设计妙就妙在，base要求是一个onehot signal，而且为1的那一位优先级最高。**我们前面说过，grant一定是onehot，grant之后被grant的那一路优先级变为最低，它的高1位优先级变为最高，所以，我只需要一个history_reg，来去记录之前最后grant的值，然后只需要将grant的值左移一下就变成了下一个周期的base。比如说，假设我上一个周期grant为4’b0010，那么bit[2]要变为最高优先级，那只需要base是grant的左移即可。RTL代码如下**

```verilog
module round_robin_arbiter #(parameter num_req = 4)

(
  input                      clk,
  input                      rstn,
  input [num_req-1:0]        req,
  output [num_req-1:0]       gnt
);

reg [num_req-1 : 0] hist_q;
always @(posedge clk or negedge rstn) begin
    if(!rstn)
        hist_q <= {(num_req-1){1'b0},1'b1};
    else(|req)
        hist_q <= {gnt[num_req-2],gnt[num_req-1]};
end
  
arbiter_base #(

  .num_req(num_req)

) arbiter(

  .req      (req),

  .gnt      (gnt),

  .base     (hist_q)

);

endmodule


```
  我们注意到，和Fixed Priority Arbiter不同，Round robin arbiter不再是纯的组合逻辑电路，而是要有时钟和复位信号，因为里面必须要有个寄存器来记录之前grant的状态。

上面这个Round Robin Arbiter的设计，好处就是思路简单明了，代码行数也很短，在你理解了Fixed Priority Arbiter之后，理解这个设计就很容易。但是这个设计也有缺点，即在**面积和timing上的优化不够好**。相比于我们接下来要介绍的设计，在request位数大(比如64位）的时候timing和area都要差一些，所以其实见并没有见到公司里采用这个设计，而更多的时候采用的是下面的设计：

**前面的思路是换优先级，而request不变，另一个思路是优先级不变，但是我们从request入手：当某一路request已经grant之后，我们人为地把进入fixed priority arbiter的这一路req给屏蔽掉，这样相当于只允许之前没有grant的那些路去参与仲裁，grant一路之后就屏蔽一路，等到剩余的request都依次处理完了再把屏蔽放开，重新来过。这就是利用屏蔽mask的办法来实现round robin的思路。**
这个思路还是会用到前面一讲里Fixed Priority Arbiter的写法，如何来产生屏蔽信号mask呢？回看下面这段RTL
```verilog
module fixed_pri_arb#(
			parameter REQ_WIDTH = 16)
		(
			input [ REQ_WIDTH-1:0] req;
			output reg [ REQ_WIDTH-1:0] grant
			);
			
			
	reg [REQ_WIDTH-1] pre_req;//为了记录低位是否已经有了request。
	
	assign pre_req[0] = 1'b0;
	assign pre_req[REQ_WIDTH-1:1] = req[REQ_WIDTH-2:0]|pre_req[REQ_WIDTH-2:0];
	assign gnt = reg& ~pre_req;
	
endmodule

```

里面的pre_req的意义是什么？**就是如果第i位的req为第一个1，那么pre_req从i+1位开始每一位都是1，而第0位到第i位都是0。** 这其实就是我们要找的mask! 只需要把req和上一个周期的pre_req AND起来，那么我们自然就得到了一个新的request，**这个request里之前grant的位以及之前的位都被mask掉了，允许通过的是在之前优先级更低的那些位，如果那些位上之前有request但是没有被grant，现在就可以轮到他们了。** 每次新的grant之后mask里0的位数会变多，从而mask掉更多位，直到所有的低优先级的request都被grant了一次之后，req AND mask的结果变成全0了，这个时候就说明我们已经轮询完毕，要重新来过了。
硬件实现上我们需要两个并行的Fixed Priority Arbiter，它们一个的输入是request AND mask之后的masked_request，另一个就是原本的request，然后我们在它们两个arbiter的output中选择一个grant。如下图所示：
![[Pasted image 20220614201707.png]]

当masked\_request不是全0，即存在没有被mask掉的request时，我们选择上面的这一路Mask Grant，否则我们选择下面这一路Unmasked Grant。

而又因为对于上面这一路来说，当masked\_request为全0的时候，Mask Grant也是全0，这个时候可以把Mask Grant和Unmask Grant直接按位OR起来就行，所以其实图上最后显示的Mux可以用下面简单的AND门和OR门实现

![[Pasted image 20220614201724.png]]
下面是这个设计的代码，依然是参数化的表达，可以满足任意数目的request。
```verilog
module round_robin_arbiter #(

 parameter N = 16

)(

input         clk,

input         rst,

input [N-1:0] req,

output[N-1:0] grant

);



logic [N-1:0] req_masked;

logic [N-1:0] mask_higher_pri_reqs;

logic [N-1:0] grant_masked;

logic [N-1:0] unmask_higher_pri_reqs;

logic [N-1:0] grant_unmasked;

logic no_req_masked;

logic [N-1:0] pointer_reg;



// Simple priority arbitration for masked portion

assign req_masked = req & pointer_reg;

assign mask_higher_pri_reqs[N-1:1] = mask_higher_pri_reqs[N-2: 0] | req_masked[N-2:0];

assign mask_higher_pri_reqs[0] = 1'b0;

assign grant_masked[N-1:0] = req_masked[N-1:0] & ~mask_higher_pri_reqs[N-1:0];



// Simple priority arbitration for unmasked portion

assign unmask_higher_pri_reqs[N-1:1] = unmask_higher_pri_reqs[N-2:0] | req[N-2:0];

assign unmask_higher_pri_reqs[0] = 1'b0;

assign grant_unmasked[N-1:0] = req[N-1:0] & ~unmask_higher_pri_reqs[N-1:0];



// Use grant_masked if there is any there, otherwise use grant_unmasked. 

assign no_req_masked = ~(|req_masked);

assign grant = ({N{no_req_masked}} & grant_unmasked) | grant_masked;



// Pointer update

always @ (posedge clk) begin

  if (rst) begin

    pointer_reg <= {N{1'b1}};

  end else begin

    if (|req_masked) begin // Which arbiter was used?

      pointer_reg <= mask_higher_pri_reqs;

    end else begin

      if (|req) begin // Only update if there's a req 

        pointer_reg <= unmask_high er_pri_reqs;

      end else begin

        pointer_reg <= pointer_reg ;

      end

    end

  end

end



endmodule

```
这里稍微多讲解几句，当no_req_masked之后，pointer_reg并不是要更新到1111或是1110，而是要根据这个时候的request来，比如说这个时候request是0010，那么新的mask就要调整为1100，重新把bit[0], bit[1]都mask掉。

可以看出，这个设计利用两个N位的arbiter并行计算，critical path只比单独的fixed priority arbiter多了mask这一步和最后的mux这一级，在timing上表现是非常好的。面积上相比于前面一种做法2N的加法器也要少一些。



