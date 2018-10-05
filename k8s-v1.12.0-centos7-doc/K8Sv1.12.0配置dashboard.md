# 配置dashboard
默认是没web界面的，可以在master机器上安装一个dashboard插件，实现通过web来管理

## 下载配置文件
```
wget https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml
```

编辑kubernetes-dashboard.yaml文件，添加type:NodePort，暴露Dashboard服务注意这里只添加行type: NodePort即可，其他配置不用改，大概位置在末尾的Dashboard Service的spec中，162行，参考如下。

# ------------------- Dashboard Service ------------------- #
kind: Service
apiVersion: v1
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard
  namespace: kube-system
spec:
  type: NodePort
  ports:
    - port: 443
      targetPort: 8443
  selector:
    k8s-app: kubernetes-dashboard


## 安装Dashboard插件
```
kubectl create -f kubernetes-dashboard.yaml
```

## 授予Dashboard账户集群管理权限
需要一个管理集群admin的权限，新建kubernetes-dashboard-admin.rbac.yaml文件，内容如下

---
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard-admin
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: kubernetes-dashboard-admin
  labels:
    k8s-app: kubernetes-dashboard
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: kubernetes-dashboard-admin
  namespace: kube-system

执行命令
```
kubectl create -f kubernetes-dashboard-admin.rbac.yaml
```

找到kubernete-dashboard-admin的token，用户登录使用 
执行命令
```
kubectl -n kube-system get secret | grep kubernetes-dashboard-admin
```
```
[root@k8smaster ~]# kubectl -n kube-system get secret | grep kubernetes-dashboard-admin
kubernetes-dashboard-admin-token-fjw48           kubernetes.io/service-account-token   3      118s
```

可以看到名称是"kubernetes-dashboard-admin-token-fjw48"，使用该名称执行如下命令
```
kubectl describe -n kube-system secret/kubernetes-dashboard-admin-token-fjw48
```
```
[root@k8smaster ~]# kubectl describe -n kube-system secret/kubernetes-dashboard-admin-token-fjw48
Name:         kubernetes-dashboard-admin-token-fjw48
Namespace:    kube-system
Labels:       <none>
Annotations:  kubernetes.io/service-account.name: kubernetes-dashboard-admin
              kubernetes.io/service-account.uid: faea604b-c7b8-11e8-adb9-080027c9a5d3

Type:  kubernetes.io/service-account-token

Data
====
ca.crt:     1025 bytes
namespace:  11 bytes
token:      eyJhbGciOiJSUzI1NiIsImtpZCI6IiJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJrdWJlLXN5c3RlbSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm5hbWUiOiJrdWJlcm5ldGVzLWRhc2hib2FyZC1hZG1pbi10b2tlbi1manc0OCIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50Lm5hbWUiOiJrdWJlcm5ldGVzLWRhc2hib2FyZC1hZG1pbiIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6ImZhZWE2MDRiLWM3YjgtMTFlOC1hZGI5LTA4MDAyN2M5YTVkMyIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDprdWJlLXN5c3RlbTprdWJlcm5ldGVzLWRhc2hib2FyZC1hZG1pbiJ9.enPlCC1DRWRbGkMYrLd9W5SR71Ncu8vmhRwCSw9gdiDq0rXKUOazcFwuagtnHExwCJu8XlMz7NFMc0HqaIzB9amoUKrx2QTH0c8_vokcyKOxwa5v_36JJiRI9e7tNDN7AE6L7I3gUsZ2UH7pB6Bzy6UXsaeThsrrIZdAs1F2UV4NDc3XxKPBdH1zDIsrxnrJJP-hndWmW7rEfI09e2PHI9_dh2ZhLVzeWqYLuvzFFqhd4KDl6cpUm1Kk4MNrQotdiwMIcSzrKBVsOjue9i8o6E_XyORq7ZjCE6XWanUNN5jkHMyDKa4WMqIfZputspG0r3xT-MC0fnGL7_c_qkWztg
```

记下这串token，等下登录使用，这个token默认是永久的。
 


## 找出Dashboard服务端口
```
kubectl get svc -n kube-system
```

```
[root@k8smaster ~]# kubectl get svc -n kube-system
NAME                   TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)         AGE
kube-dns               ClusterIP   10.96.0.10       <none>        53/UDP,53/TCP   37m
kubernetes-dashboard   NodePort    10.104.189.186   <none>        443:32534/TCP   8m28s
```

可以看到它对外的端口为32534。 
打开浏览器，访问http://192.168.2.7:32534/#!/login，选择令牌，输入刚才的token即可进入

##  部署heapster插件

```
mkdir -p ~/k8s/heapster
cd ~/k8s/heapster
wget https://raw.githubusercontent.com/kubernetes/heapster/master/deploy/kube-config/influxdb/grafana.yaml
wget https://raw.githubusercontent.com/kubernetes/heapster/master/deploy/kube-config/rbac/heapster-rbac.yaml
wget https://raw.githubusercontent.com/kubernetes/heapster/master/deploy/kube-config/influxdb/heapster.yaml
wget https://raw.githubusercontent.com/kubernetes/heapster/master/deploy/kube-config/influxdb/influxdb.yaml
kubectl create -f ./
```
安装完成后，重新登录即可看到。
