# K8S之使用kubeadm安装Kubernetes v1.12.0 错误记录


#### 初始化安装K8S Master

---
执行上述shell脚本，等待下载完成后，执行kubeadm init
```
kubeadm init --kubernetes-version=v1.10.0 --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=192.168.2.7
```
这里--kubernetes-version是指定版本（不做设置则默认安装最新版本），--pod-network-cidr表示k8s中pod使用的网络段，--apiserver-advertise-address表示k8s apiserver的地址使用master的192.168.2.7

失败：
this version of kubeadm only supports deploying clusters with the control plane version >= 1.11.0. Current version: v1.10.0

解决：
安装对应版本
```
kubeadm reset
kubeadm init --kubernetes-version=v1.12.0 --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=192.168.2.7
```
 

---
 

- 获取版本超时，本地images版本与要求不一致

kubeadm config images list

k8s.gcr.io/kube-apiserver:v1.12.0
k8s.gcr.io/kube-controller-manager:v1.12.0
k8s.gcr.io/kube-scheduler:v1.12.0
k8s.gcr.io/kube-proxy:v1.12.0
k8s.gcr.io/pause:3.1
k8s.gcr.io/etcd:3.2.24
k8s.gcr.io/coredns:1.2.2


docker pull registry.cn-hangzhou.aliyuncs.com/acs/coredns:1.2.2
docker tag registry.cn-hangzhou.aliyuncs.com/acs/coredns:1.2.2 k8s.gcr.io/coredns:1.2.2
docker rmi registry.cn-hangzhou.aliyuncs.com/acs/coredns:1.2.2


docker tag k8s.gcr.io/kube-apiserver-amd64:v1.12.0 k8s.gcr.io/kube-apiserver:v1.12.0     
docker tag k8s.gcr.io/kube-controller-manager-amd64:v1.12.0 k8s.gcr.io/kube-controller-manager:v1.12.0 
docker tag k8s.gcr.io/kube-scheduler-amd64:v1.12.0 k8s.gcr.io/kube-scheduler:v1.12.0        
docker tag k8s.gcr.io/kube-proxy-amd64:v1.12.0 k8s.gcr.io/kube-proxy:v1.12.0
docker tag k8s.gcr.io/pause-amd64:3.1 k8s.gcr.io/pause:3.1 
docker tag k8s.gcr.io/etcd-amd64:3.2.24 k8s.gcr.io/etcd:3.2.24
docker tag k8s.gcr.io/k8s-dns-sidecar-amd64:1.14.13 k8s.gcr.io/k8s-dns-sidecar:1.14.13 
docker tag k8s.gcr.io/k8s-dns-kube-dns-amd64:1.14.13 k8s.gcr.io/k8s-dns-kube-dns:1.14.13
docker tag k8s.gcr.io/k8s-dns-dnsmasq-nanny-amd64:1.14.13 k8s.gcr.io/k8s-dns-dnsmasq-nanny:1.14.13
docker tag k8s.gcr.io/kubernetes-dashboard-amd64:v1.10.0 k8s.gcr.io/kubernetes-dashboard:v1.10.0


docker rmi k8s.gcr.io/kube-apiserver-amd64:v1.12.0
docker rmi k8s.gcr.io/kube-controller-manager-amd64:v1.12.0
docker rmi k8s.gcr.io/kube-scheduler-amd64:v1.12.0
docker rmi k8s.gcr.io/kube-proxy-amd64:v1.12.0
docker rmi k8s.gcr.io/pause-amd64:3.1
docker rmi k8s.gcr.io/etcd-amd64:3.2.24
docker rmi k8s.gcr.io/k8s-dns-sidecar-amd64:1.14.13
docker rmi k8s.gcr.io/k8s-dns-kube-dns-amd64:1.14.13
docker rmi k8s.gcr.io/k8s-dns-dnsmasq-nanny-amd64:1.14.13
docker rmi k8s.gcr.io/kubernetes-dashboard-amd64:v1.10.0

---
 


