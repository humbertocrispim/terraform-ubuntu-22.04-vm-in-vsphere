locals {
  templatevars = {
    name            = var.name
    ipv4_address    = var.ipv4_address
    ipv4_gateway    = var.ipv4_gateway
    dns_server_1    = var.dns_server_list[0]
    dns_server_2    = var.dns_server_list[1]
    public_key      = var.public_key
    ssh_username    = var.ssh_username
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
    inline = [
      "sudo kubeadm init --pod-network-cidr=10.10.0.0/16 --apiserver-advertise-address=${var.ipv4_address} | tee /tmp/kubeadm_init.txt",
      "mkdir -p $HOME/.kube",
      "sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config",
      "sudo chown $(id -u):$(id -g) $HOME/.kube/config"
    ]

    connection {
      type        = "ssh"
      user        = var.ssh_username
      private_key = file(var.private_key_path)
      host        = self.default_ip_address
    }
  }

  # Capture kubeadm join command and save it locally
  provisioner "local-exec" {
    command = <<EOT
    ssh -o StrictHostKeyChecking=no -i ${var.private_key_path} ${var.ssh_username}@${var.ipv4_address} \
    "grep 'kubeadm join' /tmp/kubeadm_init.txt" > ./kubeadm_join_command.txt
    EOT
  }
}

data "external" "kubeadm_join_command" {
  program = ["bash", "-c", "cat ./kubeadm_join_command.txt"]
}

output "kubeadm_join_command" {
  value = data.external.kubeadm_join_command.result
}

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

resource "vsphere_virtual_machine" "worker" {
  count            = regex("worker", var.name) ? 1 : 0
  name             = "${var.name}-worker"
  resource_pool_id = data.vsphere_host.host.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id

  # Configuração dos workers...

  provisioner "remote-exec" {
    inline = [
      "sudo ${data.external.kubeadm_join_command.result}"
    ]

    connection {
      type        = "ssh"
      user        = var.ssh_username
      private_key = file(var.private_key_path)
      host        = self.default_ip_address
    }
  }

  depends_on = [vsphere_virtual_machine.vm]
}