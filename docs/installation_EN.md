# Overview
Installation of vLLM and Dify, and deployment of the DeepSeek-R1-Distill-Qwen-7B model.

# Resources
Purchase the ECS service with Kunpeng computing power.<br>

| Specification | Operating System                                                                                     | Storage |
|---------------------------|------------------------------------------------------------------------------------------------------------|---------|
| kc2.6xlarge.2 24vCPU/48GiB | Ubuntu 22.04 server 64-bit ARM / Huawei Cloud EulerOS 2.0 Standard Edition 64-bit ARM | System Disk: 40GiB |

# Installation
Call the script [Ubuntu Script](../scripts/deployment4Ubuntu.sh) or [HCE Script](../scripts/deployment4HCE.sh) to install the required software. Key software and version information:
- gcc 12.3.0
- vLLM v0.8.2
- PyTorch v2.5.1
- MiniConda 25.1.1
- Dify 0.15.3

# Usage
For starting and verifying the inference service, refer to [usage](usage_EN.md) for instructions.