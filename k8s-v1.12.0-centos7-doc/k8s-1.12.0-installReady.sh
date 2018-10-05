#!/bin/bash
#所有节点前期的准备工作
yum install -y vim wget

#配置hosts解析(如下操作在所有节点操作)
cat >>/etc/hosts<<EOF
192.168.2.6 k8smaster
192.168.2.7 k8snode1
EOF

#关闭所有节点系统防火墙
systemctl stop firewalld
systemctl disable firewalld

#关闭所有节点SElinux
sed -i 's/SELINUX=permissive/SELINUX=disabled/' /etc/sysconfig/selinux
#需要手动确认！！！！！
setenforce 0

#关闭所有节点swap
swapoff -a
# need---->手动修改/etc/fstab文件，注释掉SWAP的自动挂载，使用free -m确认swap已经关闭。

#调整内核参数(配置转发相关参数)
cat > /etc/sysctl.d/k8s.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
vm.swappiness=0
EOF

sysctl --system

#按需配置软件源

#阿里云yum源：    
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo 


#docker yum源    
cat >> /etc/yum.repos.d/docker.repo <<EOF
[docker]
name=Docker Repository
baseurl=http://mirrors.aliyun.com/docker-engine/yum/repo/main/centos/7
enabled=1
gpgcheck=0
EOF

#kubernetes yum源
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=0
EOF

:'

#或者以下
#kubernetes yum源
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF

'

yum clean all
yum makecache

#EPEL (Extra Packages for Enterprise Linux)，为“红帽系”的操作系统提供额外的软件包
yum -y install epel-release


#同步集群系统时间
yum -y install ntp
ntpdate asia.pool.ntp.org

#重启机器(首次)
#reboot