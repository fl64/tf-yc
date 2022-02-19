yc:
	curl https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash
	source "/home/user/.zshrc"

init:
	terraform init -upgrade=true -force

plan:
	terraform plan -out tf.plan

apply:
	terraform apply tf.plan

argo:
	KUBECONF=.kubeconfig nohup kubectl port-forward service/argocd-server -n argocd-system 8080:80 > /dev/null 2>&1 &
	sleep 5
	xdg-open http://localhost:8080

check:
	curl https://test.k8s.fl64.net
