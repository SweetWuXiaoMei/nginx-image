#!/bin/bash

set -e
# hce
sudo yum -y update & yum -y upgrade

# ubuntu
# apt-get -y update
# export DEBIAN_FRONTEND=noninteractive
# apt-get -y -o Dpkg::Options::="--force-confold" dist-upgrade
cd /opt

# 安装jdk
wget https://download.java.net/java/GA/jdk21/fd2272bbf8e04c3dbaee13770090416c/35/GPL/openjdk-21_linux-aarch64_bin.tar.gz
tar -xf openjdk-21_linux-aarch64_bin.tar.gz
echo 'export JAVA_HOME=/opt/jdk-21' | sudo tee -a /etc/profile
echo 'export PATH=$JAVA_HOME/bin:$PATH' | sudo tee -a /etc/profile
source /etc/profile

# 安装git
# hce
dnf -y install git
# ubuntu
# apt -y install git

# 安装maven
wget https://repo.huaweicloud.com/apache/maven/maven-3/3.9.6/binaries/apache-maven-3.9.6-bin.tar.gz
tar -xf apache-maven-3.9.6-bin.tar.gz
sudo mv apache-maven-3.9.6 maven
echo 'export MAVEN_HOME=/opt/maven' | sudo tee -a /etc/profile
echo 'export PATH=$MAVEN_HOME/bin:$PATH' | sudo tee -a /etc/profile
source /etc/profile

# 安装nginx
# 安装会慢
wget https://nginx.org/download/nginx-1.28.0.tar.gz
tar -xf nginx-1.28.0.tar.gz
cd nginx-1.28.0

# hce
yum install -y pcre pcre-devel zlib-devel openssl-devel
# ubuntu 
# sudo apt install -y build-essential libpcre3 libpcre3-dev zlib1g-dev libssl-dev

sudo /usr/local/nginx/sbin/nginx

sudo tee /etc/systemd/system/nginx.service > /dev/null <<EOF
[Unit]
Description=The NGINX HTTP and reverse proxy server
After=network.target

[Service]
Type=forking
ExecStart=/usr/local/nginx/sbin/nginx
ExecReload=/usr/local/nginx/sbin/nginx -s reload
ExecStop=/usr/local/nginx/sbin/nginx -s quit
PIDFile=/usr/local/nginx/logs/nginx.pid
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF

# 重新加载Systemd
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
# 启用开机启动
sudo systemctl enable nginx
# 重启服务
sudo systemctl start nginx


passwd -d root


# 停止Nacos服务
sudo systemctl stop nginx

# 禁用开机启动
sudo systemctl disable nginx

# 删除服务文件（位置可能有所不同）
sudo rm /etc/systemd/system/nginx.service

# 重新加载systemd配置
sudo systemctl daemon-reload