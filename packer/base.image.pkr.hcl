variable "img_ver" {
  type = string
}

variable "subnet_id" {
  type = string
}

source "yandex" "ubuntu-2004-lts" {
  disk_type           = "network-ssd"
  image_description   = "my custom debian with nginx"
  image_name          = "ubuntu-20040-lts-${var.img_ver}"
  # yc compute image list --folder-id standard-images
  image_family        = "ubuntu-2004-lts"
  source_image_family = "ubuntu-2004-lts"
  ssh_username        = "ubuntu"
  subnet_id           = var.subnet_id
  use_ipv4_nat        = true
}

build {
  sources = ["source.yandex.ubuntu-2004-lts"]

  provisioner "shell" {
    inline = [
      "echo 'updating APT'",
      "sudo apt-get update -y",
      "sudo apt-get install -y nginx",
      "sudo su -",
      "sudo systemctl enable nginx.service",
      "curl localhost"
    ]
  }

}