kubeadm reset
[root@localhost ~]# kubeadm init --kubernetes-version=v1.12.0 --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=192.168.2.7
[init] using Kubernetes version: v1.12.0
[preflight] running pre-flight checks
[preflight/images] Pulling images required for setting up a Kubernetes cluster
[preflight/images] This might take a minute or two, depending on the speed of your internet connection
[preflight/images] You can also perform this action in beforehand using 'kubeadm config images pull'
[kubelet] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[preflight] Activating the kubelet service
[certificates] Generated etcd/ca certificate and key.
[certificates] Generated etcd/server certificate and key.
[certificates] etcd/server serving cert is signed for DNS names [localhost.localdomain localhost] and IPs [127.0.0.1 ::1]
[certificates] Generated etcd/peer certificate and key.
[certificates] etcd/peer serving cert is signed for DNS names [localhost.localdomain localhost] and IPs [192.168.2.7 127.0.0.1 ::1]
[certificates] Generated etcd/healthcheck-client certificate and key.
[certificates] Generated apiserver-etcd-client certificate and key.
[certificates] Generated ca certificate and key.
[certificates] Generated apiserver-kubelet-client certificate and key.
[certificates] Generated apiserver certificate and key.
[certificates] apiserver serving cert is signed for DNS names [localhost.localdomain kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local] and IPs [10.96.0.1 192.168.2.7]
[certificates] Generated front-proxy-ca certificate and key.
[certificates] Generated front-proxy-client certificate and key.
[certificates] valid certificates and keys now exist in "/etc/kubernetes/pki"
[certificates] Generated sa key and public key.
[kubeconfig] Wrote KubeConfig file to disk: "/etc/kubernetes/admin.conf"
[kubeconfig] Wrote KubeConfig file to disk: "/etc/kubernetes/kubelet.conf"
[kubeconfig] Wrote KubeConfig file to disk: "/etc/kubernetes/controller-manager.conf"
[kubeconfig] Wrote KubeConfig file to disk: "/etc/kubernetes/scheduler.conf"
[controlplane] wrote Static Pod manifest for component kube-apiserver to "/etc/kubernetes/manifests/kube-apiserver.yaml"
[controlplane] wrote Static Pod manifest for component kube-controller-manager to "/etc/kubernetes/manifests/kube-controller-manager.yaml"
[controlplane] wrote Static Pod manifest for component kube-scheduler to "/etc/kubernetes/manifests/kube-scheduler.yaml"
[etcd] Wrote Static Pod manifest for a local etcd instance to "/etc/kubernetes/manifests/etcd.yaml"
[init] waiting for the kubelet to boot up the control plane as Static Pods from directory "/etc/kubernetes/manifests" 
[init] this might take a minute or longer if the control plane images have to be pulled


##### 失败原因
- 如果初始化失败查看日志：tail -f /var/log/messages
潜在原因：images版本与kubeadm版本必须对应一致，防火墙关闭，hosts配置，kubelet的cgroups与docker的cgroups是否配置一致，下载的容器镜像版本必须与K8S版本一致 等


