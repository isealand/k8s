#!/bin/bash
echo "Docker pull k8s v1.12.0 images:"

#阿里云docker仓库 https://dev.aliyun.com/search.html
#docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/kube-apiserver-amd64:v1.12.0


hubName="registry.cn-hangzhou.aliyuncs.com"
hubPath="$hubName/google_containers"
images=(kube-apiserver-amd64:v1.12.0 kube-controller-manager-amd64:v1.12.0 kube-scheduler-amd64:v1.12.0 kube-proxy-amd64:v1.12.0 pause-amd64:3.1 etcd-amd64:3.2.24 k8s-dns-kube-dns-amd64:1.14.13 k8s-dns-dnsmasq-nanny-amd64:1.14.13 k8s-dns-sidecar-amd64:1.14.13)
for imageName in ${images[@]} ; do
  docker pull $hubPath/$imageName
  docker tag $hubPath/$imageName k8s.gcr.io/$imageName
  docker rmi $hubPath/$imageName
  sleep 2
done


imageNameOther="k8s-install/coredns:v1.2.2"
imageNameTo="coredns/coredns:1.2.2"
docker pull $hubName/$imageNameOther
docker tag $hubName/$imageNameOther $imageNameTo
docker rmi $hubName/$imageNameOther
#or
#imageNameOther="acs/coredns:1.2.2"
#imageNameTo="coredns/coredns:1.2.2"
#docker pull $hubName/$imageNameOther
#docker tag $hubName/$imageNameOther $imageNameTo
#docker rmi $hubName/$imageNameOther

sleep 2

imageNameOther="kube_containers/k8s-dns-kube-dns-amd64:v1.14.10"
imageNameTo="k8s.gcr.io/k8s-dns-kube-dns-amd64:1.14.10"
docker pull $hubName/$imageNameOther
docker tag $hubName/$imageNameOther $imageNameTo
docker rmi $hubName/$imageNameOther

sleep 2

imageNameOther="kubernetes_containers/flannel:v0.10.0-amd64"
imageNameTo="quay.io/coreos/flannel:v0.9.1-amd64"
docker pull $hubName/$imageNameOther
docker tag $hubName/$imageNameOther $imageNameTo
docker rmi $hubName/$imageNameOther
#or
#docker pull registry.cn-beijing.aliyuncs.com/k8s_images/flannel:v0.9.1-amd64
#docker tag registry.cn-beijing.aliyuncs.com/k8s_images/flannel:v0.9.1-amd64 quay.io/coreos/flannel:v0.9.1-amd64
#docker rmi registry.cn-beijing.aliyuncs.com/k8s_images/flannel:v0.9.1-amd64

docker pull $hubName/google_containers/kubernetes-dashboard-amd64:v1.10.0

echo "Docker pull images completed"