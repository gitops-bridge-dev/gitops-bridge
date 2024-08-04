## Fiverr Public Helm Templates - Karpenter Nodes

### Introduction
This Helm Template is designed to generate NodeClasses and NodePools using [Karpenter](https://karpenter.sh/) in addition to optional HeadRoom.

The template follows a naming convention which is comprised of the `nodegroup` name and its architecture (amd64, arm64 or multiarch).

For example `nodes-default-amd64`

The chart will loop over the `nodegroups` and generate the relevant NodeClasses and NodePools.

### UserData
The `UserData` field supports templating and your own values. You can take a look at the `userdata_example_values.yaml` file for an example.

## Working with Helm

### Setting up
1. Add Repository: </br>```helm repo add fiverr_public https://opensource.fiverr.com/public_charts/```
2. Either get the values.yaml file from the repository or pull it with the following command: </br>```helm show values fiverr_public/karpenter_nodes > values.yaml```
3. Edit the values.yaml file to your needs.
4. Install the chart: </br>```helm install karpenter_nodes fiverr_public/karpenter_nodes -f values.yaml```


### Testing Your Changes
After making changes you will probably want to see the new output. Run `helm template` with the relevant example files: </br>
`helm template <some-name> . -f values.yaml`

### Unit Tests
Make sure you have `helm-unittest` plugin installed. [helm-unittest](https://github.com/helm-unittest/helm-unittest)

Unit tests are written in `tests` directory. To run the tests, use the following command: </br>
`helm unittest --helm3 karpenter_nodes -f "tests/*_test.yaml"`


## Configuration keys
Note - Most of the values can be overridden per nodegroup (If not specified, it will use the default (Global) values)

|  Key Name                      | Description | Type | Optional? | Optional Per NodeGroup? |
| ------------------------------ | ----------- | ---- | --------- | ----------------------- |
| `ApiVersion`                   | ApiVersion used in Karpenter's CRD | `String` | × | × |
| `IamRole`                      | The IAM Role which will be attached to the instance <br> via instance-profile (not required if `IamInstanceProfile` is specified) | `String` | x | ✓ |
| `IamInstanceProfile`           | Existing instance profile To set on the instances <br>(not required if `IamRole` is specified)| `String` | x | ✓ |
| `amiFamily`                    | AMIFamily to use (Default to AL2) [Documentation](https://karpenter.sh/docs/concepts/nodeclasses/#specamifamily) | `String` | x | ✓ |
| `amiSelectorTerms`             | AMI Selector Terms (This will override `amiFamily`) [Documentation](https://karpenter.sh/docs/concepts/nodeclasses/#specamiselectorterms) | `List(Map)` | x | ✓ |
| `subnetSelectorTerms`          | Selector for Subnets [Documentation](https://karpenter.sh/docs/concepts/nodeclasses/#specsubnetselectorterms) | `List(Map)` | x | ✓ |
| `securityGroupSelectorTerms`   | Selector for Security Groups [Documentation](https://karpenter.sh/docs/concepts/nodeclasses/#specsecuritygroupselectorterms) | `List(Map)` | x | ✓ |
| `nodeGroupLabelName`           | The Name of the label for each nodegroup (default is `nodegroup`) | `String` | x | ✓ |
| `nodeTags`                     | Tags to add to the instances `<tag_name>`: `<tag_value>` | `Map` | ✓ | ✓ |
| `nodegroups.{}`                | each will be used to setup a provisioner and template based on the nodegrup name key | `List[Maps]` | x | ✓ |
| `blockDeviceMappings`          | Block Device Mappings [Documentation](https://karpenter.sh/docs/concepts/nodeclasses/#specblockdevicemappings) | `List(Map)` | x | ✓ |
| `detailedMonitoring`           | Detailed Monitoring [Documentation](https://karpenter.sh/docs/concepts/nodeclasses/#specdetailedmonitoring) | `Boolean` | x | ✓ |
| `associatePublicIPAddress`     | Associate Public IP Address [Documentation](https://karpenter.sh/docs/concepts/nodeclasses/#specassociatepublicipaddress) | `Boolean` | x | ✓ |
| `instanceStorePolicy`          | Instance Store Policy [Documentation](https://karpenter.sh/docs/concepts/nodeclasses/#specinstancestorepolicy) | `String` | ✓ | ✓ |
| `metaDataHttpEndpoint`         | Metadata HTTP Endpoint [Documentation](https://karpenter.sh/docs/concepts/nodeclasses/#specmetadataoptions) | `String` | x | ✓ |
| `metaDataHttpProtocolIPv6`     | Metadata HTTP Protocol IPv6 [Documentation](https://karpenter.sh/docs/concepts/nodeclasses/#specmetadataoptions) | `String` | x | ✓ |
| `metaDataHttpPutResponseHopLimit` | Metadata HTTP Put Response Hop Limit [Documentation](https://karpenter.sh/docs/concepts/nodeclasses/#specmetadataoptions) | `String` | x | ✓ |
| `metaDataHttpTokens`           | Metadata HTTP Tokens [Documentation](https://karpenter.sh/docs/concepts/nodeclasses/#specmetadataoptions) | `String` | x | ✓ |
| `userData`                     | User Data (supports templating and your own values) | `MultilineString` | ✓ | ✓ |
| `instances`                    | Instance configurations for node types, families and sizing - see below | `Map` | x | ✓ |
| `instances.minGeneration`      | The minimum instance generation to use (for example 4 = c4,c5,c6 etc) | `Integer` | x | ✓ |
| `instances.architecture`       | `amd64`, `arm64` or `multiarch` for nodegroups which can have combined architectures | `String` | x | ✓ |
| `instances.categories`         | Allowed instance categories (c, m, r) | `List(String)` | x | ✓ |
| `instances.cores`              | Allowed cores per instance (`"4"`, `"8"`) | `List(String(int))` | x | ✓ |
| `instances.capacityType`       | `spot`, `on-demand` (can use both on single provisioner) | `List(String)` | x | ✓ |
| `instances.operatingSystems`   | Allowed operating systems (`"linux"`, `"windows"`) | `List(String)` | x | ✓ |
| `instances.instanceTypes`                | Explicit list of instance types to use (ie `m7i.xlarge`) This will ignore all sizing related requirements | `List(String)` | x | ✓ |
| `availabilityZones`            | Availability Zones to use | `List(String)` | x | ✓ |
| `expireAfter`                  | Specify how long node should be up before refreshing it [Documentation](https://karpenter.sh/docs/concepts/disruption/#automated-methods) | `String` | x | ✓ |
| `weight`                       | Specify NodeGroup Weight (default is `1`) | `Integer` | x | ✓ |
| `excludeFamilies`              | Exclude specific instance families | `List` | x | ✓ |
| `consolidationPolicy`          | Specify how to consolidate nodes [Documentation](https://karpenter.sh/docs/concepts/nodepools/) | `String` | x | ✓ |
| `consolidateAfter`             | Specify how long to wait before consolidating nodes [Documentation](https://karpenter.sh/docs/concepts/nodepools/) | `String` | ✓ | ✓ |
| `excludeInstanceSize`          | Exclude specific instance sizes | `List` | ✓ | ✓ |
| `headRoom`                     | Generate Ultra Low Priority Class for Headroom (see below) | `String` | ✓ | x |
| `additionalRequirements`       | add NodePool requirements which are not covered by this chart | `List(map)` | ✓ | ✓ |
| `autoTaint`                    | add NodePool taint with `dedicated` as key and nodegroup name as value (`-` replaced with `_`) | `Boolean(String)` | ✓ | ✓ |
| `cilium`                       | Add startupTaints for Cilium | `Boolean` | ✓ | ✓ |
| `ciliumEffect`                 | Set Effect on CiliumStartupTaint (Default `NoExecute`) [Documentation](https://docs.cilium.io/en/stable/installation/taints/) | `String` | ✓ | ✓ |

### NodeGroup Configuration
|  Key Name                      | Description | Type | Optional? | Optional Per NodeGroup? |
| ------------------------------ | ----------- | ---- | --------- | ----------------------- |
| `nodegroups.{}.labels`         | Labels to add to nodes `<label_name>`: `<label_value>` | `Map` | ✓ | ✓ |
| `nodegroups.{}.additionalNodeTags` | Additional Tags to add to the instances `<tag_name>`: `<tag_value>` | `Map` | ✓ | ✓ |
| `nodegroups.{}.annotations`    | Annotations to add to nodes `<annotation_name>`: `<annotation_value>` | `Map` | ✓ | ✓ |
| `nodegroups.{}.nodeClassRef`   | If you wish to use your own nodeClass, specify it [Documentation](https://karpenter.sh/docs/concepts/nodeclasses/) | `Map` | ✓ | ✓ |
| `nodegroups.{}.taints`         | Taints to add to nodes `- <taint_key>`: `<taint_value>`: `<taint_effect>` | `List(Map)` | ✓ | ✓ |
| `nodegroups.{}.startupTaints`  | startupTaints to add to nodes `- <taint_key>`: `<taint_value>`: `<taint_effect>` | `List(Map)` | ✓ | ✓ |
| `nodegroups.{}.limits`         | Specify Limits [Documentation](https://karpenter.sh/docs/concepts/nodepools/#speclimits) | `Map` | ✓ | ✓ |
| `nodegroups.{}.capacitySpread` | Set range of capacity spread keys (`integers`), set int for `start` and `end` | `Map` | ✓ | ✓ |
| `nodegroups.{}.excludeFamilies`| Exclude specific instance families | `List` | ✓ | ✓ |
| `nodegroups.{}.budgets`        | Specify Disruption Budgets [Documentation](https://karpenter.sh/docs/concepts/disruption/#nodes) | `List` | ✓ | ✓ |
| `nodegroups.{}.*`              | Over-write all above which supports it | `Map` | ✓ | ✓ |
| `nodegroups.{}.instances.*`    | Explicitly specify instances override, if using defaults specify `instances: {}` | `Map` | ✓ | ✓ |

### Headroom Configuration
Headroom will create `pause` pods with resources-requests to just keep free amount of resources up and ready for scheduling.<br> This is useful for scaling up quickly when needed.<br>
The pods will be configured with ultra-low priority, and will be terminated and recreated on new nodes to free them up for usage if needed.
|  Key Name                      | Description | Type | Optional? | Optional Per NodeGroup? |
| ------------------------------ | ----------- | ---- | --------- | ----------------------- |
| `nodegroups.{}.headRoom`       | List of headroom configurations for the nodePool | `List(Map)` | ✓ | ✓ |
| `nodegroups.{}.headRoom.size`  | `small`, `medium`, `large`, `xlarge` - see below | `String` | ✓ | ✓ |
| `nodegroups.{}.headRoom.count` | Number of headroom pod replicas to schedule | `Integer` | ✓ | ✓ |
| `nodegroups.{}.headRoom.antiAffinitySpec` | Optional - set antiaffinity to match against running workloads | `LabelSelectorSpec` | ✓ | ✓ |
| `nodegroups.{}.headRoom.nameSpaces` | Specify list of namespaces to match again (default `all`) | `List(String)` | ✓ | ✓ |

### Headroom Sizing

|  Size | CPU | Ram |
| ----- | --- | --- |
| `small` | 1 | 4Gi |
| `medium` | 2 | 8Gi |
| `large` | 4 | 16Gi |
| `xlarge` | 8 | 32Gi |

### Kubelet Configuration
[Documentation](https://karpenter.sh/docs/concepts/nodepools/#spectemplatespeckubelet)
Kubelet configuration can be set globally or per nodegroup. The following keys are supported:
|  Key Name                      | Description | Type | Optional? | Optional Per NodeGroup? |
| ------------------------------ | ----------- | ---- | --------- | ----------------------- |
| `kubeletClusterDNS`            | Cluster DNS | `List` | ✓ | ✓ |
| `kubeletSystemReservedCpu`     | System Reserved CPU | `String` | x | ✓ |
| `kubeletSystemReservedMemory`  | System Reserved Memory | `String` | x | ✓ |
| `kubeletSystemReservedEphemeralStorage` | System Reserved Ephemeral Storage | `String` | x | ✓ |
| `kubeletKubeReservedCpu`       | Kube Reserved CPU | `String` | x | ✓ |
| `kubeletKubeReservedMemory`    | Kube Reserved Memory | `String` | x | ✓ |
| `kubeletKubeReservedEphemeralStorage` | Kube Reserved Ephemeral Storage | `String` | x | ✓ |
| `kubeletEvictionHardMemoryAvailable` | Eviction Hard Memory Available | `String` | x | ✓ |
| `kubeletEvictionHardNodefsAvailable` | Eviction Hard Nodefs Available | `String` | x | ✓ |
| `kubeletEvictionHardNodefsInodesFree` | Eviction Hard Nodefs Inodes Free | `String` | x | ✓ |
| `kubeletEvictionSoftMemoryAvailable` | Eviction Soft Memory Available | `String` | x | ✓ |
| `kubeletEvictionSoftNodefsAvailable` | Eviction Soft Nodefs Available | `String` | x | ✓ |
| `kubeletEvictionSoftNodefsInodesFree` | Eviction Soft Nodefs Inodes Free | `String` | x | ✓ |
| `kubeletEvictionSoftImagefsAvailable` | Eviction Soft Imagefs Available | `String` | x | ✓ |
| `kubeletEvictionSoftImagefsInodesFree` | Eviction Soft Imagefs Inodes Free | `String` | x | ✓ |
| `kubeletEvictionSoftPidAvailable` | Eviction Soft Pid Available | `String` | x | ✓ |
| `kubeletEvictionSoftGracePeriodImagefsAvailable` | Eviction Soft Grace Period Imagefs Available | `String` | x | ✓ |
| `kubeletEvictionSoftGracePeriodImagefsInodesFree` | Eviction Soft Grace Period Imagefs Inodes Free | `String` | x | ✓ |
| `kubeletEvictionSoftGracePeriodMemoryAvailable` | Eviction Soft Grace Period Memory Available | `String` | x | ✓ |
| `kubeletEvictionSoftGracePeriodNodefsAvailable` | Eviction Soft Grace Period Nodefs Available | `String` | x | ✓ |
| `kubeletEvictionSoftGracePeriodNodefsInodesFree` | Eviction Soft Grace Period Nodefs Inodes Free | `String` | x | ✓ |
| `kubeletEvictionSoftGracePeriodPidAvailable` | Eviction Soft Grace Period Pid Available | `String` | x | ✓ |
| `kubeletImageGCHighThresholdPercent` | Image GC High Threshold Percent | `String` | ✓ | ✓ |
| `kubeletImageGCLowThresholdPercent` | Image GC Low Threshold Percent | `String` | ✓ | ✓ |
| `kubeletImageMinimumGCAge` | Image Minimum GC Age | `String` | ✓ | ✓ |
| `kubeletCpuCFSQuota` | CPU CFS Quota | `String` | ✓ | ✓ |
| `kubeletPodsPerCore` | Pods Per Core | `String` | ✓ | ✓ |
| `kubeletMaxPods` | Max Pods | `String` | ✓ | ✓ |

## Extras
See grafana directory for dashbaords available for you to import into your Grafana instance.
