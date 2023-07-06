# External Secrets

[External Secrets Operator](https://github.com/external-secrets/external-secrets) is a Kubernetes operator that integrates external secret management systems like AWS Secrets Manager, HashiCorp Vault, Google Secrets Manager, Azure Key Vault, IBM Cloud Secrets Manager, and many more. The operator reads information from external APIs and automatically injects the values into a Kubernetes Secret.

## Usage

External Secrets can be deployed by enabling the add-on via the following.

```hcl
enable_external_secrets = true
```

You can optionally customize the Helm chart that deploys External Secrets via the following configuration.

```hcl
  enable_external_secrets = true

  external_secrets = {
    name          = "external-secrets"
    chart_version = "0.8.1"
    repository    = "https://charts.external-secrets.io"
    namespace     = "external-secrets"
    values        = [templatefile("${path.module}/values.yaml", {})]
  }
```

Verify external-secrets pods are running.

```sh
$ kubectl get pods -n external-secrets
NAME                                               READY   STATUS    RESTARTS       AGE
external-secrets-67bfd5b47c-xc5xf                  1/1     Running   1 (2d1h ago)   2d6h
external-secrets-cert-controller-8f75c6f79-qcfx4   1/1     Running   1 (2d1h ago)   2d6h
external-secrets-webhook-78f6bd456-76wmm           1/1     Running   1 (2d1h ago)   2d6h
```
