---
title: V0实验指导 --lab03
updated: 2022-05-08T09:49:04
created: 2022-04-22T20:07:49
---

在lab
![image1](image1-17.png)

默认vaildo_n以及framo_n高电平。拉低frameo_n。下一个cycle拉低valido_n。valido_n为低电平时对应输出dout有效，反之。只有frameo_n为低，则表示输出有效。输出的数据是否有效，则看vaildo_n的信号即可。为低有效。否则数据无效。

我们看到新增加的内容为新定义了一个队列，用于存放接受到的数据。除此之外，将实现发送功能的任务send()与实现接受功能的任务rece()包在了fork join中。执行一次发送接受之后，进行检查两者数据是否一致。如下图。

![image2](image2-14.png)
**Fork join 用法**
在Verilog中，存在组合逻辑与时序逻辑，需要仿真器对于两者进行模拟。因此测试平台需要并发执行某些操作，称之为并发的线程。在verilog中存在begin…end，以及fork…join两中分组方式，用于顺序或者是并发执行。在**system vrilog中，引入了fork…join_any以及fork…join_none新的方法用于创建线程。最后解释停止进程**
Begin end 是顺序块 fork join 是并行块
•并行块中的语句并行执行。
•语句的顺序由分配给每个语句的延迟或事件控制来控制陈述
•如果指定了延迟或事件控制，则它与执行块的时间有关进入
**fork…join_any与fork…join_none**
前面对于fork的引入是为了更好的理解如下点。
join 父进程会阻塞直到这个分支产生的所有进程结束。
join_any 父进程会阻塞直到这个分支产生的任意一个进程结束。 然后继续执行
join_none 父进程会继续与这个分支产生的所有进程并发执行。在父线程执行一条阻塞语句之前，产生的进程不会启动执行。
![image3](image3-13.png)
![image4](image4-10.png)
![image5](image5-9.png)
简单来说
i
1.join必须块里面全部执行完再执行后面语句
2.join_any 是其中任意一个结束 就可以执行后面的
3.join none 是不需要其中结束 直接两者并发执行
停止进程：disable
关键字disable提供了一种终止命名块执行的方法。disable可用于根据控制信号跳出循环、处理错误条件或控制代码段的执行。禁用块会将执行控制传递给紧随该块之后的语句。对于C程序员来说，这与用于退出循环的break语句非常相似。区别在于break语句只能中断当前循环，而关键字disable允许禁用设计中的任何命名块。
在下面的这个例子中，等待时钟或者是等待到特定信号的下降沿。就会推出这个fork线程。两种写法都是可以的。

task get_payload();
  pkt2cmp_payload.delete();//清除之前缓存
  fork
   begin: wd_timer_fork
   fork: frameo_wd_timer
    @(negedge rtr_io.cb.frameo_n\[da\]); //这是第一个线程
    begin               //begin..end 是第二个线程
     repeat(1000) @(rtr_io.cb);
    $display("\\n%m\\n\[ERROR\]%t Frame signal timed out!\\n", $realtime);
     $finish;
    end //第二个线程结束位置
   join_any: frameo_wd_timer
   disable fork; //等同于 disable frameo_wd_timer，让剩下线程不再执行
   end: wd_timer_fork
  join

![image6](image6-8.png)

Lab3r任务实现方式解析：
**接收命令： task recv()**
该任务用于调用get_payload
task recv();
  get_payload();
 endtask: recv

**等待接收命令**：

task get_payload();
  pkt2cmp_payload.delete();//清除之前缓存的数据
  fork begin : wd_timer_fork
      fork : frameo_wd_timer 
        @(negedge rtr_io.cb.frameo_n\[da\]); //这里是第一个线程(thread)
    begin      //begin...end这里是第二个线程start
          repeat(100) @(rtr_io.cb);
          $display("\\n%m\\n\[ERROR\]%t Frame signal timed out!\\n", $realtime);
          $finish;
        end        //begin...end这里是第二个线程end
      join_any : frameo_wd_timer
      disable fork;   //等待失败，或者是等到下降沿，推出fork join。执行下面的内容
    end : wd_timer_fork
  join 

上面程序主要是防止 在执行的过程中，由于输出段始终没有出现frameo_n的**对应位的下降沿信号**则等待100时钟周期，然后输出错误信息，结束仿真。若是先等待到frameo_n的下降沿，推出进程，开始允许后面的程序。

