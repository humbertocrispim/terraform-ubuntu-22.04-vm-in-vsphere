cpu                    = 4
cores-per-socket       = 1
ram                    = 4096
disksize               = 100 # in GB
vm-guest-id            = "ubuntu64Guest"
vsphere-unverified-ssl = "true"
vsphere-datacenter     = "Datacenter"
vsphere-cluster        = "Cluster01"
vm-datastore           = "Datastore1_SSD"
vm-network             = "VM Network"
vm-domain              = "home"
dns_server_list        = ["192.168.1.80", "8.8.8.8"]
name = "ubuntu22.04-test"
ipv4_address           = "192.168.1.97"
ipv4_gateway           = "192.168.1.254"
ipv4_netmask           = "24"
vm-template-name       = "Ubuntu-2204-Template-100GB-Thin"

# vSphere Specific
vsphere_user = "administrator@vsphere.home"
vsphere_password = "IlGwamh7!"
vsphere_vcenter = "192.168.1.5"
