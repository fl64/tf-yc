output "cluster-info" {
  sensitive = true
  value = {
    cluster_id             = yandex_kubernetes_cluster.k8s_cluster.id
    cluster_name           = yandex_kubernetes_cluster.k8s_cluster.name
    cluster_ca_certificate = yandex_kubernetes_cluster.k8s_cluster.master[0].cluster_ca_certificate
    internal_v4_endpoint   = yandex_kubernetes_cluster.k8s_cluster.master[0].internal_v4_endpoint
    external_v4_endpoint   = yandex_kubernetes_cluster.k8s_cluster.master[0].external_v4_endpoint
    internal_v4_address    = yandex_kubernetes_cluster.k8s_cluster.master[0].internal_v4_address
    external_v4_address    = yandex_kubernetes_cluster.k8s_cluster.master[0].external_v4_address
  }
}
