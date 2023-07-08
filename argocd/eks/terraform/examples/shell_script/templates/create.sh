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
    cert_manager_service_account: "${cert_manager_service_account}"

    cluster_autoscaler_iam_role_arn: "${cluster_autoscaler_iam_role_arn}"
    cluster_autoscaler_namespace: "${cluster_autoscaler_namespace}"
    cluster_autoscaler_service_account: "${cluster_autoscaler_service_account}"
    cluster_autoscaler_image_tag: "${cluster_autoscaler_image_tag}"

    aws_cloudwatch_metrics_iam_role_arn: "${aws_cloudwatch_metrics_iam_role_arn}"
    aws_cloudwatch_namespace: "${aws_cloudwatch_namespace}"
    aws_cloudwatch_metrics_service_account: "${aws_cloudwatch_metrics_service_account}"

    aws_efs_csi_driver_iam_role_arn: "${aws_efs_csi_driver_iam_role_arn}"
    aws_efs_csi_driver_namespace: "${aws_efs_csi_driver_namespace}"
    aws_efs_csi_driver_controller_service_account: "${aws_efs_csi_driver_controller_service_account}"
    aws_efs_csi_driver_node_service_account: "${aws_efs_csi_driver_node_service_account}"

    aws_fsx_csi_driver_iam_role_arn: "${aws_fsx_csi_driver_iam_role_arn}"
    aws_fsx_csi_driver_namespace: "${aws_fsx_csi_driver_namespace}"
    aws_fsx_csi_driver_controller_service_account: "${aws_fsx_csi_driver_controller_service_account}"
    aws_fsx_csi_driver_node_service_account: "${aws_fsx_csi_driver_node_service_account}"

    aws_privateca_issuer_iam_role_arn: "${aws_privateca_issuer_iam_role_arn}"
    aws_privateca_issuer_namespace: "${aws_privateca_issuer_namespace}"
    aws_privateca_issuer_service_account: "${aws_privateca_issuer_service_account}"

    external_dns_iam_role_arn: "${external_dns_iam_role_arn}"
    external_dns_namespace: "${external_dns_namespace}"
    external_dns_service_account: "${external_dns_service_account}"

    external_secrets_iam_role_arn: "${external_secrets_iam_role_arn}"
    external_secrets_namespace: "${external_secrets_namespace}"
    external_secrets_service_account: "${external_secrets_service_account}"

    aws_load_balancer_controller_iam_role_arn: "${aws_load_balancer_controller_iam_role_arn}"
    aws_load_balancer_controller_namespace: "${aws_load_balancer_controller_namespace}"
    aws_load_balancer_controller_service_account: "${aws_load_balancer_controller_service_account}"

    aws_for_fluentbit_iam_role_arn: "${aws_for_fluentbit_iam_role_arn}"
    aws_for_fluentbit_namespace: "${aws_for_fluentbit_namespace}"
    aws_for_fluentbit_service_account: "${aws_for_fluentbit_service_account}"
    aws_for_fluentbit_log_group_name: "${aws_for_fluentbit_log_group_name}"

    aws_node_termination_handler_iam_role_arn: "${aws_node_termination_handler_iam_role_arn}"
    aws_node_termination_handler_namespace: "${aws_node_termination_handler_namespace}"
    aws_node_termination_handler_service_account: "${aws_node_termination_handler_service_account}"
    aws_node_termination_handler_sqs_queue_url: "${aws_node_termination_handler_sqs_queue_url}"

    aws_karpenter_iam_role_arn: "${aws_karpenter_iam_role_arn}"
    aws_karpenter_namespace: "${aws_karpenter_namespace}"
    aws_karpenter_service_account: "${aws_karpenter_service_account}"
    aws_karpenter_sqs_queue_name: "${aws_karpenter_sqs_queue_name}"
    aws_karpenter_cluster_endpoint: "${aws_karpenter_cluster_endpoint}"
    aws_karpenter_node_instance_profile_name: "${aws_karpenter_node_instance_profile_name}"


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
