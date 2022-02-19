locals {
  kubeconf = templatefile("${path.root}/templates/.kubeconfig.tpl", {
    cluster_ca_certificate = base64encode(module.k8s-cluster.cluster-info.cluster_ca_certificate),
    external_v4_endpoint   = module.k8s-cluster.cluster-info.external_v4_endpoint,
    cluster_name           = module.k8s-cluster.cluster-info.cluster_name,
    }
  )
}

resource "local_file" "kubeconfig" {
  file_permission   = "0644"
  filename          = "${path.root}/.kubeconfig"
  sensitive_content = local.kubeconf
}

variable "argocd_password" {
}

locals {
  argocd_repo_ssh_key = file("~/.ssh/id_rsa")
  argocd_values = {
    server = {
      extraArgs = ["--insecure"]
      additionalApplications = [
        {
          name      = "cluster-bootstrap"
          namespace = "argocd-system"
          project   = "default"
          source = {
            repoURL        = "git@github.com:fl64/tf-yc.git"
            targetRevision = "HEAD"
            path           = "argo/bootstrap"
            directory = {
              recurse = true
            }
          }
          destination = {
            server    = "https://kubernetes.default.svc"
            namespace = "default"
          }
          syncPolicy = {
            automated = {
              selfHeal   = true
              allowEmpty = true
              prune      = true
            }
          }

        }
      ]
    }
    configs = {
      repositories = {
        "tf-yc" = {
          url  = "git@github.com:fl64/tf-yc.git"
          name = "tf-yc"
        }
      }
      credentialTemplates = {
        "github" = {
          url           = "git@github.com:fl64"
          sshPrivateKey = local.argocd_repo_ssh_key
        }
      }
      secret = {
        argocdServerAdminPassword      = var.argocd_password
        argocdServerAdminPasswordMtime = "2010-01-01T10:00:00Z"
      }
    }
  }
}

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  create_namespace = true
  namespace        = "argocd-system"
  version          = "3.33.6"
  max_history      = 1
  wait             = true
  values           = [yamlencode(local.argocd_values)]
  depends_on = [
    module.k8s-cluster,
    module.k8s-nodes,
    yandex_vpc_security_group.nodes,
    yandex_vpc_security_group.masters,
  ]
}

resource "helm_release" "argocd-applicationset" {
  name       = "argocd-applicationset"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-applicationset"
  #create_namespace = true
  namespace   = "argocd-system"
  version     = "1.9.1"
  max_history = 1
  wait        = true
  depends_on = [
    helm_release.argocd
  ]
}

locals {
  ingress_values = {
    fullnameOverride = "ingress-nginx"
  }
}

resource "helm_release" "ingress-nginx" {
  name             = "ingress"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = "4.0.17"
  namespace        = "ingress-nginx-system"
  create_namespace = true
  values           = [yamlencode(local.ingress_values)]
  depends_on = [
    module.k8s-cluster,
    module.k8s-nodes,
    yandex_vpc_security_group.nodes,
    yandex_vpc_security_group.masters,
  ]
}

data "kubernetes_service" "ingress-nginx" {
  metadata {
    name      = format("%s-controller", local.ingress_values.fullnameOverride)
    namespace = helm_release.ingress-nginx.namespace
  }
  depends_on = [
    helm_release.ingress-nginx
  ]
}

output "ingress" {
  value = data.kubernetes_service.ingress-nginx.status[0].load_balancer[0].ingress[0].ip
}

resource "yandex_dns_recordset" "ingress" {
  count   = var.dns_zone_id == "none" ? 0 : 1
  zone_id = data.yandex_dns_zone.zone.id
  name    = "*.k8s"
  type    = "A"
  ttl     = var.dns_record_ttl
  data    = [data.kubernetes_service.ingress-nginx.status[0].load_balancer[0].ingress[0].ip]
  depends_on = [
    data.kubernetes_service.ingress-nginx
  ]
}
