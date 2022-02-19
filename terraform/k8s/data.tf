# network
data "yandex_vpc_network" "network" {
  name = "default"
}

# master subnets
data "yandex_vpc_subnet" "master_subnet" {
  for_each = toset(local.master_subnets)
  name     = each.value
}

# nodes subnets
data "yandex_vpc_subnet" "nodes_subnet" {
  for_each = toset(local.nodes_subnets)
  name     = each.value
}

# folder
data "yandex_resourcemanager_folder" "folder" {
  name = "default"
}

data "external" "my_addr" {
  program = ["${path.root}/scripts/get-ip.sh"]
}
