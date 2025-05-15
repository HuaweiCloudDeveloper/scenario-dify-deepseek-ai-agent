# 概述
此文档介绍在鲲鹏云服务器（aarch64）上Huawei Cloud Euler（HCE） 或者Ubuntu 22.04 系统中采用vLLM推理框架部署DeepSeek-R1-Distill-Qwen-7B模型的推理服务。
<br>同时安装了Dify，用户可以通过Dify配置部署的模型服务进行低代码的AI Agent开发。

# 资源
购买鲲鹏算力的ECS服务。<br>

| 规格 | 操作系统                                                                        |存储|
|---------------------------|-----------------------------------------------------------------------------|-----|
| kc2.6xlarge.2 24vCPU/48GiB | Ubuntu 22.04 server 64bit with ARM  / Huawei Cloud EulerOS 2.0 标准版 64位 ARM版 |系统盘：40GiB|

# 安装
调用脚本 [Ubuntu脚本](../scripts/deployment4Ubuntu.sh)  或者 [HCE脚本](../scripts/deployment4HCE.sh)  安装所需软件。 关键软件以及版本信息：
- gcc  12.3.0
- vLLM v0.8.2
- PyTorch v2.5.1
- MiniConda 25.1.1
- Dify 0.15.3

# 使用
推理服务的启动和验证，参考[usage.md](usage.md)进行使用。
