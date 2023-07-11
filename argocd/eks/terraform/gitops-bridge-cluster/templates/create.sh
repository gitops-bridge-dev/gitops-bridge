#!/bin/bash

set -x
set -u

argocd_version=${argocd_version:-5.38.0}
argocd_namespace=${argocd_namespace:-argocd}
argocd_bootstrap_control_plane=${argocd_bootstrap_cp:-https://raw.githubusercontent.com/csantanapr/gitops-control-plane/main/bootstrap/control-plane/exclude/bootstrap.yaml}
argocd_bootstrap_workloads=${argocd_bootstrap_cp:-https://raw.githubusercontent.com/csantanapr/gitops-control-plane/main/bootstrap/workloads/exclude/bootstrap.yaml}
argocd_helm_protocol=${argocd_helm_protocol:-https://}
argocd_helm_registry=${argocd_helm_registry:-argoproj.github.io}
argocd_helm_repository=${argocd_helm_protocol:-argo-helm}

aws eks --region ${aws_region} update-kubeconfig --name ${cluster_name} --kubeconfig /tmp/${cluster_name}
export KUBECONFIG=/tmp/${cluster_name}

helm repo list  | grep argo-helm || helm repo add argo "${argocd_helm_protocol}${argocd_helm_registry}/${argocd_helm_repository}"
helm repo update
if ! helm list -n "${argocd_namespace}" --filter="argo-cd" | grep argo-cd; then
  helm install argo-cd argo/argo-cd --version "${argocd_version}" --namespace "${argocd_namespace}" --create-namespace --wait
fi


kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: "${cluster_name}"
  namespace: "${argocd_namespace}"
  annotations:
    cluster_name: "${cluster_name}"

  labels:
    argocd.argoproj.io/secret-type: cluster
    environment: "${environment}" # control-plane, dev, qa, staging, prod


type: Opaque
stringData:
  name: "${cluster_name}"
  server: https://kubernetes.default.svc
  config: |
    {
      "tlsClientConfig": {
        "insecure": false
      }
    }
EOF

# iterate over all environments variables that start with enable_
# then create secret name in-cluster with all the variables as labels
for var in $(env | grep ^enable_); do
    kubectl label secret "${cluster_name}" -n "${argocd_namespace}" ${var} --overwrite=true
done
for var in $(env | grep ^aws_enable_); do
    kubectl label secret "${cluster_name}" -n "${argocd_namespace}" ${var} --overwrite=true
done
for var in $(env | grep ^aws_  | grep -v ^aws_enable); do
    kubectl annotate secret "${cluster_name}" -n "${argocd_namespace}" ${var} --overwrite=true
done

# bootstrap app (App or Apps)
# TODO override the bootstrap app with the one provided by the user
kubectl apply -n "${argocd_namespace}" -f "${argocd_bootstrap_control_plane}"
kubectl apply -n "${argocd_namespace}" -f "${argocd_bootstrap_workloads}"

kubectl config set-context --current --namespace "${argocd_namespace}"
export ARGOCD_OPTS="--port-forward --port-forward-namespace ${argocd_namespace} --grpc-web"
argocd login --username admin --password $(kubectl get secrets argocd-initial-admin-secret -n "${argocd_namespace}" --template="{{index .data.password | base64decode}}")
argocd repo add public.ecr.aws --type helm --name aws-public-ecr --enable-oci
echo "{\"output\": \"done create.sh\"}"
