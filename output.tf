output "master_ip" {
  value = module.master.ipv4_address
}

output "worker1_ip" {
  value = module.worker1.ipv4_address
}

output "worker2_ip" {
  value = module.worker2.ipv4_address
}

output "all_ips" {
  value = [
    module.master.ipv4_address,
    module.worker1.ipv4_address,
    module.worker2.ipv4_address
  ]
}