# K8S之使用kubeadm安装Kubernetes v1.12.0

## 环境描述：

采用CentOS7 minimual，
docker 1.13，
kubeadm 1.12.0，
etcd 3.1.12， 
k8s 1.12.0  

我们这里选用三个节点搭建一个实验环境。

10.0.100.202 k8smaster  192.168.2.7
10.0.100.203 k8snode1   192.168.2.5


## 所有节点前期的准备工作

参考 《k8s-1.12.0-installReady.md》

## 软件安装与配置

### 所有机器上安装所需的软件
使用kubeadm安装：

1.首先配置所有节点阿里K8S YUM源

2.在所有节点安装kubeadm和相关工具包
```
#每台机器都需安装docker, kubeadm, kubelet和kubectl 
#1.1 安装docker
#1.2 安装kubeadm, kubelet和kubectl

yum -y install docker kubelet kubeadm kubectl kubernetes-cni
```

```
docker.x86_64 2:1.13.1-75.git8633870.el7.centos    
kubeadm.x86_64 0:1.12.0-0    
kubectl.x86_64 0:1.12.0-0    
kubelet.x86_64 0:1.12.0-0   
kubernetes-cni.x86_64 0:0.6.0-0
```

```
# 配置kubelet的cgroups
# 获取docker的cgroups
DOCKER_CGROUPS=$(docker info | grep 'Cgroup' | cut -d' ' -f3)
echo $DOCKER_CGROUPS
cat >/etc/sysconfig/kubelet<<EOF
KUBELET_EXTRA_ARGS="--cgroup-driver=$DOCKER_CGROUPS"
EOF

#KUBELET_EXTRA_ARGS="--cgroup-driver=$DOCKER_CGROUPS --pod-infra-container-image=registry.cn-hangzhou.aliyuncs.com/google_containers/pause-amd64:3.1"
```


3.启动Docker与kubelet服务(设置Docker与kubelet服务开机自启)
```
systemctl enable docker && systemctl start docker
systemctl enable kubelet && systemctl start kubelet
```
提示：此时kubelet的服务运行状态是异常的，因为缺少主配置文件kubelet.conf。但可以暂不处理，因为在完成Master节点的初始化后才会生成这个配置文件。

至此，在所有机器上安装所需的软件已经结束。


### 在master上配置

#### 下载K8S相关镜像（Master节点操作）

因为无法直接访问gcr.io下载镜像，所以需要配置一个国内的容器镜像加速器
配置一个阿里云的加速器：
登录 https://cr.console.aliyun.com/
在页面中找到并点击镜像加速按钮，即可看到属于自己的专属加速链接，选择Centos版本后即可看到配置方法。

registry.cn-hangzhou.aliyuncs.com
提示：在阿里云上使用 Docker 并配置阿里云镜像加速器

因为国内网络的原因，我们无法到kubeadm制定的镜像源获取到启动服务需要的镜像，
两个办法：
第一个是VPN；
第二个是国内的镜像仓库找到需要的镜像，通过docker pull的方式拉到本地，然后通过docker tag的方式修改镜像的标签，来符合kubeadm要求的镜像。
所需要哪些镜像呢，我们通过官网可以看到:
`https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-init/`

```
#查看需要安装的镜像
kubeadm config images list
```

```
#拉取镜像脚本，参考《k8s-1.12.0-docker-pull-images.sh》
```
上面的shell脚本主要做了3件事，下载各种需要用到的容器镜像、重新打标记为符合k8s命令规范的版本名称、清除旧的容器镜像。

提示：镜像版本一定要和kubeadm安装的版本一致，否则会出现拉取国外iamges time out问题。
 


#### 初始化安装K8S Master

执行上述shell脚本，等待下载完成后，执行kubeadm init
```
kubeadm init --kubernetes-version=v1.12.0 --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=192.168.2.7 --token-ttl 0
```
这里--kubernetes-version是指定版本（不做设置则默认安装最新版本），--pod-network-cidr表示k8s中pod使用的网络段，--apiserver-advertise-address表示k8s apiserver的地址使用master的192.168.2.7，设置了--token-ttl 0，所以该命令永久有效（默认24H）


```
#如果需要重新执行init前需要先删除原有配置等
kubeadm reset
```


#开机后重新走一遍配置，初始化K8S启动ok


```
#成功初始化K8S显示

Your Kubernetes master has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

You can now join any number of machines by running the following on each node
as root:

  kubeadm join 192.168.2.7:6443 --token eqbfou.1wxvkn31lq7dfi6f --discovery-token-ca-cert-hash sha256:6cab8bc2f98bc09e7e9c4026e86d41d38971d0db949575c396b36a5b39ca55a1
```

上面最后一段的输出信息保存一份，后续添加工作节点还要用到。（**重新执行reset、init后显示token会改变，这个需要注意！**）
```
#重新执行
kubeadm reset
kubeadm init --kubernetes-version=v1.12.0 --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=192.168.2.7
后显示token会改变，这个需要注意！
```


#### 配置kubectl认证信息（Master节点操作）
```
# 对于root用户
export KUBECONFIG=/etc/kubernetes/admin.conf
也可以直接放到~/.bash_profile
echo "export KUBECONFIG=/etc/kubernetes/admin.conf" >> ~/.bash_profile

#对于非root用户
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```


可以通过如下命令来验证是否初始化成功:
```
kubectl get pods --all-namespaces
```

