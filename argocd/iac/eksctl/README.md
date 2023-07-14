# EKSCLT ARGOCD BRIDGE

TODO: get the correct commands for eksctl and aws iam

Platform person:
```
eksctl create cluster --name my-cluster
aws iam create role cert-manager
aws iam create ploicy doc cert-manager-policy --policy p.json
aws iam attach policy cert-manager-policy --role cert-manager
cert_manager_iam_role_arn=$(aws iam describe role cert-manager --output json | jq .arn_role)
```


Email to DevOps:
>Cluster is region us-west-2
Cluster name my-cluster
CERT_MANAGER_ROLE_ARN = arn:aws:iam::12345:role/cert-manager-20230622045248041400000013

DevOps person:
```
# Input from platform team
cert_manager_iam_role_arn="arn:aws:iam::12345:role/cert-manager-20230622045248041400000013"
cluster_name="my-cluster"
region="us-west-2"
enable_argocd="true"

helm repo add argo https://argoproj.github.io/argo-helm
helm install argo-cd argo/argo-cd --version "5.36.4" --namespace argocd --create-namespace

aws eks --region ${region} update-kubeconfig --name ${cluster_name}
kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: in-cluster-local
  namespace: argocd
  annotations:
    cluster_name: ${cluster_name}
    region: ${region}
    cert_manager_iam_role_arn: ${cert_manager_iam_role_arn}
  labels:
    argocd.argoproj.io/secret-type: cluster
    enable_argocd: "${enable_argocd}"
type: Opaque
stringData:
  name: in-cluster-local
  server: https://kubernetes.default.svc
  config: |
    {
      "tlsClientConfig": {
        "insecure": false
      }
    }
EOF

# Bootstrap apps or apps
kubectl apply -f https://raw.githubusercontent.com/csantanapr/gitops-control-plane/main/bootstrap-app.yaml


