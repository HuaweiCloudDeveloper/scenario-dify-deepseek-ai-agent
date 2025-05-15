#!/bin/bash


# install gcc 12.3 & numa
apt-get update  -y
apt-get install -y gcc-12 g++-12 libnuma-dev
update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-12 10 --slave /usr/bin/g++ g++ /usr/bin/g++-12


# download vllm
cd ${HOME}
git clone https://gitcode.com/gh_mirrors/vl/vllm.git --branch v0.8.2 vllm_source


# install Conda
conda_home=${HOME}/miniconda3
mkdir -p ${conda_home}
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-aarch64.sh -O ${conda_home}/miniconda.sh
bash ${conda_home}/miniconda.sh -b -u -p ${conda_home}
rm -f ${conda_home}/miniconda.sh
source ${conda_home}/bin/activate
conda init --all


# set python mirror
mkdir ~/.pip
cat > ~/.pip/pip.conf << 'EOF'
[global]
index-url = https://repo.huaweicloud.com/repository/pypi/simple
trusted-host = repo.huaweicloud.com
timeout = 120
EOF


# create env
conda create -n vllm python=3.12 -y
conda activate vllm

cd ${HOME}/vllm_source
pip install "cmake>=3.26" wheel packaging ninja "setuptools-scm>=8" numpy
pip install -v -r requirements/cpu.txt --extra-index-url https://download.pytorch.org/whl/cpu
VLLM_TARGET_DEVICE=cpu python setup.py install


# download DeepSeek-R1-Distill-Qwen-xB
pip install modelscope

model=DeepSeek-R1-Distill-Qwen-7B
model_name=deepseek-ai/${model}
model_path=/models/modelscope/${model_name}
mkdir -p ${model_path}
modelscope download --model ${model_name}  --local_dir ${model_path}


# install tcmalloc
apt-get install libtcmalloc-minimal4


# create start script for DeepSeek-R1-Distill-Qwen-xB
start_ds=~/start_ds.sh
mkdir "/logs"
cat > ${start_ds} << EOF
#!/bin/bash
export LD_PRELOAD=/usr/lib/aarch64-linux-gnu/libtcmalloc_minimal.so.4:$LD_PRELOAD
export VLLM_CPU_KVCACHE_SPACE=6
export VLLM_CPU_OMP_THREADS_BIND='0-21'
export VLLM_LOG_LEVEL=info
nohup /root/miniconda3/envs/vllm/bin/python -m vllm.entrypoints.openai.api_server \
--model ${model_path} \
--served-model-name ${model} \
--dtype=half \
--max-model-len 16384 \
>> /logs/ds.log 2>&1 &
EOF

chmod +x ${start_ds}


# create call script
verify_ds=~/verify_ds.sh
cat > ${verify_ds} << EOF
curl http://localhost:8000/v1/chat/completions -H "Content-Type: application/json"  -o  verify_ds.log  -d '{
        "model": "${model}",
        "messages":[{"role":"user","content": "简单介绍下九宫格，输出小于100字。"}]
    }'
EOF
chmod +x ${verify_ds}


# install docker & docker compose
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do apt-get remove -y $pkg; done

apt-get update
apt-get install -y ca-certificates curl
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update

apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

cat > /etc/docker/daemon.json << 'EOF'
{
    "registry-mirrors": [ "https://7046a839d8b94ca190169bc6f8b55644.mirror.swr.myhuaweicloud.com" ]
}
EOF
systemctl restart docker


# install dify & create start/stop script
cd ${HOME}
git clone https://gitcode.com/gh_mirrors/di/dify.git --branch 0.15.3 dify

cd dify/docker
cp .env.example .env
docker compose up -d

start_dify=${HOME}/start_dify.sh
cat > ${start_dify} << EOF
#!/bin/bash

cd ~/dify/docker/
docker compose start
EOF
chmod +x ${start_dify}

stop_dify=${HOME}/stop_dify.sh
cat > ${stop_dify} << EOF
#!/bin/bash

cd ~/dify/docker/
docker compose stop
EOF
chmod +x ${stop_dify}


# remove redundant files
cd ~
rm -rf ${HOME}/vllm_source

cat > /etc/docker/daemon.json << 'EOF'
EOF