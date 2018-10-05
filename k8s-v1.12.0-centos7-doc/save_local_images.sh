#!/bin/bash
#save_local_images.sh
logFile="save_local_images.log"
filter=$1
docker images |grep  $filter | awk '{print $3,$1,$2}' | while read line

do
  echo "docker image is : ${line}"
  arr=(${line})
  id=${arr[0]}
  sub_name=${arr[1]//// };
  name=($sub_name)
  len=${#name[@]}
  echo "length $len"
  pkg=${name[$len-1]}"~"${arr[2]}".tar"
  saveAction="docker save $id -o $pkg"
  echo $saveAction
  #save
  docker save $id -o $pkg
  #log
  echo $saveAction >> $logFile
  echo "sleep 2 ---------------"
  sleep 2
done
#docker save 3cab8e1b9802 -o k8s.gcr.io-etcd-amd64-3.2.24.tar
#chmod a+x load_local_images.sh
#执行 sh ./save_local_images.sh stringKey

