variable "folder_id" {
  type = string
}

variable "yandex_region" {
  type    = string
  default = "ru-central1"
}

variable "vpc_network_id" {
  type = string
}

variable "subnets_ids" {
  type    = list(string)
  default = []
}

variable "security_group_ids" {
  type    = list(string)
  default = []
}

variable "public_ip" {
  type    = bool
  default = true
}

variable "cluster_name" {
  type    = string
  default = "k8s-cluster"
}

variable "cluster_description" {
  type    = string
  default = "k8s-cluster"
}

variable "k8s_version" {
  type    = string
  default = "1.21"
}

variable "labels" {
  type    = map(string)
  default = {}
}

variable "cluster_ipv4_range" {
  type    = string
  default = "10.22.0.0/16"
}

variable "service_ipv4_range" {
  type    = string
  default = "10.23.0.0/16"
}

variable "release_channel" {
  type    = string
  default = "RAPID"
}

variable "cluster_sa_name" {
  type    = string
  default = ""
}

variable "node_sa_name" {
  type    = string
  default = ""
}

variable "auto_upgrade" {
  type    = bool
  default = false
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

variable "network_implementation" {
  type    = string
  default = "cilium"
  validation {
    condition     = contains(["cilium", ""], var.network_implementation)
    error_message = "The network_implementation value must be one of: cilium or empty."
  }
}

variable "network_policy_provider" {
  type    = string
  default = ""
  validation {
    condition     = contains(["CALICO", ""], var.network_policy_provider)
    error_message = "The network_policy_provider value must be one of: CALICO or empty."
  }
}
