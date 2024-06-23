# ArgoCD on Amazon EKS

This example shows how to deploy Amazon EKS with addons configured via ArgoCD

The example demonstrate how to use private ECR repository for addons and workload.

The Example using terraform data resource to register ECR with the initiall username password and then we are using external secrets to refresh the ECR token.

## Prerequisites
- Have a private ECR repo in our case we have External secrets in the private ECR

Before you begin, make sure you have the following command line tools installed:
- git
- terraform
- kubectl
- argocd

### Fork the Addon GitOps Repo
1. Fork the git repository for addons [here](https://github.com/gitops-bridge-dev/gitops-bridge-argocd-control-plane-template).
2. Update the following environment variables to point to your fork by changing the default values:
```shell
export TF_VAR_gitops_addons_org=git@github.com:gitops-bridge-dev
export TF_VAR_gitops_addons_repo=gitops-bridge-argocd-control-plane-template
```

## Deploy the EKS Cluster
Initialize Terraform and deploy the EKS cluster:
```shell
terraform init
terraform apply -auto-approve
```
Retrieve `kubectl` config, then execute the output command:
```shell
terraform output -raw configure_kubectl
```


### Monitor GitOps Progress for Addons
Wait until all the ArgoCD applications' `HEALTH STATUS` is `Healthy`. Use Crl+C to exit the `watch` command
```shell
watch kubectl get applications -n argocd
```

### Verify the Addons
Verify that the addons are ready:
```shell
kubectl get deployment -n kube-system \
  aws-load-balancer-controller \
  metrics-server
```

## Access ArgoCD
Access ArgoCD's UI, run the command from the output:
```shell
terraform output -raw access_argocd
```


## Destroy the EKS Cluster
To tear down all the resources and the EKS cluster, run the following command:
```shell
./destroy.sh
```
