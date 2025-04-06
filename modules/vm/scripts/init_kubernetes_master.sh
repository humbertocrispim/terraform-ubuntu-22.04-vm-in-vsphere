#!/bin/bash

# Verifica se o Kubernetes já está configurado
if [ -f /etc/kubernetes/admin.conf ]; then
  echo "Kubernetes já configurado. Pulando kubeadm init."
  exit 0
fi

# Executa o kubeadm init
sudo kubeadm init --pod-network-cidr=10.10.0.0/16 --apiserver-advertise-address=$1 | tee /tmp/kubeadm_init.txt

# Configura o kubeconfig para o usuário atual
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Extrai o comando kubeadm join
awk '/kubeadm join/{flag=1; print; next} flag && /^\\s/{print; next} {flag=0}' /tmp/kubeadm_init.txt > /tmp/kubeadm_join_command.txt