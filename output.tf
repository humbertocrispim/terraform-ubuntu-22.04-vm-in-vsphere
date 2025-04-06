output "master_ip" {
  value = [
    module.master.ipv4_address
  ]
  description = "IP do master"
}

output "worker_ips" {
  value = [
    module.worker1.ipv4_address,
    module.worker2.ipv4_address
  ]
  description = "Lista de IPs dos workers"
}

output "kubeadm_join_command" {
  value = file("./kubeadm_join_command.txt")
}
  
