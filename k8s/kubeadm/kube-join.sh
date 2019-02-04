#!/bin/bash
set -xe
 
#$1 - Master IP address
#$2 - token
#$3 - hash
 
sudo apt-get update
sudo apt-get install -y \
    docker.io \
    socat \
    curl \
    ca-certificates
 
sudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo bash -c 'cat >/etc/apt/sources.list.d/kubernetes.list' << EOF
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
 
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
 
sudo kubeadm join --token $2 $1:6443 --discovery-token-ca-cert-hash sha256:$3