```
Oct  3 23:59:41 localhost journal: E1003 15:59:41.556121       1 reflector.go:134] k8s.io/client-go/informers/factory.go:131: Failed to list *v1.ReplicationController: Get https://192.168.2.7:6443/api/v1/replicationcontrollers?limit=500&resourceVersion=0: dial tcp 192.168.2.7:6443: connect: connection refused
Oct  3 23:59:41 localhost journal: E1003 15:59:41.556474       1 reflector.go:134] k8s.io/kubernetes/cmd/kube-scheduler/app/server.go:178: Failed to list *v1.Pod: Get https://192.168.2.7:6443/api/v1/pods?fieldSelector=status.phase%21%3DFailed%2Cstatus.phase%21%3DSucceeded&limit=500&resourceVersion=0: dial tcp 192.168.2.7:6443: connect: connection refused
Oct  3 23:59:41 localhost kubelet: E1003 23:59:41.557076    6212 reflector.go:134] k8s.io/kubernetes/pkg/kubelet/config/apiserver.go:47: Failed to list *v1.Pod: Get https://192.168.2.7:6443/api/v1/pods?fieldSelector=spec.nodeName%3Dlocalhost.localdomain&limit=500&resourceVersion=0: dial tcp 192.168.2.7:6443: connect: connection refused
Oct  3 23:59:41 localhost kubelet: E1003 23:59:41.557197    6212 reflector.go:134] k8s.io/kubernetes/pkg/kubelet/kubelet.go:442: Failed to list *v1.Service: Get https://192.168.2.7:6443/api/v1/services?limit=500&resourceVersion=0: dial tcp 192.168.2.7:6443: connect: connection refused
Oct  3 23:59:41 localhost journal: E1003 15:59:41.557990       1 reflector.go:134] k8s.io/client-go/informers/factory.go:131: Failed to list *v1.ReplicaSet: Get https://192.168.2.7:6443/apis/apps/v1/replicasets?limit=500&resourceVersion=0: dial tcp 192.168.2.7:6443: connect: connection refused
Oct  3 23:59:41 localhost journal: E1003 15:59:41.568820       1 reflector.go:134] k8s.io/client-go/informers/factory.go:131: Failed to list *v1.StatefulSet: Get https://192.168.2.7:6443/apis/apps/v1/statefulsets?limit=500&resourceVersion=0: dial tcp 192.168.2.7:6443: connect: connection refused
Oct  3 23:59:41 localhost kubelet: E1003 23:59:41.570168    6212 reflector.go:134] k8s.io/kubernetes/pkg/kubelet/kubelet.go:451: Failed to list *v1.Node: Get https://192.168.2.7:6443/api/v1/nodes?fieldSelector=metadata.name%3Dlocalhost.localdomain&limit=500&resourceVersion=0: dial tcp 192.168.2.7:6443: connect: connection refused
Oct  3 23:59:41 localhost journal: E1003 15:59:41.572566       1 reflector.go:134] k8s.io/client-go/informers/factory.go:131: Failed to list *v1beta1.PodDisruptionBudget: Get https://192.168.2.7:6443/apis/policy/v1beta1/poddisruptionbudgets?limit=500&resourceVersion=0: dial tcp 192.168.2.7:6443: connect: connection refused
Oct  3 23:59:41 localhost kubelet: E1003 23:59:41.580625    6212 kubelet.go:2236] node "localhost.localdomain" not found
Oct  3 23:59:41 localhost kubelet: E1003 23:59:41.616714    6212 eviction_manager.go:243] eviction manager: failed to get get summary stats: failed to get node info: node "localhost.localdomain" not found
Oct  3 23:59:41 localhost kubelet: E1003 23:59:41.681075    6212 kubelet.go:2236] node "localhost.localdomain" not found
Oct  3 23:59:41 localhost kubelet: E1003 23:59:41.785665    6212 kubelet.go:2236] node "localhost.localdomain" not found
Oct  3 23:59:41 localhost journal: E1003 15:59:41.814269       1 reflector.go:134] k8s.io/client-go/informers/factory.go:131: Failed to list *v1.StorageClass: Get https://192.168.2.7:6443/apis/storage.k8s.io/v1/storageclasses?limit=500&resourceVersion=0: dial tcp 192.168.2.7:6443: connect: connection refused
Oct  3 23:59:41 localhost journal: E1003 15:59:41.816775       1 reflector.go:134] k8s.io/client-go/informers/factory.go:131: Failed to list *v1.Node: Get https://192.168.2.7:6443/api/v1/nodes?limit=500&resourceVersion=0: dial tcp 192.168.2.7:6443: connect: connection refused
Oct  3 23:59:41 localhost journal: E1003 15:59:41.824664       1 reflector.go:134] k8s.io/client-go/informers/factory.go:131: Failed to list *v1.PersistentVolumeClaim: Get https://192.168.2.7:6443/api/v1/persistentvolumeclaims?limit=500&resourceVersion=0: dial tcp 192.168.2.7:6443: connect: connection refused
Oct  3 23:59:41 localhost journal: E1003 15:59:41.824711       1 reflector.go:134] k8s.io/client-go/informers/factory.go:131: Failed to list *v1.Service: Get https://192.168.2.7:6443/api/v1/services?limit=500&resourceVersion=0: dial tcp 192.168.2.7:6443: connect: connection refused
Oct  3 23:59:41 localhost journal: E1003 15:59:41.827279       1 reflector.go:134] k8s.io/client-go/informers/factory.go:131: Failed to list *v1.PersistentVolume: Get https://192.168.2.7:6443/api/v1/persistentvolumes?limit=500&resourceVersion=0: dial tcp 192.168.2.7:6443: connect: connection refused
Oct  3 23:59:41 localhost kubelet: E1003 23:59:41.887527    6212 kubelet.go:2236] node "localhost.localdomain" not found
Oct  3 23:59:41 localhost journal: E1003 15:59:41.959761       1 leaderelection.go:252] error retrieving resource lock kube-system/kube-controller-manager: Get https://192.168.2.7:6443/api/v1/namespaces/kube-system/endpoints/kube-controller-manager?timeout=10s: dial tcp 192.168.2.7:6443: connect: connection refused
Oct  3 23:59:41 localhost kubelet: E1003 23:59:41.991669    6212 kubelet.go:2236] node "localhost.localdomain" not found
Oct  3 23:59:42 localhost kubelet: E1003 23:59:42.092069    6212 kubelet.go:2236] node "localhost.localdomain" not found
Oct  3 23:59:42 localhost kubelet: E1003 23:59:42.192485    6212 kubelet.go:2236] node "localhost.localdomain" not found
Oct  3 23:59:42 localhost kubelet: E1003 23:59:42.223129    6212 certificate_manager.go:348] Failed while requesting a signed certificate from the master: cannot create certificate signing request: Post https://192.168.2.7:6443/apis/certificates.k8s.io/v1beta1/certificatesigningrequests: dial tcp 192.168.2.7:6443: connect: connection refused
Oct  3 23:59:42 localhost kubelet: E1003 23:59:42.293246    6212 kubelet.go:2236] node "localhost.localdomain" not found
Oct  3 23:59:42 localhost kubelet: E1003 23:59:42.395190    6212 kubelet.go:2236] node "localhost.localdomain" not found
Oct  3 23:59:42 localhost kubelet: E1003 23:59:42.496059    6212 kubelet.go:2236] node "localhost.localdomain" not found
Oct  3 23:59:42 localhost kubelet: E1003 23:59:42.558527    6212 reflector.go:134] k8s.io/kubernetes/pkg/kubelet/config/apiserver.go:47: Failed to list *v1.Pod: Get https://192.168.2.7:6443/api/v1/pods?fieldSelector=spec.nodeName%3Dlocalhost.localdomain&limit=500&resourceVersion=0: dial tcp 192.168.2.7:6443: connect: connection refused
Oct  3 23:59:42 localhost journal: E1003 15:59:42.558373       1 reflector.go:134] k8s.io/client-go/informers/factory.go:131: Failed to list *v1.ReplicationController: Get https://192.168.2.7:6443/api/v1/replicationcontrollers?limit=500&resourceVersion=0: dial tcp 192.168.2.7:6443: connect: connection refused
Oct  3 23:59:42 localhost journal: E1003 15:59:42.558865       1 reflector.go:134] k8s.io/kubernetes/cmd/kube-scheduler/app/server.go:178: Failed to list *v1.Pod: Get https://192.168.2.7:6443/api/v1/pods?fieldSelector=status.phase%21%3DFailed%2Cstatus.phase%21%3DSucceeded&limit=500&resourceVersion=0: dial tcp 192.168.2.7:6443: connect: connection refused
Oct  3 23:59:42 localhost journal: E1003 15:59:42.560291       1 reflector.go:134] k8s.io/client-go/informers/factory.go:131: Failed to list *v1.ReplicaSet: Get https://192.168.2.7:6443/apis/apps/v1/replicasets?limit=500&resourceVersion=0: dial tcp 192.168.2.7:6443: connect: connection refused
Oct  3 23:59:42 localhost kubelet: E1003 23:59:42.562395    6212 reflector.go:134] k8s.io/kubernetes/pkg/kubelet/kubelet.go:442: Failed to list *v1.Service: Get https://192.168.2.7:6443/api/v1/services?limit=500&resourceVersion=0: dial tcp 192.168.2.7:6443: connect: connection refused
Oct  3 23:59:42 localhost journal: E1003 15:59:42.570113       1 reflector.go:134] k8s.io/client-go/informers/factory.go:131: Failed to list *v1.StatefulSet: Get https://192.168.2.7:6443/apis/apps/v1/statefulsets?limit=500&resourceVersion=0: dial tcp 192.168.2.7:6443: connect: connection refused
Oct  3 23:59:42 localhost kubelet: E1003 23:59:42.575080    6212 reflector.go:134] k8s.io/kubernetes/pkg/kubelet/kubelet.go:451: Failed to list *v1.Node: Get https://192.168.2.7:6443/api/v1/nodes?fieldSelector=metadata.name%3Dlocalhost.localdomain&limit=500&resourceVersion=0: dial tcp 192.168.2.7:6443: connect: connection refused
Oct  3 23:59:42 localhost journal: E1003 15:59:42.574473       1 reflector.go:134] k8s.io/client-go/informers/factory.go:131: Failed to list *v1beta1.PodDisruptionBudget: Get https://192.168.2.7:6443/apis/policy/v1beta1/poddisruptionbudgets?limit=500&resourceVersion=0: dial tcp 192.168.2.7:6443: connect: connection refused
Oct  3 23:59:42 localhost kubelet: E1003 23:59:42.602656    6212 kubelet.go:2236] node "localhost.localdomain" not found
Oct  3 23:59:42 localhost kubelet: E1003 23:59:42.702910    6212 kubelet.go:2236] node "localhost.localdomain" not found
Oct  3 23:59:42 localhost kubelet: E1003 23:59:42.803576    6212 kubelet.go:2236] node "localhost.localdomain" not found
```



