variable "dns_zone_id" {
  default = "none"
}
variable "dns_record_ttl" {
  default = 60
}
data "yandex_dns_zone" "zone" {
  dns_zone_id = var.dns_zone_id
}
