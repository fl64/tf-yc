variable "k8s_version" {
  type    = string
  default = "1.21"
}

variable "subnets_ids" {
  type = list(string)
}

variable "nat" {
  type    = bool
  default = false
}

variable "security_group_ids" {
  type    = list(string)
  default = []
}

variable "ssh_keys" {
  type    = map(list(string))
  default = {}
}

variable "name" {
  type = string
}

variable "description" {
  type    = string
  default = "k8s workers"
}

variable "cluster_id" {
  type = string
}

variable "platform_id" {
  type    = string
  default = "standard-v1"
}

variable "memory" {
  type    = number
  default = 4
}

variable "cores" {
  type    = number
  default = 2
}
variable "core_fraction" {
  type    = number
  default = 20
}
variable "preemptible" {
  type    = bool
  default = true
}

variable "boot_disk_type" {
  type    = string
  default = "network-hdd"
}
variable "boot_disk_size" {
  type    = number
  default = 30
}

variable "size" {
  type    = number
  default = 1
}

variable "autoscale_min" {
  type    = number
  default = 1
}

variable "autoscale_max" {
  type    = number
  default = 10
}

variable "autoscale_initial" {
  type    = number
  default = 1
}

variable "auto_upgrade" {
  type    = bool
  default = false
}

variable "auto_repair" {
  type    = string
  default = true
}

variable "labels" {
  type = map(string)
  default = {
  }
}

variable "node_labels" {
  type    = map(string)
  default = {}
}

variable "node_taints" {
  type    = list(string)
  default = []
}

variable "maintenance_window" {
  type = list(object(
    {
      day        = string
      start_time = string
      duration   = string
    }
  ))
  default = []
}

variable "max_expansion" {
  type    = number
  default = 3
}

variable "max_unavailable" {
  type    = number
  default = 0
}

variable "allowed_unsafe_sysctls" {
  type    = list(string)
  default = []
}

variable "container_runtime" {
  type    = string
  default = "docker"
  validation {
    condition     = contains(["docker", "containerd"], var.container_runtime)
    error_message = "The container_runtime value must be one of: docker, containerd."
  }
}

variable "network_acceleration_type" {
  type    = string
  default = "standard"
  validation {
    condition     = contains(["standard", "software_accelerated"], var.network_acceleration_type)
    error_message = "The container_runtime value must be one of: standard, software_accelerated."
  }
}
