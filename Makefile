FILE = test-mihaiblebea-platform.yaml

setup:
	export TF_VAR_do_token=2e2cdeb12c6544b693df35649d52c2278b4e31f0ab606b2b7649cdeef6535950 &&\
	export TF_VAR_kubeconfig_path=/Users/mihaiblebea/.kube/$(FILE) &&\
	terraform init &&\
	terraform plan &&\
	terraform apply -auto-approve

load-config:
	export KUBECONFIG=$$HOME/.kube/$(FILE)

destroy:
	terraform destroy -auto-approve