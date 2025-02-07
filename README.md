# SM-Box
此工具整合sing-box和mosdns为一个docker发布，提供一个快速简单、稳定的的旁路由解决方案，采用Fakeip分流模式，直连流量不通过旁路由。主路由可以使用RouterOS、Opnsense、爱快等路由器，以及任何可以设置静态路由的路由器。

## 规划功能
1. 订阅格式转换<br>
2. 可视化节点、过滤器、规则编辑<br>
3. 去广告功能开关、配置编辑<br>
4. 自动更新订阅、mosdns规则<br>
5. 代理模式切换

## docker
`docker pull yoongger/sm-box`