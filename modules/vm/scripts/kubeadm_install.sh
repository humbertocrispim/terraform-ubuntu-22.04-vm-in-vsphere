#!/bin/bash

# Função para exibir uma animação de "trabalhando"
working_animation() {
    for i in {1..10}; do
        tput setaf $((RANDOM % 7)) # Altera a cor do texto aleatoriamente
        echo -n "🔧 Trabalhando... "
        sleep 0.3
        tput cub 15 # Move o cursor 15 posições para trás
    done
    tput sgr0 # Reseta as configurações de cor
    echo -e "\nFinalizado!"
}

# Início do script
echo "Iniciando a configuração do ambiente Kubernetes..."
working_animation

# Desabilitar swap
echo "Disabling swap for Kubernetes..."
sudo swapoff -a
working_animation

# Criar arquivo em /etc/modules-load.d
echo "Criando configuração de módulos..."
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
working_animation

# Carregar módulos do kernel
echo "Carregando módulos do kernel..."
sudo modprobe overlay
sudo modprobe br_netfilter
working_animation

# Configurar parâmetros sysctl
echo "Configurando parâmetros sysctl..."
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
sudo sysctl --system
working_animation

# Verificar portas necessárias
echo "Verificando a porta 6443..."
sudo nc 127.0.0.1 6443 -zv -w 2
if [ $? -eq 0 ]; then
    echo "✅ Porta 6443 está aberta"
else
    echo "❌ Porta 6443 não está aberta. Verifique as configurações do firewall."
    sleep 2
    echo "🔒 Desativando o firewall..."
    sudo ufw disable
    echo "✅ Firewall desativado. Verifique se o kubelet está ativo."
    exit 1
fi
working_animation

# Atualizar pacotes e instalar dependências
echo "⚙️ Atualizando pacotes e instalando dependências..."
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gpg
working_animation

# Criar diretório para chaves, se necessário
if [ ! -d /etc/apt/keyrings ]; then
    echo "Criando diretório /etc/apt/keyrings..."
    sudo mkdir -p -m 755 /etc/apt/keyrings
    working_animation
fi

# Adicionar chave do repositório Kubernetes
echo "Adicionando chave do repositório Kubernetes..."
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
working_animation

# Adicionar repositório Kubernetes
echo "Adicionando repositório Kubernetes..."
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
working_animation

# Instalar kubelet, kubeadm e kubectl
echo "⚙️ Instalando kubelet, kubeadm e kubectl..."
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
working_animation

# Habilitar e iniciar kubelet
echo "Habilitando e iniciando o kubelet..."
sudo systemctl enable --now kubelet
sudo apt-mark hold kubelet kubeadm kubectl
working_animation

# Instalar Containerd
echo "⚙️ Instalando Containerd..."
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done

# Adicionando chave do repositório Docker
echo "Adicionando chave do repositório Docker..."
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
working_animation

# Adicionando repositório Docker
echo "🐳 Adicionando repositório Docker..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
working_animation

# Instalador Containerd
echo "Instalando Containerd..."
sudo apt-get install containerd.io
working_animation

# Configuração do Containerd
echo "Configurando Containerd..."
sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml
# Reiniciar o Containerd
sudo systemctl restart containerd
sudo systemctl status containerd
sudo systemctl enable --now kubelet
working_animation

echo "🎉 Configuração concluída com sucesso!"
