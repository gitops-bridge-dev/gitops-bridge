# AWS for Fluent Bit

AWS provides a Fluent Bit image with plugins for both CloudWatch Logs and Kinesis Data Firehose. We recommend using Fluent Bit as your log router because it has a lower resource utilization rate than Fluentd.

## Usage

AWS for Fluent Bit can be deployed by enabling the add-on via the following.

```hcl
enable_aws_for_fluentbit = true
```

You can optionally customize the Helm chart that deploys AWS for Fluent Bit via the following configuration.

```hcl
  enable_aws_for_fluentbit = true
  aws_for_fluentbit_cw_log_group = {
    create          = true
    use_name_prefix = true # Set this to true to enable name prefix
    name_prefix     = "eks-cluster-logs-"
    retention       = 7
  }
  aws_for_fluentbit = {
    name          = "aws-for-fluent-bit"
    chart_version = "0.1.24"
    repository    = "https://aws.github.io/eks-charts"
    namespace     = "kube-system"
    values        = [templatefile("${path.module}/values.yaml", {})]
  }
```

## Verify the Fluent Bit setup

Verify aws-for-fluentbit pods are running.

```sh
$ kuebctl get pods -n kube-system
NAME                                                         READY   STATUS    RESTARTS       AGE
aws-for-fluent-bit-6kp66                                     1/1     Running   0              172m
```

Open the CloudWatch console at https://console.aws.amazon.com/cloudwatch/


In the navigation pane, choose Log groups.

Make sure that you're in the Region where you deployed Fluent Bit.

Check the list of log groups in the Region. You should see the following:

```
/aws/containerinsights/Cluster_Name/application

/aws/containerinsights/Cluster_Name/host

/aws/containerinsights/Cluster_Name/dataplane
```

Navigate to one of these log groups and check the Last Event Time for the log streams. If it is recent relative to when you deployed Fluent Bit, the setup is verified.

There might be a slight delay in creating the /dataplane log group. This is normal as these log groups only get created when Fluent Bit starts sending logs for that log group.
