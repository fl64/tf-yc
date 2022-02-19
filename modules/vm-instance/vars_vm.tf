variable "instance_name" {
  description = "Instance name"
}

variable "zone" {
  description = "The availability zone where the virtual machine will be created"
  default     = null
}

variable "platform_id" {
  description = "The type of virtual machine to create"
  default     = "standard-v1"
}

variable "description" {
  description = "VM description"
  default     = ""
}

variable "cpu_count" {
  description = "CPU count"
  default     = 2
}

variable "cpu_usage" {
  description = "CPU % usage"
  default     = 5
}

variable "ram" {
  description = "Amount of RAM"
  default     = 2
}

#ubuntu 20.04 lts >> yc compute image list --folder-id
variable "image" {
  description = "Image name"
  default     = "ubuntu-1804-lts"
}

variable "disk_size" {
  description = "Boot disk size"
  default     = 10
}

variable "network_interfaces" {
  description = "List of network interfaces"
}

variable "secondary_disks" {
  description = "List of secondary attaced disks"
  default     = []
}

variable "preemptible" {
  description = "scheduling_policy preemptible"
  default     = false
}

variable "pub_key_path" {
  description = "ssh public key path"
  default     = "~/.ssh/id_rsa.pub"
}

variable "priv_key_path" {
  description = "ssh private key path"
  default     = "~/.ssh/id_rsa"
}

variable "allow_stopping_for_update" {
  description = "If true, allows Terraform to stop the instance in order to update its properties."
  default     = false
}

variable "labels" {
  description = "Labels for VM instance"
  type        = map(any)
  default     = null
}

variable "mountpoint" {
  description = "Mountpoint for secondary disk"
  default     = ""
}

variable "secondary_disk_size" {
  description = "Secondary disk size (Gb)"
  default     = 10
}

variable "user" {
  description = "Created user"
  default     = "yc-bot"
}

variable "vm_count" {
  description = "VM count"
  default     = 1
}

variable "dns_zone_id" {
  description = "DNS zone id"
  default     = "none"
}

variable "dns_record_ttl" {
  description = "DNS record TTL"
  default     = 60
}
