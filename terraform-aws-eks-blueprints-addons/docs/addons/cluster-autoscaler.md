# Cluster Autoscaler

The Kubernetes [Cluster Autoscaler](https://github.com/kubernetes/autoscaler) automatically adjusts the number of nodes in your cluster when pods fail or are rescheduled onto other nodes. The Cluster Autoscaler uses Auto Scaling groups. For more information, see [Cluster Autoscaler on AWS](https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/cloudprovider/aws/README.md).

## Usage

Cluster Autoscaler can be deployed by enabling the add-on via the following.

```hcl
enable_cluster_autoscaler = true
```

You can optionally customize the Helm chart that deploys Cluster Autoscaler via the following configuration.

```hcl
  enable_cluster_autoscaler = true

  cluster_autoscaler = {
    name          = "cluster-autoscaler"
    chart_version = "9.29.0"
    repository    = "https://kubernetes.github.io/autoscaler"
    namespace     = "kube-system"
    values        = [templatefile("${path.module}/values.yaml", {})]
  }

```

Verify cluster-autoscaler pods are running.

```sh
$ kubectl get pods -n kube-system
NAME                                                         READY   STATUS    RESTARTS     AGE
cluster-autoscaler-aws-cluster-autoscaler-7ff79bc484-pm8g9   1/1     Running   1 (2d ago)   2d5h
```
