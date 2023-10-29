# ArgoCD with ingress domain name

Example on how to deploy Amazon EKS with addons configured via ArgoCD.
In this example the ArgoCD is configured with ingress using a https domain name managed on Route53


## Prerequisites
Before you begin, make sure you have the following command line tools installed:
- git
- terraform
- kubectl
- argocd

## Fork the Git Repositories

### Fork the Addon GitOps Repo
1. Fork the git repository for addons [here](https://github.com/gitops-bridge-dev/gitops-bridge-argocd-control-plane-template).
2. Update the following environment variables to point to your fork by changing the default values:
```shell
export TF_VAR_gitops_addons_org=https://github.com/gitops-bridge-dev
export TF_VAR_gitops_addons_repo=gitops-bridge-argocd-control-plane-template
```


**Create DNS Hosted Zone in Route 53:**

In this step you will delegate your registered domain DNS to Amazon Route53. You can either delegate the top level domain or a subdomain.
```shell
export TF_VAR_domain_name=<my-registered-domain> # For example: example.com or subdomain.example.com
```

You can use the Console, or the `aws` cli to create a hosted zone. Execute the following command only once:
```sh
aws route53 create-hosted-zone --name $TF_VAR_domain_name --caller-reference "$(date)"
```
Use the NameServers in the DelegatoinSet to update your registered domain NS records at the registrar.


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

## Access ArgoCD
Access ArgoCD's UI, run the command from the output:
```shell
terraform output -raw access_argocd
```


Destroy EKS Cluster
```shell
./destroy.sh
```
