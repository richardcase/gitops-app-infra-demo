# GitOps App And Infra Demo

1. Install kind
2. Create a cluster

```bash
kind create cluster --name=gitops-demo
```

3. Install helm & tiller

```bash
kubectl -n kube-system create sa tiller

kubectl create clusterrolebinding tiller-cluster-rule \
    --clusterrole=cluster-admin \
    --serviceaccount=kube-system:tiller

helm init --wait --skip-refresh --upgrade --service-account tiller --history-max 10

```

3. Install flux:

```bash
kubectl create ns fluxcd
helm repo add fluxcd https://charts.fluxcd.io

helm upgrade -i flux fluxcd/flux --wait \
--namespace fluxcd \
--set git.url=https://github.com/richardcase/gitops-app-infra-demo.git \
--set git.path="deploy/infra\,deploy/apps" \
--set git.timeout=120s \
--set git.pollInterval=30s \
--set rbac.create=true
```

4. Copy `samples/podinfo.yaml` to `deploy/apps` and push change