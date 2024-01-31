# Argo Workflows

Example on how to deploy Amazon EKS with addons configured via ArgoCD.
In this example we show how to deploy Argo Workflows

## Prerequisites
Before you begin, make sure you have the following command line tools installed:
- git
- terraform
- kubectl
- argocd (brew install argocd)
- argo (brew install argo)

## Fork the Git Repositories

### Fork the Addon GitOps Repo
1. Fork the git repository for addons [here](https://github.com/gitops-bridge-dev/gitops-bridge-argocd-control-plane-template).
2. Update the following environment variables to point to your fork by changing the default values:
```shell
export TF_VAR_gitops_addons_org=https://github.com/gitops-bridge-dev
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

## Use Argo Workflows
Make sure you have kubectl/KUBECONFIG setup by usind the output of `terraform output -raw configure_kubectl`
Run a workflow in the `default` namespace using the service account created by the argo-workflow helm chart addon
```shell
argo submit -n default --serviceaccount argo-workflow https://raw.githubusercontent.com/argoproj/argo-workflows/main/examples/hello-world.yaml
```
Check the status of the workflow
```shell
argo list
```
Expected output:
```
NAME                STATUS      AGE   DURATION   PRIORITY   MESSAGE
hello-world-zvczz   Succeeded   59s   10s        0
```
Get the output of the workflow
```shell
argo logs @latest
```
Expected output:
```
hello-world-zvczz:  _____________
hello-world-zvczz: < hello world >
hello-world-zvczz:  -------------
hello-world-zvczz:     \
hello-world-zvczz:      \
hello-world-zvczz:       \
hello-world-zvczz:                     ##        .
hello-world-zvczz:               ## ## ##       ==
hello-world-zvczz:            ## ## ## ##      ===
hello-world-zvczz:        /""""""""""""""""___/ ===
hello-world-zvczz:   ~~~ {~~ ~~~~ ~~~ ~~~~ ~~ ~ /  ===- ~~~
hello-world-zvczz:        \______ o          __/
hello-world-zvczz:         \    \        __/
hello-world-zvczz:           \____\______/
hello-world-zvczz: time="2024-01-23T20:32:24.174Z" level=info msg="sub-process exited" argo=true error="<nil>"
```
Use the Argo Workflow UI, use port-forward, and open url http://localhost:8080
```shell
kubectl port-forward -n argo-workflows svc/argo-workflows-server 8080:2746
```
Get authentication token using argo cli
```shell
argo auth token
```


## Access ArgoCD
Access ArgoCD's UI, run the command from the output:
```shell
terraform output -raw access_argocd
```

Destroy EKS Cluster
```shell
cd hub
./destroy.sh
```
