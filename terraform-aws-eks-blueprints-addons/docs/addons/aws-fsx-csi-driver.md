# AWS FSx CSI Driver

This add-on deploys the [Amazon FSx CSI Driver](https://docs.aws.amazon.com/eks/latest/userguide/fsx-csi.html) in to an Amazon EKS Cluster.

## Usage

The [Amazon FSx CSI Driver](https://github.com/aws-ia/terraform-aws-eks-blueprints/tree/main/modules/kubernetes-addons/aws-fsx-csi-driver) can be deployed by enabling the add-on via the following.

```hcl
  enable_aws_fsx_csi_driver = true
```

### Helm Chart customization

You can optionally customize the Helm chart deployment using a configuration like the following.

```hcl
  enable_aws_fsx_csi_driver = true
  aws_fsx_csi_driver = {
    namespace     = "aws-fsx-csi-driver"
    chart_version = "1.6.0"
    role_policies = <ADDITIONAL_IAM_POLICY_ARN>
  }
```

You can find all available Helm Chart parameter values [here](https://github.com/kubernetes-sigs/aws-fsx-csi-driver/blob/master/charts/aws-fsx-csi-driver/values.yaml)

## Validation

Once deployed, you will be able to see a number of supporting resources in the `kube-system` namespace.

```sh
$ kubectl -n kube-system get deployment fsx-csi-controller

NAME                 READY   UP-TO-DATE   AVAILABLE   AGE
fsx-csi-controller   2/2     2            2           4m29s

$ kubectl -n kube-system get pods -l app=fsx-csi-controller
NAME                                  READY   STATUS    RESTARTS   AGE
fsx-csi-controller-56c6d9bbb8-89cpc   4/4     Running   0          3m30s
fsx-csi-controller-56c6d9bbb8-9wnlh   4/4     Running   0          3m30s
```

```sh
$ kubectl -n kube-system get daemonset fsx-csi-node
NAME           DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
fsx-csi-node   3         3         3       3            3           kubernetes.io/os=linux   5m27s

$ kubectl -n kube-system get pods -l  app=fsx-csi-node
NAME                 READY   STATUS    RESTARTS   AGE
fsx-csi-node-7c5z6   3/3     Running   0          5m29s
fsx-csi-node-d5q28   3/3     Running   0          5m29s
fsx-csi-node-hlg8q   3/3     Running   0          5m29s
```

Create a StorageClass. Replace the SubnetID and the SecurityGroupID with your own values. More details [here](https://docs.aws.amazon.com/eks/latest/userguide/fsx-csi.html).

```sh
$ cat <<EOF | kubectl apply -f -
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: fsx-sc
provisioner: fsx.csi.aws.com
parameters:
  subnetId:	<YOUR_SUBNET_IDs>
  securityGroupIds: <YOUR_SG_ID>
  perUnitStorageThroughput: "200"
  deploymentType: PERSISTENT_1
mountOptions:
  - flock
EOF
```

```sh
$ kubect describe storageclass fsx-sc
Name:            fsx-sc
IsDefaultClass:  No
Annotations:     kubectl.kubernetes.io/last-applied-configuration={"apiVersion":"storage.k8s.io/v1","kind":"StorageClass","metadata":{"annotations":{},"name":"fsx-sc"},"mountOptions":null,"parameters":{"deploymentType":"PERSISTENT_1","perUnitStorageThroughput":"200","securityGroupIds":"sg-q1w2e3r4t5y6u7i8o","subnetId":"subnet-q1w2e3r4t5y6u7i8o"},"provisioner":"fsx.csi.aws.com"}

Provisioner:           fsx.csi.aws.com
Parameters:            deploymentType=PERSISTENT_1,perUnitStorageThroughput=200,securityGroupIds=sg-q1w2e3r4t5y6u7i8o,subnetId=subnet-q1w2e3r4t5y6u7i8o
AllowVolumeExpansion:  <unset>
MountOptions:          <none>
ReclaimPolicy:         Delete
VolumeBindingMode:     Immediate
Events:                <none>
```

Create a PVC.

```sh
$ cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: fsx-claim
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: fsx-sc
  resources:
    requests:
      storage: 1200Gi
EOF
```

Wait for the PV to be created and bound to your PVC.

```sh
$ kubectl get pvc
NAME        STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
fsx-claim   Bound    pvc-df385730-72d6-4b0c-8275-cc055a438760   1200Gi     RWX            fsx-sc         7m47s
$ kubectl get pv
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM               STORAGECLASS   REASON   AGE
pvc-df385730-72d6-4b0c-8275-cc055a438760   1200Gi     RWX            Delete           Bound    default/fsx-claim   fsx-sc                  2m13s
```
