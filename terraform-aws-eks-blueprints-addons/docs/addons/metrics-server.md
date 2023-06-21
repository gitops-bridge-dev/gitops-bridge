# Metrics Server

[Metrics Server](https://github.com/kubernetes-sigs/metrics-server) is a scalable, efficient source of container resource metrics for Kubernetes built-in autoscaling pipelines.

Metrics Server collects resource metrics from Kubelets and exposes them in Kubernetes apiserver through Metrics API for use by Horizontal Pod Autoscaler and Vertical Pod Autoscaler. Metrics API can also be accessed by kubectl top, making it easier to debug autoscaling pipelines.

## Usage

Metrics Server can be deployed by enabling the add-on via the following.

```hcl
enable_metrics_server = true
```

You can optionally customize the Helm chart that deploys External DNS via the following configuration.

```hcl
  enable_metrics_server = true

  metrics_server = {
    name          = "metrics-server"
    chart_version = "3.10.0"
    repository    = "https://kubernetes-sigs.github.io/metrics-server/"
    namespace     = "kube-system"
    values        = [templatefile("${path.module}/values.yaml", {})]
  }
```

Verify metrics-server pods are running.

```sh
$ kubectl get pods -n kube-system
NAME                                   READY   STATUS    RESTARTS       AGE
metrics-server-6f9cdd486c-njh8b        1/1     Running   1 (2d2h ago)   2d7h
```
