terraform {
  required_version = ">= 1.0.11"
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">= 0.71.0"
    }
  }
}

provider "yandex" {
  zone = "ru-central1-a"
}

provider "helm" {
  kubernetes {
    host                   = module.k8s-cluster.cluster-info.external_v4_endpoint
    cluster_ca_certificate = module.k8s-cluster.cluster-info.cluster_ca_certificate
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "yc"
      args = [
        "k8s",
        "create-token"
      ]
    }
  }
}

provider "kubernetes" {
  host                   = module.k8s-cluster.cluster-info.external_v4_endpoint
  cluster_ca_certificate = module.k8s-cluster.cluster-info.cluster_ca_certificate
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "yc"
    args = [
      "k8s",
      "create-token"
    ]
  }
}
