#!/usr/bin/env bash

# 删除旧版docker
apt-get remove docker docker-engine docker.io

# 添加仓库并在线安装
apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo apt-key add -

add-apt-repository \
   "deb [arch=amd64] https://mirrors.aliyun.com/docker-ce/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

apt-get update -y

apt-get install -y docker-ce

# 配置用户组
usermod -aG docker $USER

# 配置远程访问
mkdir -p /etc/systemd/system/docker.service.d/
tee /etc/systemd/system/docker.service.d/override.conf <<-'EOF'
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd -H fd:// -H tcp://0.0.0.0:2375
EOF

# 配置DNS、镜像加速
tee /etc/docker/daemon.json <<-'EOF'
{
	"dns": ["114.114.114.114", "8.8.8.8"],
	"registry-mirrors": ["https://tfgymrsd.mirror.aliyuncs.com"]
}
EOF

# 重启守护进程及docker服务
systemctl daemon-reload
systemctl restart docker

# 运行测试命令
docker run hello-world

# 打印docker版本信息
docker version
