# Cluster Proportional Autoscaler

Horizontal cluster-proportional-autoscaler watches over the number of schedulable nodes and cores of the cluster and resizes the number of replicas for the required resource. This functionality may be desirable for applications that need to be autoscaled with the size of the cluster, such as CoreDNS and other services that scale with the number of nodes/pods in the cluster.

The [cluster-proportional-autoscaler](https://github.com/kubernetes-sigs/cluster-proportional-autoscaler) helps to scale the applications using deployment or replicationcontroller or replicaset. This is an alternative solution to Horizontal Pod Autoscaling.
It is typically installed as a **Deployment** in your cluster.

Refer to the [eks-best-practices-guides](https://aws.github.io/aws-eks-best-practices/reliability/docs/dataplane/#configure-cluster-proportional-scaler-for-coredns) for addional configuration guidanance.

## Usage

This add-on requires both `enable_cluster_proportional_autoscaler` and `cluster_proportional_autoscaler` as mandatory fields.

The example shows how to enable `cluster-proportional-autoscaler` for `CoreDNS Deployment`. CoreDNS deployment is not configured with HPA. So, this add-on helps to scale CoreDNS Add-on according to the size of the nodes and cores.

This Add-on can be used to scale any application with Deployment objects.

```hcl
enable_cluster_proportional_autoscaler  = true
cluster_proportional_autoscaler  = {
    values = [
      <<-EOT
        nameOverride: kube-dns-autoscaler

        # Formula for controlling the replicas. Adjust according to your needs
        # replicas = max( ceil( cores * 1/coresPerReplica ) , ceil( nodes * 1/nodesPerReplica ) )
        config:
          linear:
            coresPerReplica: 256
            nodesPerReplica: 16
            min: 1
            max: 100
            preventSinglePointFailure: true
            includeUnschedulableNodes: true

        # Target to scale. In format: deployment/*, replicationcontroller/* or replicaset/* (not case sensitive).
        options:
          target: deployment/coredns # Notice the target as `deployment/coredns`

        serviceAccount:
          create: true
          name: kube-dns-autoscaler

        podSecurityContext:
          seccompProfile:
            type: RuntimeDefault
            supplementalGroups: [65534]
            fsGroup: 65534

        resources:
          limits:
            cpu: 100m
            memory: 128Mi
          requests:
            cpu: 100m
            memory: 128Mi

        tolerations:
          - key: "CriticalAddonsOnly"
            operator: "Exists"
            description: "Cluster Proportional Autoscaler for CoreDNS Service"
      EOT
    ]
}
```
### Expected result
The `cluster-proportional-autoscaler` pod running in the `kube-system` namespace.
```bash
kubectl -n kube-system get po -l app.kubernetes.io/instance=cluster-proportional-autoscaler
NAME                                                              READY   STATUS    RESTARTS   AGE
cluster-proportional-autoscaler-kube-dns-autoscaler-d8dc8477xx7   1/1     Running   0          21h
```
The `cluster-proportional-autoscaler-kube-dns-autoscaler` config map exists.
```bash
kubectl -n kube-system get cm cluster-proportional-autoscaler-kube-dns-autoscaler
NAME                                                  DATA   AGE
cluster-proportional-autoscaler-kube-dns-autoscaler   1      21h
```

## Testing
To test that `coredns` pods scale, first take a baseline of how many nodes the cluster has and how many `coredns` pods are running.
```bash
kubectl get nodes
NAME                          STATUS   ROLES    AGE   VERSION
ip-10-0-19-243.ec2.internal   Ready    <none>   21h   v1.26.4-eks-0a21954
ip-10-0-25-182.ec2.internal   Ready    <none>   21h   v1.26.4-eks-0a21954
ip-10-0-40-138.ec2.internal   Ready    <none>   21h   v1.26.4-eks-0a21954
ip-10-0-8-136.ec2.internal    Ready    <none>   21h   v1.26.4-eks-0a21954

kubectl get po -n kube-system -l k8s-app=kube-dns
NAME                       READY   STATUS    RESTARTS   AGE
coredns-7975d6fb9b-dlkdd   1/1     Running   0          21h
coredns-7975d6fb9b-xqqwp   1/1     Running   0          21h
```

Change the following parameters in the hcl code above so a scaling event can be easily triggered:
```hcl
        config:
          linear:
            coresPerReplica: 4
            nodesPerReplica: 2
            min: 1
            max: 4
```
and execute `terraform apply`.

Increase the managed node group desired size, in this example from 4 to 5. This can be done via the AWS Console.

Check that the new node came up and `coredns` scaled up.
```bash
NAME                          STATUS   ROLES    AGE   VERSION
ip-10-0-14-120.ec2.internal   Ready    <none>   10m   v1.26.4-eks-0a21954
ip-10-0-19-243.ec2.internal   Ready    <none>   21h   v1.26.4-eks-0a21954
ip-10-0-25-182.ec2.internal   Ready    <none>   21h   v1.26.4-eks-0a21954
ip-10-0-40-138.ec2.internal   Ready    <none>   21h   v1.26.4-eks-0a21954
ip-10-0-8-136.ec2.internal    Ready    <none>   21h   v1.26.4-eks-0a21954

kubectl get po -n kube-system -l k8s-app=kube-dns
NAME                       READY   STATUS    RESTARTS   AGE
coredns-7975d6fb9b-dlkdd   1/1     Running   0          21h
coredns-7975d6fb9b-ww64t   1/1     Running   0          10m
coredns-7975d6fb9b-xqqwp   1/1     Running   0          21h
```
