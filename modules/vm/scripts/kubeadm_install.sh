#!/bin/bash

# Função simples de progresso para ambientes tipo Terraform
progress_step() {
    local step="$1"
    echo "==> [$(date +%H:%M:%S)] $step..."
    sleep 1
}

# Função com "barra de progresso fake"
progress_bar_fake() {
    local step="$1"
    echo -n "==> $step ["
    for i in {1..20}; do
        echo -n "#"
        sleep 0.05
    done
    echo "] OK"
}

echo "==== Iniciando a configuração do ambiente Kubernetes ===="

progress_step "Desabilitando swap"
sudo sed -i '/swap/s/^/#/' /etc/fstab
sudo swapoff -a

progress_step "Criando configuração de módulos"
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

progress_step "Carregando módulos do kernel"
sudo modprobe overlay
sudo modprobe br_netfilter

progress_step "Configurando parâmetros sysctl"
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
sudo sysctl --system

progress_bar_fake "Atualizando pacotes e instalando dependências"
sudo apt-get update -y
sudo apt-get install -y apt-transport-https ca-certificates curl gpg

if [ ! -d /etc/apt/keyrings ]; then
    progress_step "Criando diretório /etc/apt/keyrings"
    sudo mkdir -p -m 755 /etc/apt/keyrings
fi

progress_step "Adicionando chave do repositório Kubernetes"
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

progress_step "Adicionando repositório Kubernetes"
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

progress_bar_fake "Instalando kubelet, kubeadm e kubectl"
sudo apt-get update -y
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

progress_step "Habilitando e iniciando o kubelet"
sudo systemctl enable --now kubelet

progress_bar_fake "Removendo pacotes antigos do Docker"
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do 
    sudo apt-get remove -y $pkg
done

progress_step "Adicionando chave do repositório Docker"
sudo apt-get update -y
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

progress_step "Adicionando repositório Docker"
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y

progress_bar_fake "Instalando Containerd"
sudo apt-get install -y containerd.io

progress_step "Configurando Containerd"
sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml

progress_step "Reiniciando Containerd"
sudo systemctl restart containerd

progress_step "Verificando status do Containerd"
sudo systemctl is-active containerd

echo "==== 🎉 Configuração concluída com sucesso! ===="
