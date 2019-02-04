#!/bin/bash
set -xe
 
: ${CALICO_VER:="v3.3"}
 
#NOTE: install required packages on host
sudo apt-get update
sudo apt-get install -y \
    docker.io \
    socat \
    ca-certificates \
    nmap \
    curl \
    uuid-runtime \
    jq \
    util-linux \
    bridge-utils \
    libxtables11
 
sudo apt-get update
sudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo bash -c 'cat >/etc/apt/sources.list.d/kubernetes.list' << EOF
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
 
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
 
sudo kubeadm init --pod-network-cidr=192.168.0.0/16
 
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
 
kubectl apply -f https://docs.projectcalico.org/${CALICO_VER}/getting-started/kubernetes/installation/hosted/rbac-kdd.yaml
kubectl apply -f https://docs.projectcalico.org/${CALICO_VER}/getting-started/kubernetes/installation/hosted/kubernetes-datastore/calico-networking/1.7/calico.yaml
kubectl wait --timeout=240s --for=condition=Ready nodes/$(hostname)
kubectl --namespace=kube-system wait --timeout=240s --for=condition=Ready pods -l k8s-app=kube-dns
kubectl taint nodes --all node-role.kubernetes.io/master-

