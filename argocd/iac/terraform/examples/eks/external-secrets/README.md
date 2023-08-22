# ArgoCD on Amazon EKS

This example shows how to deploy Amazon EKS with addons configured via ArgoCD

The example demonstrate how to use private git repository for workload apps.

The example stores your ssh key in AWS Secret Manager, and External Secret Operator to create the secret
for ArgoCD to access the git repositories.

## Prerequisites
- Create a Github ssh key file, example assumes the file path `~/.ssh/id_rsa`, update `main.tf` if using a different location

Deploy EKS Cluster
```shell
terraform init
terraform apply
```

Access Terraform output to configure `kubectl` and `argocd`
```shell
terraform output
```

There is a file `github.yaml` located in the addons git repository `clusters/ex-external-secrets/secret/` this file creates the resources `ClusterSecretStore` and `ExternalSecret`. Update the git `url` this file when you change the git repository for the workloads specified in `bootstrap/workloads.yaml`

To verify that the ArgoCD secret with ssh key is created run the following command
```shell
kubectl get secret private-repo-creds -n argocd
```
Expected output, should have 3 data items in secret
```
NAME                 TYPE     DATA   AGE
private-repo-creds   Opaque   3      6m45s
```

Destroy EKS Cluster
```shell
cd hub
./destroy.sh
```
