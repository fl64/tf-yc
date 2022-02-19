# subnets
data "yandex_vpc_subnet" "nodes_subnet" {
  for_each  = toset(var.subnets_ids)
  subnet_id = each.value
}

resource "yandex_kubernetes_node_group" "k8s_nodes" {
  cluster_id             = var.cluster_id
  name                   = var.name
  description            = var.description
  version                = var.k8s_version
  labels                 = var.labels
  node_labels            = var.node_labels
  node_taints            = var.node_taints
  allowed_unsafe_sysctls = var.allowed_unsafe_sysctls
  instance_template {
    # https://cloud.yandex.ru/docs/compute/concepts/vm-platforms
    platform_id               = var.platform_id
    network_acceleration_type = var.network_acceleration_type
    metadata                  = local.ssh_keys_metadata

    network_interface {
      subnet_ids         = [for subnet in data.yandex_vpc_subnet.nodes_subnet : subnet.id]
      security_group_ids = var.security_group_ids
      nat                = var.nat
    }

    container_runtime {
      type = var.container_runtime
    }

    resources {
      memory        = var.memory
      cores         = var.cores
      core_fraction = var.core_fraction
    }

    boot_disk {
      type = var.boot_disk_type
      size = var.boot_disk_size
    }

    scheduling_policy {
      preemptible = var.preemptible
    }
  }

  scale_policy {
    dynamic "fixed_scale" {
      for_each = local.fixed_scale
      content {
        size = var.size
      }
    }
    dynamic "auto_scale" {
      for_each = local.auto_scale
      content {
        min     = var.autoscale_min
        max     = var.autoscale_max
        initial = var.autoscale_initial
      }
    }
  }
  allocation_policy {
    dynamic "location" {
      for_each = data.yandex_vpc_subnet.nodes_subnet
      content {
        zone = location.value.zone
        //subnet_id = location.value.id
      }
    }

  }
  deploy_policy {
    max_expansion   = var.max_expansion
    max_unavailable = var.max_unavailable
  }
  maintenance_policy {
    auto_upgrade = var.auto_upgrade
    auto_repair  = var.auto_repair
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


locals {
  fixed_scale = var.size != 0 ? [true] : []
  auto_scale  = var.size == 0 ? [true] : []
  ssh_keys_metadata = length(var.ssh_keys) > 0 ? {
    ssh-keys = join("\n", flatten([
      for username, ssh_keys in var.ssh_keys : [
        for ssh_key in ssh_keys
        : "${username}:${ssh_key}"
      ]
    ]))
  } : {}
}
