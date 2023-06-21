# AWS Secrets Manager and Config Provider for Secret Store CSI Driver

AWS offers two services to manage secrets and parameters conveniently in your code. AWS Secrets Manager allows you to easily rotate, manage, and retrieve database credentials, API keys, certificates, and other secrets throughout their lifecycle. AWS Systems Manager Parameter Store provides hierarchical storage for configuration data. The [AWS provider for the Secrets Store CSI Driver](https://github.com/aws/secrets-store-csi-driver-provider-aws) allows you to make secrets stored in Secrets Manager and parameters stored in Parameter Store appear as files mounted in Kubernetes pods.

## Usage

AWS Secrets Store CSI Driver can be deployed by enabling the add-on via the following.

```hcl
enable_secrets_store_csi_driver              = true
enable_secrets_store_csi_driver_provider_aws = true
```

You can optionally customize the Helm chart via the following configuration.

```hcl
  enable_secrets_store_csi_driver              = true
  enable_secrets_store_csi_driver_provider_aws = true

  secrets_store_csi_driver_provider_aws = {
    name          = "secrets-store-csi-driver"
    chart_version = "0.3.2"
    repository    = "https://aws.github.io/secrets-store-csi-driver-provider-aws"
    namespace     = "kube-system"
    values        = [templatefile("${path.module}/values.yaml", {})]
  }
```

Verify metrics-server pods are running.

```sh
$ kubectl get pods -n kube-system
NAME                                         READY   STATUS    RESTARTS       AGE
secrets-store-csi-driver-9l2z8               3/3     Running   1 (2d5h ago)   2d9h
secrets-store-csi-driver-provider-aws-2qqkk  1/1     Running   1 (2d5h ago)   2d9h
```
