# AWS Node Termination Handler

This project ensures that the Kubernetes control plane responds appropriately to events that can cause your EC2 instance to become unavailable, such as [EC2 maintenance events](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/monitoring-instances-status-check_sched.html), [EC2 Spot interruptions](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/spot-interruptions.html), [ASG Scale-In](https://docs.aws.amazon.com/autoscaling/ec2/userguide/AutoScalingGroupLifecycle.html#as-lifecycle-scale-in), ASG AZ Rebalance, and EC2 Instance Termination via the API or Console. If not handled, your application code may not stop gracefully, take longer to recover full availability, or accidentally schedule work to nodes that are going down.

## Usage

AWS Node Termination Handler can be deployed by enabling the add-on via the following.

```hcl
enable_aws_node_termination_handler = true
```

You can optionally customize the Helm chart that deploys AWS Node Termination Handler via the following configuration.

```hcl
  enable_aws_node_termination_handler = true

  aws_node_termination_handler = {
    name          = "aws-node-termination-handler"
    chart_version = "0.21.0"
    repository    = "https://aws.github.io/eks-charts"
    namespace     = "aws-node-termination-handler"
    values        = [templatefile("${path.module}/values.yaml", {})]
  }

```

Verify aws-node-termination-handler pods are running.

```sh
$ kubectl get pods -n aws-node-termination-handler
NAME                                            READY   STATUS    RESTARTS      AGE
aws-node-termination-handler-6f598b6b89-6mqgk   1/1     Running   1 (22h ago)   26h
```

Verify SQS Queue is created.

```sh
$ aws sqs list-queues

{
    "QueueUrls": [
        "https://sqs.us-east-1.amazonaws.com/XXXXXXXXXXXXXX/aws_node_termination_handler20221123072051157700000004"
    ]
}
```

Verify Event Rules are created.

```sh
$ aws event list-rules
{
    [
        {
            "Name": "NTH-ASGTerminiate-20230602191740664900000025",
            "Arn": "arn:aws:events:us-west-2:XXXXXXXXXXXXXX:rule/NTH-ASGTerminiate-20230602191740664900000025",
            "EventPattern": "{\"detail-type\":[\"EC2 Instance-terminate Lifecycle Action\"],\"source\":[\"aws.autoscaling\"]}",
            "State": "ENABLED",
            "Description": "Auto scaling instance terminate event",
            "EventBusName": "default"
        },
        {
            "Name": "NTH-HealthEvent-20230602191740079300000022",
            "Arn": "arn:aws:events:us-west-2:XXXXXXXXXXXXXX:rule/NTH-HealthEvent-20230602191740079300000022",
            "EventPattern": "{\"detail-type\":[\"AWS Health Event\"],\"source\":[\"aws.health\"]}",
            "State": "ENABLED",
            "Description": "AWS health event",
            "EventBusName": "default"
        },
        {
            "Name": "NTH-InstanceRebalance-20230602191740077100000021",
            "Arn": "arn:aws:events:us-west-2:XXXXXXXXXXXXXX:rule/NTH-InstanceRebalance-20230602191740077100000021",
            "EventPattern": "{\"detail-type\":[\"EC2 Instance Rebalance Recommendation\"],\"source\":[\"aws.ec2\"]}",
            "State": "ENABLED",
            "Description": "EC2 instance rebalance recommendation",
            "EventBusName": "default"
        },
        {
            "Name": "NTH-InstanceStateChange-20230602191740165000000024",
            "Arn": "arn:aws:events:us-west-2:XXXXXXXXXXXXXX:rule/NTH-InstanceStateChange-20230602191740165000000024",
            "EventPattern": "{\"detail-type\":[\"EC2 Instance State-change Notification\"],\"source\":[\"aws.ec2\"]}",
            "State": "ENABLED",
            "Description": "EC2 instance state-change notification",
            "EventBusName": "default"
        },
        {
            "Name": "NTH-SpotInterrupt-20230602191740077100000020",
            "Arn": "arn:aws:events:us-west-2:XXXXXXXXXXXXXX:rule/NTH-SpotInterrupt-20230602191740077100000020",
            "EventPattern": "{\"detail-type\":[\"EC2 Spot Instance Interruption Warning\"],\"source\":[\"aws.ec2\"]}",
            "State": "ENABLED",
            "Description": "EC2 spot instance interruption warning",
            "EventBusName": "default"
        },
        {
            "Name": "NTHASGTermRule",
            "Arn": "arn:aws:events:us-west-2:XXXXXXXXXXXXXX:rule/NTHASGTermRule",
            "EventPattern": "{\"detail-type\":[\"EC2 Instance-terminate Lifecycle Action\"],\"source\":[\"aws.autoscaling\"]}",
            "State": "ENABLED",
            "EventBusName": "default"
        },
        {
            "Name": "NTHInstanceStateChangeRule",
            "Arn": "arn:aws:events:us-west-2:XXXXXXXXXXXXXX:rule/NTHInstanceStateChangeRule",
            "EventPattern": "{\"detail-type\":[\"EC2 Instance State-change Notification\"],\"source\":[\"aws.ec2\"]}",
            "State": "ENABLED",
            "EventBusName": "default"
        },
        {
            "Name": "NTHRebalanceRule",
            "Arn": "arn:aws:events:us-west-2:XXXXXXXXXXXXXX:rule/NTHRebalanceRule",
            "EventPattern": "{\"detail-type\":[\"EC2 Instance Rebalance Recommendation\"],\"source\":[\"aws.ec2\"]}",
            "State": "ENABLED",
            "EventBusName": "default"
        },
        {
            "Name": "NTHScheduledChangeRule",
            "Arn": "arn:aws:events:us-west-2:XXXXXXXXXXXXXX:rule/NTHScheduledChangeRule",
            "EventPattern": "{\"detail-type\":[\"AWS Health Event\"],\"source\":[\"aws.health\"]}",
            "State": "ENABLED",
            "EventBusName": "default"
        },
        {
            "Name": "NTHSpotTermRule",
            "Arn": "arn:aws:events:us-west-2:XXXXXXXXXXXXXX:rule/NTHSpotTermRule",
            "EventPattern": "{\"detail-type\":[\"EC2 Spot Instance Interruption Warning\"],\"source\":[\"aws.ec2\"]}",
            "State": "ENABLED",
            "EventBusName": "default"
        }
    ]
}
```