接收数据并存储：

forever begin
 logic\[7:0\] datum;
 for(int i=0; i\<8; i=i) begin
   if(!rtr_io.cb.valido_n\[da\]) begin   
     datum\[i++\] = rtr_io.cb.dout\[da\];
     if(rtr_io.cb.frameo_n\[da\]) begin 
       if(i==8) begin //判断i是否为8。可能拉高的时间不对，就有可能引起这个问题。
         pkt2cmp_payload.push_back(datum);//将数据写入队列中
         return;   //返回。跳出forever
       end
       else begin
        $display("\\n%m\\n\[ERROR\]%t Packet payload not byte aligned!\\n", $realtime);
         $finish;
       end
     end
   end
   @(rtr_io.cb);
 end
 pkt2cmp_payload.push_back(datum);
end
endtask: get_payload

重点理解begin end块的划分。将原代码逻辑进行梳理，然后重点理解**对frameo_n的判断**。

开始进入forever循环
定义一个8bit数，用于数据缓存。logic\[7:0\] datum;
这里for循环后面会给出两个不一样的写法供参考。放在附录供思考分析
if(!rtr_io.cb.valido_n\[da\]) 就是判断rtr_io.cb.valido_n\[da\]是否为低电平。根据时序图，该信号为低，数据有效。开始对数据进行存储。若是为高，则根据时序图，这里继续将时钟向前推进。跳转到了@(rtr_io.cb)。
假设上一步判断为真，datum\[i++\] = rtr_io.cb.dout\[da\]; 然后将接收到的输出数据写入到datum的最低为中去。
接下来判断if(rtr_io.cb.frameo_n\[da\])
1）通过frameo_n为高判断是否接收结束！！！
2）这里i从1-8。i=8时候。将最后一个bit存储到datum中，这也是最后一个接收到的8bit数据。
3）由波形知，判断frameo_n为低，则说明还有数据未写入，跳转出去。不进行下面的判断，**将仿真时间向前推进一个cycle**。然后继续执行for循环，因为i\<8为满足。假设for循环到i==8，且**frameo_n依旧为低电平，说明并不是最后一组8bit数据**，**将现在存储的先写入队列**。假设frameo_n为高电平，则判断i是否为8。因为有可能不是一个完整的8bit数，就已经拉高了。这时候报错，否则写入最后一个8bit数，跳出forever。
同时这也是为什么再结束for循环之后将数据写入的原因。因为如果在i=8时候frame_o不为高说明不是最后一个字节 也就是传输的不是一个字节。

if(!rtr_io.cb.valido_n\[da\]) 建议直接写成if(rtr_io.cb.valido_n\[da\] == 1’b0) if(rtr_io.cb.frameo_n\[da\])建议写为if(rtr_io.cb.frameo_n\[da\] == 1'b1)，这两者是等价的，后者可读性更好。

比较任务 task check();
得到接收到的数据之后进行比较，这里check调用了**函数compare**。函数compare返回一个返回值。要是返回值等于0。则比较失败，输出相关信息，反之比较成功，打印相关信息。不进行过多介绍。

task check();
  string message;
  static int pkts_checked = 0;
  if (!compare(message)) begin
   $display("\\n%m\\n\[ERROR\]%t Packet #%0d %s\\n", $realtime, pkts_checked, message);
   $finish;
  end
  $display("\[NOTE\]%t Packet #%0d %s", $realtime, pkts_checked++, message);
 endtask: check

比较函数（compare）
比较函数的比较方式就是1）先比较长度（2）再比较内容。在任何一个方面比较失败，均返回0，表示比对不匹配。输出相关信息。笔者对原solution文件提供的进行了一点点的修改。很简单，这里不进行赘述。

function bit compare(ref string message);
  if(payload.size() != pkt2cmp_payload.size()) begin
   message = "Payload size Mismatch:\\n";
   message = { message, $sformatf("payload.size() = %0d, pkt2cmp_payload.size() = %0d\\n", payload.size(), pkt2cmp_payload.size()) };
   return (0);
  end
  if(payload == pkt2cmp_payload) ;
  else begin
   message = "Payload Content Mismatch:\\n";
   message = { message, $sformatf("Packet Sent:  %p\\nPkt Received:  %p", payload, pkt2cmp_payload) };
   return (0);
  end
  message = "Successfully Compared";
  return(1);
 endfunction: compare

