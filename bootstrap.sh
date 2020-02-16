#!/bin/bash

# Create the mom clusters
kind create cluster --name=gitops-demo --wait 1m

# Install Helm/Tiller
#TODO: change to use helm v3
kubectl -n kube-system create sa tiller

kubectl create clusterrolebinding tiller-cluster-rule \
    --clusterrole=cluster-admin \
    --serviceaccount=kube-system:tiller

helm init --wait --skip-refresh --upgrade --service-account tiller --history-max 10

# Install Flux
kubectl create ns fluxcd
kubectl create secret generic flux-git-deploy --from-file=identity=$(pwd)/ssh/id_rsa
helm repo add fluxcd https://charts.fluxcd.io

helm upgrade -i flux fluxcd/flux --wait \
--namespace fluxcd \
--set git.url=git@github.com:richardcase/gitops-app-infra-demo.git \
--set git.path="deploy/infra\,deploy/apps" \
--set git.timeout=120s \
--set git.pollInterval=30s \
--set rbac.create=true \
--set git.secretName=flux-git-deploy