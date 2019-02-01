#!/bin/bash
set -xe

kubectl create -n kube-system serviceaccount helm-tiller
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: helm-tiller
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: helm-tiller
    namespace: kube-system
EOF

kubectl taint nodes --all node-role.kubernetes.io/master-

curl https://raw.githubusercontent.com/helm/helm/master/scripts/get > get_helm.sh
chmod 700 get_helm.sh
./get_helm.sh

helm init --service-account helm-tiller

kubectl --namespace=kube-system wait \
  --timeout=240s \
  --for=condition=Ready \
  pod -l app=helm,name=tiller

sudo -E tee /etc/systemd/system/helm-serve.service <<EOF
[Unit]
Description=Helm Server
After=network.target
[Service]
User=$(id -un 2>&1)
Restart=always
ExecStart=/usr/local/bin/helm serve
[Install]
WantedBy=multi-user.target
EOF


sudo chmod 0640 /etc/systemd/system/helm-serve.service
sudo systemctl restart helm-serve
sudo systemctl daemon-reload
sudo systemctl enable helm-serve

helm repo add local http://localhost:8879/charts
helm repo update
uptime
make
