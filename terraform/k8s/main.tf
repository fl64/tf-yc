locals {
  k8s_cluster_name = "fl64-net-cluster"
  master_subnets = [
    "default-ru-central1-a",
  ]
  nodes_subnets = [
    "default-ru-central1-a",
  ]
  k8s_labels = {
    "cluster" : local.k8s_cluster_name
  }
  ssh_keys = {
    admin = [
      file("~/.ssh/id_rsa.pub"),
    ],
  }
}


module "k8s-cluster" {
  source             = "../../modules/cluster"
  vpc_network_id     = data.yandex_vpc_network.network.id
  folder_id          = data.yandex_resourcemanager_folder.folder.id
  subnets_ids        = [for subnet in data.yandex_vpc_subnet.master_subnet : subnet.id]
  cluster_name       = local.k8s_cluster_name
  labels             = local.k8s_labels
  security_group_ids = [yandex_vpc_security_group.masters.id]
  depends_on = [
    yandex_vpc_security_group.masters
  ]
}

output "k8s-cluster-info" {
  sensitive = true
  value     = module.k8s-cluster.cluster-info
}

module "k8s-nodes" {
  source             = "../../modules/nodes"
  name               = format("%s-%s", local.k8s_cluster_name, "node-group")
  cluster_id         = module.k8s-cluster.cluster-info.cluster_id
  subnets_ids        = [for subnet in data.yandex_vpc_subnet.nodes_subnet : subnet.id]
  labels             = local.k8s_labels
  node_labels        = local.k8s_labels
  security_group_ids = [yandex_vpc_security_group.nodes.id]
  ssh_keys           = local.ssh_keys
  depends_on = [
    yandex_vpc_security_group.nodes
  ]
}
