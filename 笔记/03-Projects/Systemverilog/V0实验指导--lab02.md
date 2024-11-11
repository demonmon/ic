---
title: V0实验指导--lab02
updated: 2022-04-22T16:40:30
created: 2022-04-22T16:00:26
---

接口时序
![image1](image1-16.png)
首先是输入信号，我们看到先是发送地址，需要在发送的时候拉低frame_n，然后在发送一个地址，4bit，这个时候不关心vaild_n信号。但是建议为高。然后发送pad，需要5个cycle。这时信号din以及vaild_n都是高，但是frame_n为低。接下来发送数据din信号开始发送数据，发送nbit的数据。在**发送最后一位数据的时候拉高frame_n信号**。**din有效时即发送数据时候，vaild_n为低。就是输入的波形时序**

![image2](image2-13.png)

然后是输出时序。默认vaildo_n以及framo_n高电平。拉低frameo_n。下一个cycle拉低valido_n。valido_n为低电平时对应输出dout有效，反之。**只有frameo_n为低，则表示输出有效。输出的数据是否有效，则看vaildo_n的信号即可**。以上就是输入输出的时序波形了。注意这里的sa，da表示16个并行输入输出的某一个端口

**代码分析**

initial begin
  //$vcdpluson;//用于存储波形的方法，在使用questa-sim进行仿真的时候不需要
  reset();
  run_for_n\_packets = 21;
  repeat(run_for_n\_packets) begin
    gen();//产生发送数据
    send();//产生激励，与时序保持一致
  end
  repeat(10) @(rtr_io.cb);//每次发送结束间隔一定的时钟周期
end

task gen();//该task定义了发送接收的端口。
 sa = 3;//发送的端口为3
 da = 7;//接收数据的端口为7
 payload.delete(); //clear previous data 删除原始数据，推荐使用
 repeat($urandom_range(4,2))//重复2-4次，该函数后续进行说明
  payload.push_back($urandom);//在队列中写入数据，一次只能写队列的一个元素，就是8bit，这里返回的是一个32bit的数。会截取低八位。该函数后续进行介绍。
endtask: g

task send();//这个任务将分为三个任务，注意对于任务拆分的思想！！！
//我们看到，发送的时序分为三段，第一段发送地址，然后发送pad，最后实现数据的发送。这里均进行了模拟。且并没有揉在一起。简化简洁。
 send_addrs();
 send_pad();
 send_payload();
endtask: send

task send_addrs();//发送的前一个时钟上升沿将frame_n拉低，frame_n有16个bit。拉低的哪一位就是需要发送的数据了。
 rtr_io.cb.frame_n\[sa\] \<= 1'b0; //start of packet
 for(int i = 0; i\<4; i++) begin
  rtr_io.cb.din\[sa\] \<= da\[i\]; //i'th bit of da同时在这个相同的时钟沿将接收地址发送出去，串行发送，一位一位发送
  @(rtr_io.cb);//然后改变推进一个时钟周期。同时进行循环四次。
 end
endtask: send_addrs
task send_pad();//发送pad时序需要将din，valid_n拉高，frame_n保持为低即可。维持5个cycle
 rtr_io.cb.frame_n\[sa\] \<= 1'b0;
 rtr_io.cb.valid_n\[sa\] \<= 1'b1;
 rtr_io.cb.din\[sa\] \<= 1'b1;
 repeat(5) @(rtr_io.cb);
endtask: send_pad
task send_payload();//将准备好的数据进行发送
 foreach(payload\[index\])//循环次数为队列元素的个数
 $display(index,payload\[index\]);
  for(int i=0; i\<8; i++) begin
    rtr_io.cb.din\[sa\] \<= payload\[index\]\[i\];//注意这里发送的高低位，先发送的是低位
    rtr_io.cb.valid_n\[sa\] \<= 1'b0; //driving a valid bit
    rtr_io.cb.frame_n\[sa\] \<= ((i == 7) && (index == (payload.size() - 1)));//frame_n根据时序，在适当的时候拉高。
  @(rtr_io.cb);
  end
 rtr_io.cb.valid_n\[sa\] \<= 1'b1;//当完成发送的时候，valid_n也拉高，相比较于frame_n后延时一个cycle
endtask: send_payload
[foreach](https://so.csdn.net/so/search?q=foreach&spm=1001.2101.3001.7020)
这里简单解释，foreach(array\[i\])就是将其中的变量进行遍历。直接看输出会更清楚。
![image3](image3-12.png)

**

