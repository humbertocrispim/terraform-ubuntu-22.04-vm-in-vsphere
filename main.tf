terraform {
  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "2.2.0"
    }
  }
}

provider "vsphere" {
  user                 = var.vsphere_user
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_vcenter
  allow_unverified_ssl = true
}

locals {
  templatevars = {
    name         = var.name,
    ipv4_address = var.ipv4_address,
    ipv4_gateway = var.ipv4_gateway,
    dns_server_1 = var.dns_server_list[0],
    dns_server_2 = var.dns_server_list[1],
    public_key   = var.public_key,
    ssh_username = var.ssh_username
  }
}

# Define VMware vSphere 
data "vsphere_datacenter" "dc" {
  name = var.vsphere-datacenter
}

data "vsphere_datastore" "datastore" {
  name          = var.vm-datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_host" "host" {
  name          = var.vsphere_host
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = var.vm-network
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = "/${var.vsphere-datacenter}/vm/${var.vsphere-template-folder}/${var.vm-template-name}"
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "vm" {
  name             = var.name
  resource_pool_id = data.vsphere_host.host.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id

  num_cpus             = var.cpu
  num_cores_per_socket = var.cores-per-socket
  memory               = var.ram
  guest_id             = var.vm-guest-id

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  disk {
    label            = "${var.name}-disk"
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
    eagerly_scrub    = data.vsphere_virtual_machine.template.disks.0.eagerly_scrub
    size             = var.disksize == "" ? data.vsphere_virtual_machine.template.disks.0.size : var.disksize 
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

  lifecycle {
    ignore_changes = [
      annotation,
      clone[0].template_uuid,
      clone[0].customize[0].dns_server_list,
      clone[0].customize[0].network_interface[0]
    ]
  }
}

# Null resource to manage network configuration
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
