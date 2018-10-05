#!/bin/bash
#load指定文件夹中所有images的tar

#指定文件夹路径
current_path="."
for file_a in $current_path/*.tar; do
   temp_file=`basename $file_a`
   echo "----------------------$temp_file"
   docker load < $current_path/$temp_file
   sleep 2
done


#docker tag da86e6ba6ca1 k8s.gcr.io/pause:3.1
#docker tag 50e7aa4dbbf8 quay.io/coreos/flannel:v0.9.1-amd64
#docker tag 9c3a9d3f09a0 k8s.gcr.io/kube-proxy:v1.12.0
#docker tag 07e068033cf2 k8s.gcr.io/kube-controller-manager:v1.12.0
#docker tag ab60b017e34f k8s.gcr.io/kube-apiserver:v1.12.0
#docker tag 5a1527e735da k8s.gcr.io/kube-scheduler:v1.12.0
#docker tag 4b2e93f0133d k8s.gcr.io/k8s-dns-sidecar:1.14.13
#docker tag 6dc8ef8287d3 k8s.gcr.io/k8s-dns-dnsmasq-nanny:1.14.13
#docker tag 367cdc8433a4 k8s.gcr.io/coredns:1.2.2#