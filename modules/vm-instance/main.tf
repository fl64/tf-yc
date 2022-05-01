data "yandex_compute_image" "image" {
  family = var.image
}

data "template_file" "cloud-config" {
  template = file("${path.module}/bootstrap/cloud_config.tpl")
  vars = {
    user       = var.user
    ssh-key    = file(var.pub_key_path)
    if_hdd     = length(yandex_compute_disk.secondary-disk)
    mountpoint = var.mountpoint
  }
}

resource "yandex_compute_disk" "secondary-disk" {
  count = var.mountpoint == "" ? 0 : var.vm_count
  name  = format("%s-disk-%d", var.instance_name, count.index)
  type  = "network-hdd"
  size  = var.secondary_disk_size
  //zone = "ru-central1-a"
  labels = var.labels
  lifecycle {
    ignore_changes = all
  }
}

resource "yandex_compute_instance" "vm" {
  count = var.vm_count
  name  = format("%s-%d", var.instance_name, count.index)
  // if hosntame empty, use instance_name https://www.terraform.io/docs/configuration/functions/coalesce.html
  hostname                  = format("%s-%d", var.instance_name, count.index)
  description               = var.description
  allow_stopping_for_update = var.allow_stopping_for_update
  zone                      = var.zone
  labels                    = var.labels
  resources {
    cores         = var.cpu_count
    memory        = var.ram
    core_fraction = var.cpu_usage
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.image.id
      size     = var.disk_size
    }
  }

  secondary_disk {
    disk_id = var.mountpoint == "" ? null : yandex_compute_disk.secondary-disk.*.id[count.index]
  }

  dynamic "network_interface" {
    for_each = var.network_interfaces
    content {
      subnet_id          = network_interface.value["subnet_id"]
      nat                = lookup(network_interface.value, "nat", false)               // optional
      nat_ip_address     = lookup(network_interface.value, "nat_ip_address", null)     // optional
      security_group_ids = lookup(network_interface.value, "security_group_ids", null) // optional
      ip_address         = lookup(network_interface.value, "ip_address", null)         // optional
    }
  }

  scheduling_policy {
    preemptible = var.preemptible
  }

  metadata = {
    #ssh-keys  = "ubuntu:${file(var.pub_key_path)}"
    user-data = data.template_file.cloud-config.rendered #"${var.cloudconfig != "" ? file(var.cloudconfig) : file("${path.module}/bootstrap/metadata.yml")}"
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = self.network_interface.0.nat_ip_address
      user        = var.user
      private_key = file(var.priv_key_path)
    }
    inline = ["sudo apt update", "sudo apt install python3 -y", "echo Done!"]
  }
}
