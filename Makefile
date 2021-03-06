# ---------cluster
create-cluster:
	kind create cluster --name kube-playground --config kind-config.yaml

delete-cluster:
	kind delete cluster --name kube-playground

# ---------ingress
# nginx
create-ingress-nginx:
	kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
	kubectl wait --namespace ingress-nginx \
		--for=condition=ready pod \
		--selector=app.kubernetes.io/component=controller \
		--timeout=90s

delete-ingress-nginx:
	kubectl delete -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

# traefik
create-ingress-traefik:
	kubectl apply -f ingress.yaml

delete-ingress-traefik:
	kubectl delete -f ingress.yaml

# kong
create-ingress-kong:
	kubectl apply -f https://raw.githubusercontent.com/Kong/kubernetes-ingress-controller/master/deploy/single/all-in-one-dbless.yaml
	kubectl patch deployment -n kong ingress-kong -p '{"spec":{"template":{"spec":{"containers":[{"name":"proxy","ports":[{"containerPort":8000,"hostPort":80,"name":"proxy","protocol":"TCP"},{"containerPort":8443,"hostPort":43,"name":"proxy-ssl","protocol":"TCP"}]}],"nodeSelector":{"ingress-ready":"true"},"tolerations":[{"key":"node-role.kubernetes.io/control-plane","operator":"Equal","effect":"NoSchedule"},{"key":"node-role.kubernetes.io/master","operator":"Equal","effect":"NoSchedule"}]}}}}'
	# LoadBalancerは使えないのでNodePortに変更する
	kubectl patch service -n kong kong-proxy -p '{"spec":{"type":"NodePort"}}'
	# Kong Ingress Controllerで制御するためには、Ingressの仕様に ingressClassName: kong が含まれている必要ある
	kubectl patch ingress example-ingress -p '{"spec":{"ingressClassName":"kong"}}'

delete-ingress-kong:
	kubectl delete -f https://raw.githubusercontent.com/Kong/kubernetes-ingress-controller/master/deploy/single/all-in-one-dbless.yaml

# ---------テスト用のリソース作成
create-target:
	kubectl apply -f targets/

delete-target:
	kubectl delete -f targets/

test-request:
	curl -i localhost/foo
	curl -i localhost/bar

# ----------others
# 参考: https://docs.konghq.com/kubernetes-ingress-controller/latest/guides/using-kong-with-knative/
instll-knative:
	kubectl apply --filename https://github.com/knative/serving/releases/download/knative-v1.1.0/serving-crds.yaml
	kubectl apply --filename https://github.com/knative/serving/releases/download/knative-v1.1.0/serving-core.yaml

# tekton
# 参考: https://hashnode.com/post/tekton-ci-simplified-ckzleauyw0n6beks1diq6ejvv
install-tekton:
	kubectl apply --filename https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml
	kubectl apply --filename https://storage.googleapis.com/tekton-releases/dashboard/latest/tekton-dashboard-release.yaml
	brew install tektoncd-cli

run:
	kubectl apply ./tekton
	kubectl create -f pipelinerun.yaml
