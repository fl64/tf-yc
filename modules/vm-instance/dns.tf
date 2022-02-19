data "yandex_dns_zone" "zone" {
  dns_zone_id = var.dns_zone_id
}

resource "yandex_dns_recordset" "master" {
  count   = var.dns_zone_id == "none" ? 0 : var.vm_count
  zone_id = data.yandex_dns_zone.zone.id
  name    = element(yandex_compute_instance.vm.*.name, count.index)
  type    = "A"
  ttl     = var.dns_record_ttl
  data    = [element(yandex_compute_instance.vm.*.network_interface.0.nat_ip_address, count.index)]
}
