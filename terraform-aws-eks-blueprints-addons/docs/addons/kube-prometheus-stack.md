# Kube Prometheus Stack

[Kube Prometheus Stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack) is a collection of Kubernetes manifests, Grafana dashboards, and Prometheus rules combined with documentation and scripts to provide easy to operate end-to-end Kubernetes cluster monitoring with Prometheus using the Prometheus Operator.

## Usage

Kube Prometheus Stack can be deployed by enabling the add-on via the following.

```hcl
enable_kube_prometheus_stack = true
```

You can optionally customize the Helm chart that deploys Kube Prometheus Stack via the following configuration.

```hcl
  enable_kube_prometheus_stack = true

  kube_prometheus_stack = {
    name          = "kube-prometheus-stack"
    chart_version = "45.10.1"
    repository    = "https://charts.external-secrets.io"
    namespace     = "kube-prometheus-stack"
    values        = [templatefile("${path.module}/values.yaml", {})]
  }
```

Verify kube-prometheus-stack pods are running.

```sh
$ kubectl get pods -n external-secrets
NAME                                                        READY   STATUS    RESTARTS       AGE
alertmanager-kube-prometheus-stack-alertmanager-0           2/2     Running   3 (2d2h ago)   2d7h
kube-prometheus-stack-grafana-5c6cf88fd9-8wc9k              3/3     Running   3 (2d2h ago)   2d7h
kube-prometheus-stack-kube-state-metrics-584d8b5d5f-s6p8d   1/1     Running   1 (2d2h ago)   2d7h
kube-prometheus-stack-operator-c74ddccb5-8cprr              1/1     Running   1 (2d2h ago)   2d7h
kube-prometheus-stack-prometheus-node-exporter-vd8lw        1/1     Running   1 (2d2h ago)   2d7h
prometheus-kube-prometheus-stack-prometheus-0               2/2     Running   2 (2d2h ago)   2d7h
```
