#!/bin/bash

set -x
aws eks --region ${region} update-kubeconfig --name ${cluster_name} --kubeconfig /tmp/${cluster_name}
export KUBECONFIG=/tmp/${cluster_name}

# TODO: check if repo already added
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
# TODO check if argocd already installed (ie check for the argocd namespace)
helm install argo-cd argo/argo-cd --version "5.36.7" --namespace argocd --create-namespace --wait

kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: in-cluster
  namespace: argocd
  annotations:
    cluster_name: "${cluster_name}"
    region: "${region}"
    cert_manager_iam_role_arn: "${cert_manager_iam_role_arn}"
    cert_manager_namespace: "${cert_manager_namespace}"
    cluster_autoscaler_iam_role_arn: "${cluster_autoscaler_iam_role_arn}"
    cluster_autoscaler_sa: "${cluster_autoscaler_sa}"
    cluster_autoscaler_image_tag: "${cluster_autoscaler_image_tag}"
    cluster_autoscaler_namespace: "${cluster_autoscaler_namespace}"
    aws_cloudwatch_metrics_iam_role_arn: "${aws_cloudwatch_metrics_iam_role_arn}"
    aws_cloudwatch_metrics_sa: "${aws_cloudwatch_metrics_sa}"
    aws_cloudwatch_namespace: "${aws_cloudwatch_namespace}"
  labels:
    argocd.argoproj.io/secret-type: cluster
    # This indicates this is a control-plane cluster (central management argocd) compatible with akuity in-cluster usage
    akuity.io/argo-cd-cluster-name: in-cluster
type: Opaque
stringData:
  name: in-cluster
  server: https://kubernetes.default.svc
  config: |
    {
      "tlsClientConfig": {
        "insecure": false
      }
    }
EOF

# bootstrap app (App or Apps)
# We are deploying both because the single cluster with argocd will be re-use to run workloads, if using akuity agent only workloads is need it
kubectl apply -f https://raw.githubusercontent.com/csantanapr/gitops-control-plane/main/bootstrap/control-plane/exclude/bootstrap.yaml
kubectl apply -f https://raw.githubusercontent.com/csantanapr/gitops-control-plane/main/bootstrap/workloads/exclude/bootstrap.yaml

kubectl config set-context --current --namespace argocd
export ARGOCD_OPTS="--port-forward --port-forward-namespace argocd --grpc-web"
argocd login --username admin --password $(kubectl get secrets argocd-initial-admin-secret -n argocd --template="{{index .data.password | base64decode}}")
