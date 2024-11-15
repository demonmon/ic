High temperature gate-bias and reverse-bias tests on SiC MOSFETs

## 引言
宽带隙半导体在开关电源应用中受到越来越多的关注，因为由于其优越的物理特性，它们提供了克服硅对工作温度、功率率和开关频率的限制的潜力。
稳定的天然氧化物的形成使碳化硅(SiC)成为比任何其他宽带隙半导体更有希望实现MOS基器件的候选材料。
这使得用SiC制造的功率mosfet(金属-氧化物-半导体场效应晶体管)的开发成为可能，它们在技术上已经成熟为商业产品[1]。
然而，SiC晶圆中大量的晶体缺陷和晶体中碳原子的存在导致氧化物生长速度缓慢，从而给器件性能带来了一些问题[1,2]。
高温栅偏置(HTGB)和高温反向偏置(HTRB)测试是半导体制造业中常规进行的可靠性和合格性测试。
HTGB测试旨在通过在高温下施加直流偏置电压对栅极氧化物施加电应力，以检测由SiC/SiO2界面附近大量电荷阱和随着氧化物增长[3]而产生的大块氧化物阱引起的任何电参数漂移。HTRB测试的目的是在一段时间内监测高温反向偏置条件下器件的泄漏电流。由于它结合了电应力和热应力，该测试可用于检查结的完整性，晶体缺陷和离子污染水平，这可以揭示器件边缘终止和表面钝化时场损耗结构中的弱点或退化效应


## 实验过程

### 高温栅偏压试验

HTGB测试旨在监测在高温下对器件施加长时间门源偏置直流电压后，阈值电压(Vth)的变化。Vth定义为Vds = Vgs时漏极电流id = 5ma时的闸源电压。在测量电路中采用Keighley 6487皮安计，以实现精确的测量值。测试器件为商用现货产品，额定电压为1200v，额定电流为42a。在测试过程中，待测设备(DUT)被放置在一个环境室中，该环境室提供150℃的恒定温度，与此同时，通过施加栅极源直流电压，漏极短至源，对它们施加偏置应力。图1所示为应力和Vth测量时的门偏置电路原理图。

表1总结了HTGB测试条件。在+20 V、5 V和10 V三种偏置条件下，对来自同一生产批次的三组器件进行了检查，以研究所施加栅极电压的大小和极性对V移的程度和符号的影响。每组包括四个平行连接的设备。
所有器件在上述条件下受力1000小时(6周)。在施加压力前首先测量阈值电压，然后每周定期测量一次。在测量过程中，被检查的设备保持在150℃的环境室中。

### 高温反向偏置试验

高温反向偏置测试在HTRB测试中，在高温下器件长时间的漏源偏置应力期间监测漏漏电流(Ileak)。数据表允许的最大额定反向击穿电压(BVdss)的80%应用于栅极短路到源。

在测试过程中，四个被测器件在温度为150摄氏度的热板上被紧紧地拧紧，同时施加960 V的漏源反向偏置电压。在设备和热板之间插入热垫，以提供电气隔离。反向偏置应力和泄漏电流测量电路原理图如图2所示。

表2总结了HTRB试验条件。4个器件在上述条件下受力6周。首先在受力前测量泄漏电流(Ileak)，然后每隔一周定期测量一次。在测量过程中，被检查的设备保持在150℃的热板上。为了获得低电流测量(<1 lA)的精度，使用Keithley 2635a系统源表，其直流电流测量能力为1 fA至1.53 a。


## 结果与讨论

### 高温栅偏压后的阈值电压漂移

三种应力条件下Vth随应力时间的变化如图3-5所示。从图3中可以看出，A组4个器件在门偏压+20 V时，Vth值均有所增加。在图4和图5中，B组和C组器件分别受到5 V和10 V的栅偏压应力时，Vth都有所下降。这表明，正的门偏压应力导致Vth的正移位，负的偏压应力导致Vth的负移位。在[5]中，尽管[5]中的应力时间远短于本工作的测试持续时间，但在高温栅偏压应力条件下，SiC mosfet也报告了同样的现象。这种效应可以通过电子隧穿进出SiC/SiO2界面附近的氧化物阱来解释，以响应栅偏压应力产生的电场[6,7]。
	![[Pasted image 20230417093031.png]]

![[Pasted image 20230417093118.png]]

![[Pasted image 20230417093129.png]]


图4和图5为负栅偏应力结果。对比图4和图5,5v应力下的器件(B组)Vth的变化要小于10v应力下的器件(C组)，也就是说，在偏置电压极性相同的情况下，偏置应力的大小越大，阈值电压的位移越大。这是因为栅极偏压应力在栅极氧化物上产生电场，栅极偏压的大小与电场的强度相对应。因此，偏压越大，电子隧穿过程越有效，导致Vth位移越大


### 高温反向偏置应力后漏极漏电流的变化

在上述应力条件下，四种被测器件的漏极泄漏电流(Ileak)随应力持续时间的变化如图6所示。Device_14在测试期间严重失败。在施加压力378小时后，可以看到Ileak急剧增加。用万用表测量本征体的导通电压，注意到漏源短路。其他三种器件在不同水平下漏极电流随应力持续时间的增加而增长相对缓慢。

漏极漏电流衰减机制多种，包括漏极到源的亚阈值漏极、带对带隧道主导的pn结漏极和界面阱致漏极[8-10]。应用于MOSFET器件的HTRB不仅对漏极pn结施加应力，而且对栅极氧化物也施加应力。HTRB应力作用后的漏极泄漏退化主要由发生在栅极-漏极重叠区域深层耗尽层的表面缺陷辅助隧穿所驱动，这种隧穿是在栅极接地的漏极施加高压时形成的[10,11]。半导体/栅氧化物界面氧化电荷的产生改变了半导体表面场，导致带对带隧穿电流[8]的增强。器件边缘端场损耗结构中钝化裂纹的存在是导致应力后泄漏退化[12]演变的另一种观察现象。

## 结论

对最先进的SiC mosfet进行了静态测试，包括HTGB和HTRB测试，以表征该器件的稳定性和可靠性。这两种试验分别观察到阈值电压不稳定和漏电流退化。

我们已经证明，在高温门偏压下，Vth的位移强烈依赖于偏压应力条件，包括偏压极性和大小。正的栅偏压应力引起Vth的正位移，负的偏压应力引起Vth的负位移，这可能是由于在栅偏压应力存在时，近界面氧化阱的充盈和清空。此外，具有相同极性的栅极偏置的值决定了其产生的电场强度，从而改变了Vth位移的大小。

在高温漏源反向偏置应力作用下，器件的漏极泄漏电流随着应力时间的延长呈现不同程度的增加。这可以通过长时间反向偏置对体漏二极管特性的影响来解释，体漏二极管是功率MOSFET结构中最关键的部分。底层物理，如那些涉及由HTRB应力激活的表面和界面缺陷超出了本文的范围。











