variable "name" {}
variable "cpu" {}
variable "cores_per_socket" {}
variable "ram" {}
variable "disk_size" {}
variable "ipv4_address" {}
variable "ipv4_gateway" {}
variable "ipv4_netmask" {}
variable "dns_server_list" {
  type = list(string)
}
variable "ssh_username" {}
variable "public_key" {}
variable "vsphere_datacenter" {}
variable "vm_datastore" {}
variable "vsphere_host" {}
variable "vm_network" {}
variable "vm_template_name" {}
variable "vm_guest_id" {}
variable "private_key_path" {
  description = "Path to the private key file for SSH access"
}


