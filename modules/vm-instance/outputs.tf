output "vm-info" {
  value = [
    for item in yandex_compute_instance.vm : {
      ip_addr     = tolist(item.network_interface[*].ip_address)
      nat_ip_addr = item.network_interface[*].nat_ip_address
      labels      = item.labels
      fqdn        = var.dns_zone_id != "none" ? join(".", [item.name, data.yandex_dns_zone.zone.name]) : null
    }
  ]
}
