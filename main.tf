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

#===========================#
#       Shape VMs           #
#===========================#


module "master" {
  source           = "./modules/vm"
  name             = "k8s-master"
  cpu              = 4
  cores_per_socket = 1
  ram              = 8192
  disk_size        = 60
  ipv4_address     = "10.20.2.16"
  ipv4_gateway     = "10.20.2.1"
  ipv4_netmask     = "23"
  dns_server_list  = ["1.1.1.1", "8.8.8.8"]
  ssh_username     = var.ssh_username
  public_key       = var.public_key
  private_key_path = var.private_key_path
  vsphere_datacenter = var.vsphere-datacenter
  vm_datastore     = var.vm-datastore
  vsphere_host     = var.vsphere_host
  vm_network       = var.vm-network
  vm_template_name = var.vm-template-name
  vm_guest_id      = var.vm-guest-id
}

module "worker1" {
  source           = "./modules/vm"
  name             = "k8s-worker-1"
  cpu              = 2
  cores_per_socket = 1
  ram              = 4096
  disk_size        = 60
  ipv4_address     = "10.20.2.17"
  ipv4_gateway     = "10.20.2.1"
  ipv4_netmask     = "23"
  dns_server_list  = ["1.1.1.1", "8.8.8.8"]
  ssh_username     = var.ssh_username
  public_key       = var.public_key
  private_key_path = var.private_key_path
  vsphere_datacenter = var.vsphere-datacenter
  vm_datastore     = var.vm-datastore
  vsphere_host     = var.vsphere_host
  vm_network       = var.vm-network
  vm_template_name = var.vm-template-name
  vm_guest_id      = var.vm-guest-id
}

module "worker2" {
  source           = "./modules/vm"
  name             = "k8s-worker-2"
  cpu              = 2
  cores_per_socket = 1
  ram              = 4096
  disk_size        = 60
  ipv4_address     = "10.20.2.18"
  ipv4_gateway     = "10.20.2.1"
  ipv4_netmask     = "23"
  dns_server_list  = ["1.1.1.1", "8.8.8.8"]
  ssh_username     = var.ssh_username
  public_key       = var.public_key
  private_key_path = var.private_key_path
  vsphere_datacenter = var.vsphere-datacenter
  vm_datastore     = var.vm-datastore
  vsphere_host     = var.vsphere_host
  vm_network       = var.vm-network
  vm_template_name = var.vm-template-name
  vm_guest_id      = var.vm-guest-id
}