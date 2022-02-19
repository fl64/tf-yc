yandex cloud lab
================

`terraform/vm`


`terraform/k8s` - manifest for creating and bootstrapping k8s cluster in yandex cloud.

Spec:
- zonal cluster with one node (2 cpu 4 ram)
- ingress controller `ingress-nginx`
- dns record for ingress `*.k8s.fl64.net`
- `argo-cd` for installing apps from `./argo/apps`
