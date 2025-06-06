cpu                    = 4
cores-per-socket       = 1
ram                    = 4096
disksize               = 60 # in GB
vm-guest-id            = "ubuntu64Guest"
vsphere-unverified-ssl = "true"
vsphere-datacenter     = "Datacenter-Gav"
#vsphere-cluster       = "Cluster01"
vm-datastore           = "STORAGE-01"
vm-network             = "VM Network"
vm-domain              = "home"
dns_server_list        = ["1.1.1.1", "8.8.8.8"]
name                   = "k8s-master-01"
ipv4_address           = "10.20.2.17"
ipv4_gateway           = "10.20.2.1"
ipv4_netmask           = "23"
vm-template-name       = "Ubuntu-2204-Template-60GB-Thin"
vsphere_host           = "10.20.2.8"
vsphere_user           = "administrator@vcenter.local"
vsphere_password       = ""
vsphere_vcenter        = "10.20.2.20"
private_key_path       = "~/.ssh/id_rsa"
