locals {
  regional_cluster = length(var.subnets_ids) > 1 ? [{
    region  = var.yandex_region
    subnets = var.subnets_ids
  }] : []
  zonal_cluster = length(var.subnets_ids) > 1 ? [] : var.subnets_ids
  cilium        = var.network_implementation == "cilium" ? [true] : []
}

# subnets
data "yandex_vpc_subnet" "master_subnet" {
  for_each  = toset(var.subnets_ids)
  subnet_id = each.value
}

# iam
resource "yandex_iam_service_account" "k8s_cluster_sa" {
  name        = var.cluster_sa_name == "" ? "k8s-cluster-sa" : var.cluster_sa_name
  description = "k8s cluster SA"
}

resource "yandex_iam_service_account" "k8s_node_sa" {
  name        = var.node_sa_name == "" ? "k8s-node-sa" : var.node_sa_name
  description = "k8s node SA"
}

resource "yandex_resourcemanager_folder_iam_member" "k8s_cluster_sa_role" {
  folder_id = var.folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.k8s_cluster_sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "k8s_node_sa_role" {
  folder_id = var.folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.k8s_node_sa.id}"
}

resource "yandex_kubernetes_cluster" "k8s_cluster" {
  name                    = var.cluster_name
  description             = var.cluster_description
  folder_id               = var.folder_id
  labels                  = var.labels
  network_id              = var.vpc_network_id
  network_policy_provider = var.network_policy_provider
  master {
    dynamic "zonal" {
      // zonal cluster have only one zone, so let's go...
      for_each = data.yandex_vpc_subnet.master_subnet
      content {
        zone      = zonal.value.zone
        subnet_id = zonal.value.id
      }
    }
    dynamic "regional" {
      for_each = local.regional_cluster
      content {
        region = regional.value["region"]

        dynamic "location" {
          for_each = data.yandex_vpc_subnet.master_subnet
          content {
            zone      = location.value.zone
            subnet_id = location.value.id
          }
        }
      }
    }
    security_group_ids = var.security_group_ids
    public_ip          = var.public_ip
    version            = var.k8s_version

    maintenance_policy {
      auto_upgrade = var.auto_upgrade
      dynamic "maintenance_window" {
        for_each = var.maintenance_window
        content {
          day        = maintenance_window.value.day
          start_time = maintenance_window.value.start_time
          duration   = maintenance_window.value.duration
        }
      }
    }
  }

  service_account_id      = yandex_iam_service_account.k8s_cluster_sa.id
  node_service_account_id = yandex_iam_service_account.k8s_node_sa.id

  cluster_ipv4_range = var.cluster_ipv4_range
  service_ipv4_range = var.service_ipv4_range
  release_channel    = var.release_channel

  network_implementation {
    dynamic "cilium" {
      for_each = local.cilium
      content {
      }
    }
  }
  depends_on = [
    yandex_resourcemanager_folder_iam_member.k8s_cluster_sa_role,
    yandex_resourcemanager_folder_iam_member.k8s_node_sa_role
  ]
}
