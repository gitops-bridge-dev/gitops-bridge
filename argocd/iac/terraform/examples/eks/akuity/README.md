# Example of EKS with Akuity

## Prerequisites
Before you begin, make sure you have the following command line tools installed:
- git
- terraform
- kubectl
- argocd

Get a free account on akuity.com, and create an API Key with org access
```shell
export AKUITY_API_KEY_ID=xxxxxxxxxxxxx
export AKUITY_API_KEY_SECRET=xxxxxxxxxxxxxxxxxxxxxxxxxx
export AKUITY_SERVER_URL=https://akuity.cloud
export TF_VAR_akp_org_name="your org name"
```

Set the password you wan to access argocd
```shell
export TF_VAR_argocd_admin_password=xxxxxxxxxxx
```


## Fork the Git Repositories

### Fork the Addon GitOps Repo
1. Fork the git repository for addons [here](https://github.com/gitops-bridge-dev/gitops-bridge).
2. Update the following environment variables to point to your fork by changing the default values:
```shell
export TF_VAR_gitops_addons_org=https://github.com/<org or user>
export TF_VAR_gitops_workload_org=https://github.com/<org or user>
```

## Deploy the Kubernetes Cluster
Initialize Terraform and deploy the EKS cluster:
```shell
terraform init
terraform apply -target="module.vpc" -auto-approve
terraform apply -target="module.eks" -auto-approve
terraform apply -target="module.akuity" -auto-approve
```
Retrieve `kubectl` config, then execute the output command:
```shell
terraform output -raw configure_kubectl
```

Terraform added GitOps Bridge Metadata to ArgoCD Cluster in Akuity.
The annotations contain metadata for the addons' Helm charts and ArgoCD ApplicationSets.
In the EKS cluster there is a secret with a projection of the annotations
```shell
kubectl get secret -n akuity cplane -o json | jq '.metadata.annotations' | grep -v "kubectl.kubernetes.io/last-applied-configuration"
```
The output looks like the following:
```json
{
  "addons_repo_basepath": "gitops/",
  "addons_repo_path": "bootstrap/control-plane/addons",
  "addons_repo_revision": "main",
  "addons_repo_url": "git@github.com:gitops-bridge/gitops-bridge",
  "workload_repo_basepath": "gitops/",
  "workload_repo_path": "apps",
  "workload_repo_revision": "main",
  "workload_repo_url": "git@github.com:gitops-bridge/gitops-bridge"
  "aws_account_id": "0123456789",
  "aws_cloudwatch_metrics_iam_role_arn": "arn:aws:iam::0123456789:role/aws-cloudwatch-metrics-20231029150636632700000028",
  "aws_cloudwatch_metrics_namespace": "amazon-cloudwatch",
  "aws_cloudwatch_metrics_service_account": "aws-cloudwatch-metrics",
  "aws_cluster_name": "ex-eks-akuity",
  "aws_for_fluentbit_iam_role_arn": "arn:aws:iam::0123456789:role/aws-for-fluent-bit-20231029150636632700000029",
  "aws_for_fluentbit_log_group_name": "/aws/eks/ex-eks-akuity/aws-fluentbit-logs-20231029150605912500000017",
  "aws_for_fluentbit_namespace": "kube-system",
  "aws_for_fluentbit_service_account": "aws-for-fluent-bit-sa",
  "aws_load_balancer_controller_iam_role_arn": "arn:aws:iam::0123456789:role/alb-controller-20231029150636630700000025",
  "aws_load_balancer_controller_namespace": "kube-system",
  "aws_load_balancer_controller_service_account": "aws-load-balancer-controller-sa",
  "aws_region": "us-west-2",
  "aws_vpc_id": "vpc-0d1e6da491803e111",
  "cert_manager_iam_role_arn": "arn:aws:iam::0123456789:role/cert-manager-20231029150636632300000026",
  "cert_manager_namespace": "cert-manager",
  "cert_manager_service_account": "cert-manager",
  "cluster_name": "in-cluster",
  "environment": "dev",
  "external_dns_namespace": "external-dns",
  "external_dns_service_account": "external-dns-sa",
  "external_secrets_iam_role_arn": "arn:aws:iam::0123456789:role/external-secrets-20231029150636632600000027",
  "external_secrets_namespace": "external-secrets",
  "external_secrets_service_account": "external-secrets-sa",
  "karpenter_iam_role_arn": "arn:aws:iam::0123456789:role/karpenter-20231029150636630500000024",
  "karpenter_namespace": "karpenter",
  "karpenter_node_instance_profile_name": "karpenter-ex-eks-akuity-2023102915060627290000001a",
  "karpenter_service_account": "karpenter",
  "karpenter_sqs_queue_name": "karpenter-ex-eks-akuity",
}
```
The labels offer a straightforward way to enable or disable an addon in ArgoCD for the cluster.
```shell
kubectl get secret -n argocd -l argocd.argoproj.io/secret-type=cluster -o json | jq '.items[0].metadata.labels'
kubectl get secret -n akuity cplane -o json | jq '.metadata.labels'
```
The output looks like the following:
```json
{
  "argocd.argoproj.io/secret-type": "cluster",
  "aws_cluster_name": "ex-eks-akuity",
  "cluster_name": "in-cluster",
  "enable_argocd": "true",
  "enable_aws_cloudwatch_metrics": "true",
  "enable_aws_ebs_csi_resources": "true",
  "enable_aws_for_fluentbit": "true",
  "enable_aws_load_balancer_controller": "true",
  "enable_cert_manager": "true",
  "enable_external_dns": "true",
  "enable_external_secrets": "true",
  "enable_ingress_nginx": "true",
  "enable_karpenter": "true",
  "enable_kyverno": "true",
  "enable_metrics_server": "true",
  "environment": "dev",
  "kubernetes_version": "1.28"
}
```
export AKUITY_INSTANCE=$(akuity --org-name $TF_VAR_akp_org_name argocd instance list -o json | jq -r '.[0].name')
export ARGOCD_SERVER=$(akuity --org-name $TF_VAR_akp_org_name argocd instance list -o json | jq -r '.[0].hostname')
export ARGOCD_OPTS="--grpc-web"
argocd login $ARGOCD_SERVER --username admin --password $TF_VAR_argocd_admin_password

akuity --org-name $TF_VAR_akp_org_name argocd instance list
akuity --org-name $TF_VAR_akp_org_name argocd cluster list
akuity argocd cluster get --org-name $TF_VAR_akp_org_name



## Deploy the Addons
Bootstrap the addons using ArgoCD:
```shell
argocd appset create --upsert ./gitops/bootstrap/control-plane/exclude/addons-akuity.yaml
```

### Monitor GitOps Progress for Addons
Wait until all the ArgoCD applications' `HEALTH STATUS` is `Healthy`. Use Crl+C to exit the `watch` command
```shell
argocd app list
```
The output looks like this
```
NAME                                                         CLUSTER            NAMESPACE          PROJECT  STATUS  HEALTH   SYNCPOLICY  CONDITIONS  REPO                                               PATH                                        TARGET
argocd/addon-ex-eks-akuity-dev-aws-cloudwatch-metrics        ex-eks-akuity-dev  amazon-cloudwatch  default  Synced  Healthy  Auto        <none>      git@github.com:gitops-bridge/gitops-bridge                                              main
argocd/addon-ex-eks-akuity-dev-aws-ebs-csi-resources         ex-eks-akuity-dev                     default  Synced  Healthy  Auto        <none>      git@github.com:gitops-bridge/gitops-bridge  gitops/charts/addons/aws-ebs-csi/resources  main
argocd/addon-ex-eks-akuity-dev-aws-for-fluent-bit            ex-eks-akuity-dev  kube-system        default  Synced  Healthy  Auto        <none>      git@github.com:gitops-bridge/gitops-bridge                                              main
argocd/addon-ex-eks-akuity-dev-aws-load-balancer-controller  ex-eks-akuity-dev  kube-system        default  Synced  Healthy  Auto        <none>      git@github.com:gitops-bridge/gitops-bridge                                              main
argocd/addon-ex-eks-akuity-dev-cert-manager                  ex-eks-akuity-dev  cert-manager       default  Synced  Healthy  Auto        <none>      git@github.com:gitops-bridge/gitops-bridge                                              main
argocd/addon-ex-eks-akuity-dev-external-secrets              ex-eks-akuity-dev  external-secrets   default  Synced  Healthy  Auto        <none>      git@github.com:gitops-bridge/gitops-bridge                                              main
argocd/addon-ex-eks-akuity-dev-ingress-nginx                 ex-eks-akuity-dev  ingress-nginx      default  Synced  Healthy  Auto        <none>      git@github.com:gitops-bridge/gitops-bridge                                              main
argocd/addon-ex-eks-akuity-dev-karpenter                     ex-eks-akuity-dev  karpenter          default  Synced  Healthy  Auto        <none>      git@github.com:gitops-bridge/gitops-bridge                                              main
argocd/addon-ex-eks-akuity-dev-kyverno                       ex-eks-akuity-dev  kyverno            default  Synced  Healthy  Auto        <none>      git@github.com:gitops-bridge/gitops-bridge                                              main
argocd/addon-ex-eks-akuity-dev-metrics-server                ex-eks-akuity-dev  kube-system        default  Synced  Healthy  Auto        <none>      git@github.com:gitops-bridge/gitops-bridge                                              main
argocd/cluster-addons                                        in-cluster         argocd             default  Synced  Healthy  Auto        <none>      git@github.com:gitops-bridge/gitops-bridge  gitops/bootstrap/control-plane/addons       main
```


### Verify the Addons
Verify that the addons are ready:
```shell
kubectl get deployment -A
```


## Deploy the Workloads
Deploy a sample application located in [../../gitops/apps/guestbook](../../gitops/apps/guestbook) using ArgoCD:
```shell
argocd appset create --upsert ./gitops/bootstrap/workloads/exclude/workloads-akuity.yaml
```

### Monitor GitOps Progress for Workloads
Watch until the Workloads ArgoCD Application is `Healthy`
```shell
watch argocd app get workload
```
Wait until the ArgoCD Applications `HEALTH STATUS` is `Healthy`. Crl+C to exit the `watch` command

Output should look like the following:
```text
Name:               argocd/workload
Project:            default
Server:             in-cluster
Namespace:          argocd
URL:                https://k9gjmlz7hz2jiqe2.cd.akuity.cloud/applications/workload
Repo:               git@github.com:gitops-bridge/gitops-bridge
Target:             main
Path:               gitops/bootstrap/workloads
SyncWindow:         Sync Allowed
Sync Policy:        Automated
Sync Status:        Synced to main (fc6768e)
Health Status:      Healthy

GROUP        KIND            NAMESPACE  NAME       STATUS  HEALTH   HOOK  MESSAGE
argoproj.io  ApplicationSet  argocd     guestbook  Synced  Healthy        applicationset.argoproj.io/guestbook created
```

### Verify the Application
Verify that the application configuration is present and the pod is running:
```shell
kubectl get -n guestbook deployments,service,ep,ingress
```

### Access the Application using AWS Load Balancer
Verify the application endpoint health using `curl`:
```shell
curl -I $(kubectl get -n ingress-nginx svc ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
```
The first line of the output should have `HTTP/1.1 200 OK`.

Retrieve the ingress URL for the application, and access in the browser:
```shell
echo "Application URL: http://$(kubectl get -n ingress-nginx svc ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')"
```


### Container Metrics
Check the application's CPU and memory metrics:
```shell
kubectl top pods -n guestbook
```

Output should look like the following:
```
NAMESPACE           NAME                                                CPU(cores)   MEMORY(bytes)
akuity              akuity-agent-764cc87d89-2gmd6                       1m           10Mi
akuity              akuity-agent-764cc87d89-jjlvt                       1m           10Mi
akuity              argocd-application-controller-66664445b8-mmh8n      8m           154Mi
akuity              argocd-notifications-controller-7646fd4549-xzgjg    1m           19Mi
akuity              argocd-redis-6fd6f6556b-4l8px                       2m           4Mi
akuity              argocd-repo-server-6f8c6f6cf5-454t8                 1m           42Mi
akuity              argocd-repo-server-6f8c6f6cf5-6fj2d                 1m           35Mi
amazon-cloudwatch   aws-cloudwatch-metrics-7fh49                        11m          25Mi
amazon-cloudwatch   aws-cloudwatch-metrics-8879k                        10m          24Mi
cert-manager        cert-manager-55657857dd-xc9ww                       1m           15Mi
cert-manager        cert-manager-cainjector-7b5b5d4786-xtjbk            1m           25Mi
cert-manager        cert-manager-webhook-55fb5c9c88-w66h5               1m           8Mi
external-secrets    external-secrets-cb85c6976-hcg7m                    1m           19Mi
external-secrets    external-secrets-cert-controller-767c998588-ck8xj   1m           38Mi
external-secrets    external-secrets-webhook-9f9c4f65-wzptp             1m           18Mi
guestbook           guestbook-ui-7d6d6cbf96-qvbkg                       1m           9Mi
ingress-nginx       ingress-nginx-controller-7f9796776-gxpn7            1m           68Mi
ingress-nginx       ingress-nginx-controller-7f9796776-hlvmm            2m           68Mi
ingress-nginx       ingress-nginx-controller-7f9796776-v4x7t            2m           70Mi
karpenter           karpenter-799746c7c9-27ggv                          2m           25Mi
karpenter           karpenter-799746c7c9-p987j                          9m           46Mi
kube-system         aws-for-fluent-bit-bmfqf                            1m           19Mi
kube-system         aws-for-fluent-bit-gdxb6                            1m           21Mi
kube-system         aws-load-balancer-controller-55c676478-2dlz4        3m           27Mi
kube-system         aws-load-balancer-controller-55c676478-xc295        1m           20Mi
kube-system         aws-node-659vb                                      3m           56Mi
kube-system         aws-node-hjbkr                                      4m           59Mi
kube-system         coredns-59754897cf-8bct9                            2m           14Mi
kube-system         coredns-59754897cf-rthvl                            1m           14Mi
kube-system         ebs-csi-controller-86497db997-cxxdp                 4m           56Mi
kube-system         ebs-csi-controller-86497db997-qpxzk                 2m           51Mi
kube-system         ebs-csi-node-j2cpt                                  1m           21Mi
kube-system         ebs-csi-node-p6bzr                                  2m           21Mi
kube-system         kube-proxy-9ds98                                    1m           14Mi
kube-system         kube-proxy-hkw2f                                    1m           12Mi
kube-system         metrics-server-5b76987ff-ccdmr                      4m           16Mi
kyverno             kyverno-admission-controller-6f54d4786f-bdmgq       3m           82Mi
kyverno             kyverno-background-controller-696c6d575c-6r5z7      2m           30Mi
kyverno             kyverno-cleanup-controller-79dd5858df-69nkw         2m           19Mi
kyverno             kyverno-reports-controller-5fcd875795-mk2dr         1m           31Mi
```

## Destroy the Kubernetes Cluster
To tear down all the resources and the EKS cluster, run the following command:
```shell
./destroy.sh
```
