# Master nodes =================================================================

locals {
  subnet_v4_cidr_blocks = flatten([for subnet in data.yandex_vpc_subnet.nodes_subnet : subnet.v4_cidr_blocks])
  my_ip_subnet = [ format("%s/32", data.external.my_addr.result.ip) ]
}

resource "yandex_vpc_security_group" "masters" {
  name       = "masters sg"
  network_id = data.yandex_vpc_network.network.id
  labels = {
    api = "true"
  }
  egress {
    description    = "Allow egress traffic from worker-nodes"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description    = "Allow ingress traffic form cluster subnets"
    protocol       = "ANY"
    v4_cidr_blocks = local.subnet_v4_cidr_blocks
  }

  ingress {
    description    = "Allow ingress traffic from my host"
    protocol       = "TCP"
    v4_cidr_blocks = local.my_ip_subnet
  }
}



# Worker nodes =================================================================

resource "yandex_vpc_security_group" "nodes" {
  name       = "nodes sg"
  network_id = data.yandex_vpc_network.network.id
  labels = {
    nodes = "true"
  }

  egress {
    description    = "Allow egress traffic from worker-nodes"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description    = "Allow ingress traffic form cluster subnets"
    protocol       = "ANY"
    v4_cidr_blocks = local.subnet_v4_cidr_blocks
  }

  ingress {
    description    = "Allow access form LB to nodePort range"
    protocol       = "TCP"
    from_port      = 30000
    to_port        = 32767
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description    = "Allow access form LB to kublet health port"
    protocol       = "TCP"
    port           = 10256
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

}
