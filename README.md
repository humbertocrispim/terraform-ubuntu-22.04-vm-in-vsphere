# Terraform Ubuntu 22.04 VM in vSphere

Este projeto utiliza Terraform para provisionar máquinas virtuais (VMs) no vSphere com o sistema operacional Ubuntu 22.04. Ele inclui a configuração de um nó master e workers para um cluster Kubernetes.

## Estrutura do Projeto

- **`main.tf`**: Configuração principal para provisionar os módulos.
- **`variables.tf`**: Declaração de variáveis utilizadas no projeto.
- **`outputs.tf`**: Saídas do Terraform, como endereços IP das VMs.
- **`vars.auto.tfvars`**: Valores padrão para as variáveis.
- **`modules/vm`**: Módulo reutilizável para criar VMs no vSphere.

## Pré-requisitos

- Terraform instalado ([Guia de instalação](https://developer.hashicorp.com/terraform/tutorials)).
- Acesso ao vSphere com permissões para criar VMs.
- Chave SSH configurada para acesso às VMs.

## Configuração

1. Clone este repositório:
   ```bash
   git clone https://github.com/seu-usuario/terraform-ubuntu-22.04-vm-in-vsphere.git
   cd terraform-ubuntu-22.04-vm-in-vsphere



2. Configure o arquivo vars.auto.tfvars com os valores apropriados para o seu ambiente.

3. Inicialize o Terraform:
    ``` bash
    terraform init
4. Valide o plano

    ```bash
    terraform plan
5. Aplique as configurações:

    ```bash
    terraform apply -auto-approve
Estrutura de Módulos
O módulo vm é responsável por criar as VMs no vSphere. Ele inclui:

Configuração de CPU, RAM e disco.
Configuração de rede.
Provisioners para inicializar o cluster Kubernetes.
Saídas
Endereço IP do nó master.
Endereços IP dos workers.
Comando kubeadm join para adicionar os workers ao cluster.
Licença
Este projeto está licenciado sob a licença MIT. Consulte o arquivo LICENSE para mais detalhes.