```
[root@k8smaster ~]# kubectl get pods --all-namespaces
NAMESPACE     NAME                                READY   STATUS    RESTARTS   AGE
kube-system   coredns-576cbf47c7-6f6mz            0/1     Pending   0          20m
kube-system   coredns-576cbf47c7-9sblt            0/1     Pending   0          20m
kube-system   etcd-k8smaster                      1/1     Running   2          5s
kube-system   kube-apiserver-k8smaster            1/1     Running   2          88s
kube-system   kube-controller-manager-k8smaster   1/1     Running   4          87s
kube-system   kube-proxy-lk7kr                    1/1     Running   2          20m
kube-system   kube-scheduler-k8smaster            1/1     Running   2          86s

```
可以看到所有的容器都处于Running状态，除了dns处于Pending, 那是因为还没有安装k8s的网络插件。

##### 安装flannel网络（Master节点操作）/ k8s网络插件安装和选择
k8s提供了丰富的第三方的网络插件，有Flannel,Calico等，这些网络插件的细节会在后面的文章进行探索，安装者应该根据具体场景进行选择，这里我们使用Flannel。

```
mkdir -p /etc/cni/net.d/

cat <<EOF> /etc/cni/net.d/10-flannel.conf
{
"name": "cbr0",
"type": "flannel",
"delegate": {
"isDefaultGateway": true
}
}
EOF

mkdir /usr/share/oci-umount/oci-umount.d -p
mkdir /run/flannel/

cat <<EOF> /run/flannel/subnet.env
FLANNEL_NETWORK=10.244.0.0/16
FLANNEL_SUBNET=10.244.1.0/24
FLANNEL_MTU=1450
FLANNEL_IPMASQ=true
EOF

#指定版本
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/v0.9.1/Documentation/kube-flannel.yml
或 安装最新
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
```

显示：
```
clusterrole.rbac.authorization.k8s.io/flannel created
clusterrolebinding.rbac.authorization.k8s.io/flannel created
serviceaccount/flannel created
configmap/kube-flannel-cfg created
daemonset.extensions/kube-flannel-ds created
```

通过如下命令来来查看kube-dns是否在running来判断network是否安装成功:
```
kubectl get pods --all-namespaces
```

如果还有服务处于非Running状态， 可尝试重启服务：
```
systemctl restart docker
systemctl restart kubelet
```
 


---
 


#### 让node1、node2加入集群(所有节点的操作)


在node1和node2节点上分别执行`kubeadm join`命令，加入集群：
```
kubeadm join 192.168.2.7:6443 --token eqbfou.1wxvkn31lq7dfi6f --discovery-token-ca-cert-hash sha256:6cab8bc2f98bc09e7e9c4026e86d41d38971d0db949575c396b36a5b39ca55a1
```
提示：这段命令其实就是前面K8S Matser init安装成功后保存的那段命令。

显示：
```
[root@localhost ~]# kubeadm join 192.168.2.7:6443 --token eqbfou.1wxvkn31lq7dfi6f --discovery-token-ca-cert-hash sha256:6cab8bc2f98bc09e7e9c4026e86d41d38971d0db949575c396b36a5b39ca55a1
[preflight] running pre-flight checks
        [WARNING RequiredIPVSKernelModulesAvailable]: the IPVS proxier will not be used, because the following required kernel modules are not loaded: [ip_vs ip_vs_rr ip_vs_wrr ip_vs_sh] or no builtin kernel ipvs support: map[ip_vs_rr:{} ip_vs_wrr:{} ip_vs_sh:{} nf_conntrack_ipv4:{} ip_vs:{}]
you can solve this problem with following methods:
 1. Run 'modprobe -- ' to load missing kernel modules;
2. Provide the missing builtin kernel ipvs support

[discovery] Trying to connect to API Server "192.168.2.7:6443"
[discovery] Created cluster-info discovery client, requesting info from "https://192.168.2.7:6443"
[discovery] Requesting info from "https://192.168.2.7:6443" again to validate TLS against the pinned public key
[discovery] Cluster info signature and contents are valid and TLS certificate validates against pinned roots, will use API Server "192.168.2.7:6443"
[discovery] Successfully established connection with API Server "192.168.2.7:6443"
[kubelet] Downloading configuration for the kubelet from the "kubelet-config-1.12" ConfigMap in the kube-system namespace
[kubelet] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[preflight] Activating the kubelet service
[tlsbootstrap] Waiting for the kubelet to perform the TLS Bootstrap...
[patchnode] Uploading the CRI Socket information "/var/run/dockershim.sock" to the Node API object "localhost.localdomain" as an annotation

This node has joined the cluster:
* Certificate signing request was sent to apiserver and a response was received.
* The Kubelet was informed of the new secure connection details.

Run 'kubectl get nodes' on the master to see this node join the cluster.
```

#### 单机做集群
默认情况下，Master节点不参与工作负载，但如果希望安装出一个All-In-One的k8s环境，则可以Master节点执行以下命令，让Master节点也成为一个Node节点：
```
kubectl taint nodes --all node-role.kubernetes.io/master-
```
 



#### 验证K8S Master是否搭建成功（Master节点操作）
```
# 查看节点状态
kubectl get nodes

# 查看pods状态
kubectl get pods --all-namespaces

# 查看K8S集群状态
kubectl get cs
```
 
安装完。 接下来安装、配置 kubernetes-dashboard（图形操作面板）。

---
  
---
 
部分cmd
```
systemctl restart docker
systemctl restart kubelet
```
 

```
kubeadm reset

kubeadm init --kubernetes-version=v1.12.0 --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=192.168.2.7 --token-ttl 0

kubectl get pods --all-namespaces

kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/v0.9.1/Documentation/kube-flannel.yml

systemctl restart docker
systemctl restart kubelet
```

#保存内容脚本
```
cat <<EOF > /root/latest.init.totken.txt
#需要保存的内容
EOF
```
 

 ---
