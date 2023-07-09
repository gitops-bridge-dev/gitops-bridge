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

    aws_cert_manager_iam_role_arn: "${aws_cert_manager_iam_role_arn}"
    aws_cert_manager_namespace: "${aws_cert_manager_namespace}"
    aws_cert_manager_service_account: "${aws_cert_manager_service_account}"

    aws_cluster_autoscaler_iam_role_arn: "${aws_cluster_autoscaler_iam_role_arn}"
    aws_cluster_autoscaler_namespace: "${aws_cluster_autoscaler_namespace}"
    aws_cluster_autoscaler_service_account: "${aws_cluster_autoscaler_service_account}"
    aws_cluster_autoscaler_image_tag: "${aws_cluster_autoscaler_image_tag}"

    aws_cloudwatch_metrics_iam_role_arn: "${aws_cloudwatch_metrics_iam_role_arn}"
    aws_cloudwatch_metrics_namespace: "${aws_cloudwatch_metrics_namespace}"
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

    aws_external_dns_iam_role_arn: "${aws_external_dns_iam_role_arn}"
    aws_external_dns_namespace: "${aws_external_dns_namespace}"
    aws_external_dns_service_account: "${aws_external_dns_service_account}"

    aws_external_secrets_iam_role_arn: "${aws_external_secrets_iam_role_arn}"
    aws_external_secrets_namespace: "${aws_external_secrets_namespace}"
    aws_external_secrets_service_account: "${aws_external_secrets_service_account}"

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

    aws_velero_iam_role_arn: "${aws_velero_iam_role_arn}"
    aws_velero_namespace: "${aws_velero_namespace}"
    aws_velero_service_account: "${aws_velero_service_account}"
    aws_velero_backup_s3_bucket_prefix: "${aws_velero_backup_s3_bucket_prefix}"
    aws_velero_backup_s3_bucket_name: "${aws_velero_backup_s3_bucket_name}"

  labels:
    argocd.argoproj.io/secret-type: cluster
    environment: "${environment}" # control-plane, dev, qa, staging, prod
    aws_enable_aws_efs_csi_driver: "${aws_enable_aws_efs_csi_driver}"
    aws_enable_aws_fsx_csi_driver: "${aws_enable_aws_fsx_csi_driver}"
    aws_enable_aws_cloudwatch_metrics: "${aws_enable_aws_cloudwatch_metrics}"
    aws_enable_aws_privateca_issuer: "${aws_enable_aws_privateca_issuer}"
    aws_enable_cert_manager: "${aws_enable_cert_manager}"
    aws_enable_cluster_autoscaler: "${aws_enable_cluster_autoscaler}"
    aws_enable_external_dns: "${aws_enable_external_dns}"
    aws_enable_external_secrets: "${aws_enable_external_secrets}"
    aws_enable_aws_load_balancer_controller: "${aws_enable_aws_load_balancer_controller}"
    aws_enable_aws_for_fluentbit: "${aws_enable_aws_for_fluentbit}"
    aws_enable_aws_node_termination_handler: "${aws_enable_aws_node_termination_handler}"
    aws_enable_karpenter: "${aws_enable_karpenter}"
    aws_enable_velero: "${aws_enable_velero}"




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

# iterate over all environments variables that start with enable_
# then create secret name in-cluster with all the variables as labels in the single kubernetes secret
# for example:
# enable_argocd=true
# enable_argo_rollouts=true
# using env
for var in $(env | grep ^enable_); do
    kubectl label secret in-cluster -n argocd ${var} --overwrite=true
done










# bootstrap app (App or Apps)
# TODO override the bootstrap app with the one provided by the user
kubectl apply -f https://raw.githubusercontent.com/csantanapr/gitops-control-plane/main/bootstrap/control-plane/exclude/bootstrap.yaml
kubectl apply -f https://raw.githubusercontent.com/csantanapr/gitops-control-plane/main/bootstrap/workloads/exclude/bootstrap.yaml

kubectl config set-context --current --namespace argocd
export ARGOCD_OPTS="--port-forward --port-forward-namespace argocd --grpc-web"
argocd login --username admin --password $(kubectl get secrets argocd-initial-admin-secret -n argocd --template="{{index .data.password | base64decode}}")
argocd repo add public.ecr.aws --type helm --name aws-public-ecr --enable-oci
