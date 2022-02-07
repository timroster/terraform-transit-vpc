# terraform-transit-vpc

Demonstration Terraform code to create one or more spoke VPCs, link them to a Transit VPC which then has connectivity to the outside world using a [ZeroTier VNF](https://github.com/timroster/terraform-vsi-zerotier-edge.git). The approach is currently to a single zone, but will be extended to be multi-zonal with one VNF per zone.

The Transit VPC will be configured with a public gateway to allow Internet access. Spoke VPC can be optionally configured with a public gateway. For the provide network range, the first /24 network will be used for the Transit network and then subsequent /24's will be used for each spoke VPC

Input variables to the code:

* project label to use for resources
* id of the ZeroTier network for the server to join
* IBM Cloud API key
* name of a ssh key that has been uploaded to the VPC

Optional variables:

* number of spoke VPC (default: 1)
* enable PGW on spoke VPC (default: false)
* tags to put on all resources (default: null)
* environment lable to put on all resources (default: vpc)
* IBM Cloud region name (default: us-south)
* IBM Cloud VPC zone name (default: us-south-2)
* name of the resource group to use for all resources (default: null = use account default RG)
* Subnet range for transit and spokes on /18 boundary (default: 10.240.0.0/18)

VPC module: This code uses a VPC module that creates a VPC with a specific subnet and PGW, taking a default security group configuration with rule. The module does not specify a `provider {}` section relying on this from the root module. As such, all resources are created in the same region set in the root module.

module inputs:

* name
* tags
* resource group id
* enable PGW
* vpc subnet address
* vpc subnet zone

module outputs:

* vpc id
* vpc subnet id
* vpc crn
* vpc default security group
