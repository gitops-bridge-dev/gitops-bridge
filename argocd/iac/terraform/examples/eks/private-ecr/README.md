# ArgoCD on Amazon EKS

This example shows how to deploy Amazon EKS with addons configured via ArgoCD

The example demonstrate how to use private ECR repository for addons and workload.

The Example using terraform ECR data resource to register ECR with the initial username password to argo cd as a repository and then using external secrets to refresh the ECR token.

On the appset-manifest-example folder there are examples of how to use external secrets and how you can configure an appset to use private ECR repo.


## Prerequisites
Before you begin, make sure you have the following command line tools installed:
- aws cli
- git
- terraform
- kubectl
- argocd

## Helm Login into ECR
Helm login into ECR registry
```bash
aws ecr get-login-password | helm registry login --username AWS --password-stdin <aws_account_id>.dkr.ecr.<region>.amazonaws.com
```

## Configure ECR for ArgoCD
Create a new ECR repository for the ArgoCD helm charts
```bash
aws ecr create-repository --repository-name argo-cd
```

Push the ArgoCD helm chart to the ECR repository
```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm pull argo/argo-cd --version 7.3.4 -d $TMPDIR
helm push $TMPDIR/argo-cd-7.3.4.tgz oci://<aws_account_id>.dkr.ecr.<region>.amazonaws.com
```

## Configure ECR for External Secrets
Create a new ECR repository for the ArgoCD helm charts
```bash
aws ecr create-repository --repository-name external-secrets
```

Push the ArgoCD helm chart to the ECR repository
```bash
helm repo add external-secrets-operator https://charts.external-secrets.io
helm repo update
helm pull external-secrets-operator/external-secrets --version 0.9.19 -d $TMPDIR
helm push $TMPDIR/external-secrets-0.9.19.tgz oci://<aws_account_id>.dkr.ecr.<region>.amazonaws.com
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

### Deploy ArgoCD from ArgoCD
Deploy ArgoCD using ApplicationSet from ECR
```bash
kubectl apply -f appset-manifest-example/addons-argo-cd-appset.yaml
```

### Deploy External Secret Operator (ESO) and Extra CRs from ECR
Deploy ESO using ApplicationSet from ECR
```bash
kubectl apply -f appset-manifest-example/addons-aws-oss-external-secrets-appset.yaml
```
Deploy `ExternalSecret` this will refresh the ECR token every 8h
```bash
kubectl apply -f appset-manifest-example/ecr-repo.yaml
```

### Monitor GitOps Progress for Addons
Wait until all the ArgoCD applications' `HEALTH STATUS` is `Healthy`. Use Crl+C to exit the `watch` command
```shell
watch kubectl get applications -n argocd
```

### Verify
Verify the `ECRAuthorizationToken`:
```bash
kubectl get -n argocd ECRAuthorizationToken argocd-secrets-ecr -o yaml
```
Expected example output:
```yaml
apiVersion: generators.external-secrets.io/v1alpha1
kind: ECRAuthorizationToken
metadata:
  name: argocd-secrets-ecr
  namespace: argocd
spec:
  auth:
    jwt:
      serviceAccountRef:
        name: argocd-server
  region: us-west-2
```
Verify the `ExternalSecret`:
```bash
kubectl get externalsecret.external-secrets.io/argocd-secrets-ecr-auth-token-external-secret
```
Expected example output:
```
NAME                                            STORE   REFRESH INTERVAL   STATUS         READY
argocd-secrets-ecr-auth-token-external-secret           8h                 SecretSynced   True
```
After 8h you can check for a new token in the ArgoCD secret for private ECR, you can modify how often to refresh the token
```bash
kubectl get secret -n argocd argocd-private-ecr-credentials  --template="{{index .data.password | base64decode}}" | base64 -d | jq .
```
Expected output:
```json
{
  "payload": "....",
  "datakey": "...",
  "version": "2",
  "type": "DATA_KEY",
  "expiration": 1720335544
}
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