#开机后重新走一遍配置，初始化K8S启动ok
```
kubeadm reset
kubeadm init --kubernetes-version=v1.12.0 --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=192.168.2.7
```
 

---
 
初始化K8S启动ok
 ```
#初始化K8S显示
[root@localhost ~]# kubeadm init --kubernetes-version=v1.12.0 --pod-network-cidr=10.244.0.0/16
[init] using Kubernetes version: v1.12.0
[preflight] running pre-flight checks
[preflight/images] Pulling images required for setting up a Kubernetes cluster
[preflight/images] This might take a minute or two, depending on the speed of your internet connection
[preflight/images] You can also perform this action in beforehand using 'kubeadm config images pull'
[kubelet] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[preflight] Activating the kubelet service
[certificates] Generated ca certificate and key.
[certificates] Generated apiserver-kubelet-client certificate and key.
[certificates] Generated apiserver certificate and key.
[certificates] apiserver serving cert is signed for DNS names [localhost.localdomain kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local] and IPs [10.96.0.1 192.168.2.7]
[certificates] Generated front-proxy-ca certificate and key.
[certificates] Generated front-proxy-client certificate and key.
[certificates] Generated etcd/ca certificate and key.
[certificates] Generated apiserver-etcd-client certificate and key.
[certificates] Generated etcd/server certificate and key.
[certificates] etcd/server serving cert is signed for DNS names [localhost.localdomain localhost] and IPs [127.0.0.1 ::1]
[certificates] Generated etcd/peer certificate and key.
[certificates] etcd/peer serving cert is signed for DNS names [localhost.localdomain localhost] and IPs [192.168.2.7 127.0.0.1 ::1]
[certificates] Generated etcd/healthcheck-client certificate and key.
[certificates] valid certificates and keys now exist in "/etc/kubernetes/pki"
[certificates] Generated sa key and public key.
[kubeconfig] Wrote KubeConfig file to disk: "/etc/kubernetes/admin.conf"
[kubeconfig] Wrote KubeConfig file to disk: "/etc/kubernetes/kubelet.conf"
[kubeconfig] Wrote KubeConfig file to disk: "/etc/kubernetes/controller-manager.conf"
[kubeconfig] Wrote KubeConfig file to disk: "/etc/kubernetes/scheduler.conf"
[controlplane] wrote Static Pod manifest for component kube-apiserver to "/etc/kubernetes/manifests/kube-apiserver.yaml"
[controlplane] wrote Static Pod manifest for component kube-controller-manager to "/etc/kubernetes/manifests/kube-controller-manager.yaml"
[controlplane] wrote Static Pod manifest for component kube-scheduler to "/etc/kubernetes/manifests/kube-scheduler.yaml"
[etcd] Wrote Static Pod manifest for a local etcd instance to "/etc/kubernetes/manifests/etcd.yaml"
[init] waiting for the kubelet to boot up the control plane as Static Pods from directory "/etc/kubernetes/manifests" 
[init] this might take a minute or longer if the control plane images have to be pulled
[apiclient] All control plane components are healthy after 148.008147 seconds
[uploadconfig] storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace
[kubelet] Creating a ConfigMap "kubelet-config-1.12" in namespace kube-system with the configuration for the kubelets in the cluster
[markmaster] Marking the node localhost.localdomain as master by adding the label "node-role.kubernetes.io/master=''"
[markmaster] Marking the node localhost.localdomain as master by adding the taints [node-role.kubernetes.io/master:NoSchedule]
[patchnode] Uploading the CRI Socket information "/var/run/dockershim.sock" to the Node API object "localhost.localdomain" as an annotation
[bootstraptoken] using token: eqbfou.1wxvkn31lq7dfi6f
[bootstraptoken] configured RBAC rules to allow Node Bootstrap tokens to post CSRs in order for nodes to get long term certificate credentials
[bootstraptoken] configured RBAC rules to allow the csrapprover controller automatically approve CSRs from a Node Bootstrap Token
[bootstraptoken] configured RBAC rules to allow certificate rotation for all node client certificates in the cluster
[bootstraptoken] creating the "cluster-info" ConfigMap in the "kube-public" namespace
[addons] Applied essential addon: CoreDNS
[addons] Applied essential addon: kube-proxy

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

上面最后一段的输出信息保存一份，后续添加工作节点还要用到。


---
 重新开机，报错
The connection to the server localhost:8080 was refused - did you specify the right host or port?

解决方法：
需要开启api server 代理端口：
查看端口是否代理：curl localhost:8080/api
开启端口代理：`kubectl proxy --port=8080 &`
参考：https://yq.aliyun.com/articles/14959


接着报错：

I1004 07:48:34.948027    8940 log.go:172] http: Accept error: accept tcp 127.0.0.1:8080: accept4: too many open files; retrying in 5ms
I1004 07:48:34.948455    8940 log.go:172] http: proxy error: dial tcp 127.0.0.1:8080: socket: too many open files

[root@k8smaster ~]# kubectl get pods --all-namespaces
I1004 08:17:50.706820    8940 log.go:172] http: Accept error: accept tcp 127.0.0.1:8080: accept4: too many open files; retrying in 5ms
I1004 08:17:50.707295    8940 log.go:172] http: proxy error: dial tcp 127.0.0.1:8080: socket: too many open files
I1004 08:17:51.500327    8940 log.go:172] http: Accept error: accept tcp 127.0.0.1:8080: accept4: too many open files; retrying in 5ms
I1004 08:17:51.500633    8940 log.go:172] http: proxy error: dial tcp 127.0.0.1:8080: socket: too many open files
I1004 08:17:52.704898    8940 log.go:172] http: Accept error: accept tcp 127.0.0.1:8080: accept4: too many open files; retrying in 5ms
I1004 08:17:52.705694    8940 log.go:172] http: proxy error: dial tcp 127.0.0.1:8080: socket: too many open files
I1004 08:17:53.549209    8940 log.go:172] http: Accept error: accept tcp 127.0.0.1:8080: accept4: too many open files; retrying in 5ms
I1004 08:17:53.549874    8940 log.go:172] http: proxy error: dial tcp 127.0.0.1:8080: socket: too many open files

解决方法：
暂时：重启系统
systemctl restart docker
systemctl restart kubelet


---
[root@k8smaster ~]# kubectl get nodes
NAME        STATUS     ROLES    AGE   VERSION
k8smaster   Ready      master   26m   v1.12.0
k8snode1    NotReady   <none>   10m   v1.12.0

节点状态NotReady排查：
```
journalctl -f -u kubelet
```

log：
Oct 05 15:16:57 k8snode1 kubelet[2968]: E1005 15:16:57.908081    2968 kubelet.go:2167] Container runtime network not ready: NetworkReady=false reason:NetworkPluginNotReady message:docker: network plugin is not ready: cni config uninitialized
Oct 05 15:17:02 k8snode1 kubelet[2968]: W1005 15:17:02.910454    2968 cni.go:188] Unable to update cni config: No networks found in /etc/cni/net.d
Oct 05 15:17:02 k8snode1 kubelet[2968]: E1005 15:17:02.911939    2968 kubelet.go:2167] Container runtime network not ready: NetworkReady=false reason:NetworkPluginNotReady message:docker: network plugin is not ready: cni config uninitialized
Oct 05 15:17:03 k8snode1 kubelet[2968]: E1005 15:17:03.801513    2968 summary_sys_containers.go:45] Failed to get system container stats for "/system.slice/kubelet.service": failed to get cgroup stats for "/system.slice/kubelet.service": failed to get container info for "/system.slice/kubelet.service": unknown container "/system.slice/kubelet.service"
Oct 05 15:17:03 k8snode1 kubelet[2968]: E1005 15:17:03.801595    2968 summary_sys_containers.go:45] Failed to get system container stats for "/system.slice/docker.service": failed to get cgroup stats for "/system.slice/docker.service": failed to get container info for "/system.slice/docker.service": unknown container "/system.slice/docker.service"

解决：
unkown
