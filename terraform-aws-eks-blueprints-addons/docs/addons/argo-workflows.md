# Argo Workflows

[Argo Workflows](https://argoproj.github.io/argo-workflows/) is an open source container-native workflow engine for orchestrating parallel jobs on Kubernetes. Argo Workflows is implemented as a Kubernetes CRD (Custom Resource Definition).

## Usage

Argo Workflows can be deployed by enabling the add-on via the following.

```hcl
enable_argo_workflows = true
```

You can optionally customize the Helm chart that deploys Argo Workflows via the following configuration.

```hcl
  enable_argo_workflows = true

  argo_workflows = {
    name          = "argo-workflows"
    chart_version = "0.28.2"
    repository    = "https://argoproj.github.io/argo-helm"
    namespace     = "argo-workflows"
    values        = [templatefile("${path.module}/values.yaml", {})]
  }

```

Verify argo-workflows pods are running.

```sh
$ kubectl get pods -n argo-workflows
NAME                                                  READY   STATUS    RESTARTS   AGE
argo-workflows-server-68988cd864-22zhr                1/1     Running   0          6m32s
argo-workflows-workflow-controller-7ff7b5658d-9q44f   1/1     Running   0          6m32s
```
