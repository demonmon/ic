---
title: jacobian（R*2）的计算分解为以下计算，可以通过调用calc_smpl和mult256，然后...
updated: 2022-03-20T16:35:42.0000000+08:00
created: 2022-03-20T16:23:49.0000000+08:00
---

jacobian（R\*2）的计算分解为以下计算，可以通过调用calc_smpl和mult256，然后调用mod512来完成。

jacobian（R+Q）的计算分解为以下计算，可以通过调用calc_smpl和mult256，然后调用mod512和jcb_dble来完成。

