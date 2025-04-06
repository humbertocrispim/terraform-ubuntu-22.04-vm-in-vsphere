#===========================#
# VMware vCenter connection #
#===========================#

variable "vsphere_user" {
  type        = string
  description = "VMware vSphere user name"
  default = "administrator@vcenter.local"
}

variable "vsphere_password" {
  type        = string
  description = "VMware vSphere password"
  sensitive = true
}

variable "vsphere_vcenter" {
  type        = string
  description = "VMWare vCenter server FQDN / IP"
  default = "10.20.2.20"
  
}

variable "vsphere_host" {
  description = "Nome do host no vSphere"
  type        = string
}

variable "vsphere-unverified-ssl" {
  type        = string
  description = "Is the VMware vCenter using a self signed certificate (true/false)"
}

variable "vsphere-datacenter" {
  type        = string
  description = "VMWare vSphere datacenter"
}

variable "vsphere-cluster" {
  type        = string
  description = "VMWare vSphere cluster"
  default     = ""
}

variable "vsphere-template-folder" {
  type        = string
  description = "Template folder"
  default = "Templates"
}

#================================#
# VMware vSphere virtual machine #
#================================#

variable "name" {
  type        = string
  description = "The name of the vSphere virtual machines and the hostname of the machine"
}

variable "vm-name-prefix" {
  type        = string
  description = "Name of VM prefix"
  default     =  "k3sup"
}

variable "vm-datastore" {
  type        = string
  description = "Datastore used for the vSphere virtual machines"
}

variable "vm-network" {
  type        = string
  description = "Network used for the vSphere virtual machines"
}

variable "vm-linked-clone" {
  type        = string
  description = "Use linked clone to create the vSphere virtual machine from the template (true/false). If you would like to use the linked clone feature, your template need to have one and only one snapshot"
  default     = "false"
}

variable "cpu" {
  description = "Number of vCPU for the vSphere virtual machines"
  default     = 2
}

variable "cores-per-socket" {
  description = "Number of cores per cpu for workers"
  default     = 1
}

variable "ram" {
  description = "Amount of RAM for the vSphere virtual machines (example: 2048)"
}

variable "disksize" {
  description = "Disk size, example 100 for 100 GB"
  default = ""
}

variable "vm-guest-id" {
  type        = string
  description = "The ID of virtual machines operating system"
}

variable "vm-template-name" {
  type        = string
  description = "The template to clone to create the VM"
}

variable "vm-domain" {
  type        = string
  description = "Linux virtual machine domain name for the machine. This, along with host_name, make up the FQDN of the virtual machine"
  default     = ""
}

variable "dns_server_list" {
  type = list(string)
  description = "List of DNS servers"
  default = ["8.8.8.8", "8.8.4.4"]
}

variable "ipv4_address" {
  type = string
  description = "ipv4 addresses for a vm"
}

variable "ipv4_gateway" {
  type = string
}

variable "ipv4_netmask" {
  type = string
}

variable "ssh_username" {
  type      = string
  sensitive = true
  default   = "gavtech"
}

variable "public_key" {
  type        = string
  description = "Public key to be used to ssh into a machine"
  default     = "AAAAB3NzaC1yc2EAAAADAQABAAABgQDPnWw5/DvxJq1l6CNBC14DxDT6RCrX6GLC8YLuc8B44azyMf8YatyIVomStmo2iOzkhbdRxnyn7yI5WDERU58VXvwqadPHy0G4h1suQ3VYSYlur4dWNrxK8Xz2tKDlp98wqXaXqxIFLnJDyQs7IwaQQTR+jp4C++mfEcImncbxu9oFx6DhceVACUDC77xcIfz539ENJn4fe6E1Khnhv5iZd0AhySvMog3ZiU+t2X66fEcG++IsP8b457ITPBL4rIbk0Tn2dsnqGcx9WAnPgfxpC0aI21pSWj3w0RG2gT4yY3AWW8wO1DXhbaCiUFUGNE+CiRVtROktqvrH0UGcgG86X4bG0Zo1I1HP+4nYhk15gxd32lyEYH6MhZa3L2zjHv2sbei5zNm0GLUC6SkWfmvIrCDW/7Utbq85gv/BVhxzIeN45A0NmNrlBUPXgwRS8B3bJw6suIvdSnQQ6tsnGMQHEFxeTIGBH5QnhUHAXZ6cPErrstUnkMAAzARdsiUvkok= humberto.crispim@Humbertos-Macbook-Air.local"
}

variable "private_key_path" {
  type        = string
  description = "Path to the private key to be used to ssh into a machine"

}