#!/bin/bash
set -xe


sudo apt-key adv --keyserver keyserver.ubuntu.com  --recv 460F3994
RELEASE_NAME=$(grep 'CODENAME' /etc/lsb-release | awk -F= '{print $2}')
sudo add-apt-repository "deb https://download.ceph.com/debian-mimic/ ${RELEASE_NAME} main"
sudo apt-get update
sudo apt-get install -y \
    docker.io \
    socat \
    git \
    ca-certificates \
    make \
    nmap \
    curl \
    uuid-runtime \
    jq \
    util-linux \
    ceph-common \
    rbd-nbd \
    nfs-common \
    bridge-utils \
    libxtables11
sudo tee /etc/modprobe.d/rbd.conf <<EOF
install rbd /bin/true
EOF

sudo apt-get update
sudo apt-get install -y apt-transport-https
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

kubectl apply -f https://docs.projectcalico.org/v3.3/getting-started/kubernetes/installation/hosted/rbac-kdd.yaml
kubectl apply -f https://docs.projectcalico.org/v3.3/getting-started/kubernetes/installation/hosted/kubernetes-datastore/calico-networking/1.7/calico.yaml
kubectl wait --timeout=240s --for=condition=Ready nodes/rkhanbikov-wrkspc
kubectl --namespace=kube-system wait --timeout=240s --for=condition=Ready pods -l k8s-app=kube-dns
