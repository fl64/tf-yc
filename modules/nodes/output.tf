output "nodes-info" {
  sensitive = true
  value = {
    name = yandex_kubernetes_node_group.k8s_nodes.name
    id   = yandex_kubernetes_node_group.k8s_nodes.id
  }
}
