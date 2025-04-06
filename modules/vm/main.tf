locals {
  templatevars = {
    name            = var.name
    ipv4_address    = var.ipv4_address
    ipv4_gateway    = var.ipv4_gateway
    dns_server_1    = var.dns_server_list[0]
    dns_server_2    = var.dns_server_list[1]
    public_key      = var.public_key
    ssh_username    = var.ssh_username
    ipv4_workers    = [for i in range(1, 3) : format("10.20.2.%d", 16 + i)]
  }
}

resource "vsphere_virtual_machine" "vm" {
  name             = var.name
  resource_pool_id = data.vsphere_host.host.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id

  num_cpus             = var.cpu
  num_cores_per_socket = var.cores_per_socket
  memory               = var.ram
  guest_id             = var.vm_guest_id

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = "vmxnet3"
  }

  disk {
    label            = "${var.name}-disk"
    thin_provisioned = true
    size             = var.disk_size
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
  }

  extra_config = {
    "guestinfo.metadata"          = base64encode(templatefile("${path.module}/templates/metadata.yaml", local.templatevars))
    "guestinfo.metadata.encoding" = "base64"
    "guestinfo.userdata"          = base64encode(templatefile("${path.module}/templates/userdata.yaml", local.templatevars))
    "guestinfo.userdata.encoding" = "base64"
  }
  provisioner "remote-exec" {
    script = "${path.module}/scripts/kubeadm_install.sh"

    connection {
      type        = "ssh"
      user        = var.ssh_username
      private_key = file(var.private_key_path)
      host        = self.default_ip_address
    }
  }
}
#===========================#
#       Data Sources        #
#===========================#
# Data sources are used to fetch information about existing resources in vSphere.
data "vsphere_datacenter" "dc" {
  name = var.vsphere_datacenter
}

data "vsphere_datastore" "datastore" {
  name          = var.vm_datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_host" "host" {
  name          = var.vsphere_host
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = var.vm_network
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = var.vm_template_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "null_resource" "configure_network" {
  triggers = {
    ipv4_address = var.ipv4_address
  }

  # Step 1: Remove conflicting cloud-init configurations and reboot
  provisioner "remote-exec" {
    inline = [
      "sudo rm -f /etc/netplan/50-cloud-init.yaml",
      "sudo cloud-init clean",
      "sudo reboot"
    ]

    connection {
      type        = "ssh"
      user        = var.ssh_username
      private_key = file(var.private_key_path)
      host        = vsphere_virtual_machine.vm.default_ip_address
    }

    on_failure = continue
  }

  # Step 2: Wait for the machine to become reachable
  provisioner "local-exec" {
    command = <<EOT
    while ! ping -c 1 -W 1 ${var.ipv4_address}; do
      echo "Waiting for VM to become reachable at ${var.ipv4_address}..."
      sleep 5
    done
    EOT
  }

 depends_on = [vsphere_virtual_machine.vm]
}


resource "null_resource" "master" {
  count = var.name == "k8s-master" ? 1 : 0

  # Aguarda até que a VM esteja acessível
  provisioner "local-exec" {
    command = <<EOT
    while ! ping -c 1 -W 1 ${var.ipv4_address}; do
      echo "Aguardando a VM master ficar acessível no IP ${var.ipv4_address}..."
      sleep 5
    done
    echo "VM master está acessível no IP ${var.ipv4_address}."
    EOT
  }
  # Executa o comando remoto no master
  provisioner "remote-exec" {
    script = "${path.module}/scripts/init_kubernetes_master.sh"

    connection {
      type        = "ssh"
      user        = var.ssh_username
      private_key = file(var.private_key_path)
      host        = var.ipv4_address
    }
    on_failure = continue
  }
  provisioner "local-exec" {
    command = <<EOT
    ssh -o StrictHostKeyChecking=no -i ${var.private_key_path} ${var.ssh_username}@${var.ipv4_address} \
    "awk '/kubeadm join/{flag=1; print; next} flag && /^\\s/{print; next} {flag=0}' /tmp/kubeadm_init.txt" > ./kubeadm_join_command.txt
    EOT
  }
  depends_on = [vsphere_virtual_machine.vm]
}


resource "null_resource" "workers" {
  for_each = toset(local.templatevars.ipv4_workers)

  # Transfere o arquivo kubeadm_join_command.txt para o node
  provisioner "remote-exec" {
    inline = [
      "echo '${base64encode(file("./kubeadm_join_command.txt"))}' | base64 -d > /tmp/kubeadm_join_command.sh",
      "chmod +x /tmp/kubeadm_join_command.sh",
      "sudo /tmp/kubeadm_join_command.sh"
    ]

    connection {
      type        = "ssh"
      user        = var.ssh_username
      private_key = file(var.private_key_path)
      host        = each.key
      timeout     = "2m"
    }
    on_failure = continue
}
  depends_on = [null_resource.master] # Garante que o master esteja configurado antes
}

resource "null_resource" "kubectl_command" {
  provisioner "local-exec" {
    command = <<EOT
    ssh -o StrictHostKeyChecking=no -i ${var.private_key_path} ${var.ssh_username}@${var.ipv4_address} \
    "kubectl get nodes -o wide"
    EOT
    
  }
  
}