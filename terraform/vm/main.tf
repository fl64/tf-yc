variable "dns_zone_id" {
  default = "none"
}

module "vm" {

  source        = "../../modules/vm-instance"
  instance_name = "vm"
  description   = "vm"
  vm_count      = 1
  labels = {
    env     = "test",
  }
  allow_stopping_for_update = true
  preemptible               = true
  network_interfaces = [
    {
      subnet_id = yandex_vpc_subnet.vpc-subnet-0.id,
      # ip_address = "192.168.99.10",
      nat = true,
      security_group_ids = [
        yandex_vpc_security_group.ssh-access.id
    ] }
  ]
  mountpoint  = "/mount/data"
  #dns_zone_id = var.dns_zone_id
}

resource "yandex_vpc_security_group" "ssh-access" {
  name        = "ssh-access"
  description = "Allow all ingress and egress ssh"
  network_id  = yandex_vpc_network.vpc-network.id

  ingress {
    protocol       = "TCP"
    description    = "Allow ssh access"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }
  egress {
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}


resource "yandex_vpc_network" "vpc-network" {
  name = "vpc-network"
}

resource "yandex_vpc_subnet" "vpc-subnet-0" {
  name = "vpc-subnet-0"
  //zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.vpc-network.id
  v4_cidr_blocks = ["192.168.99.0/24"]
}

output "vm-info" {
  value = module.vm.vm-info
}
