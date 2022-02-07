provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region = var.region
}

# Identify target resource group
data "ibm_resource_group" "byname" {
  count = var.resource_group_name != null ? 1 : 0 
  name = var.resource_group_name
}

data "ibm_resource_group" "default" {
  is_default = "true"
}

locals {
  resource_group_id = var.resource_group_name != null ? data.ibm_resource_group.byname[0].id : data.ibm_resource_group.default.id
  basename = "${var.project}-${var.environment}"
}


## Define transit VPC
module "transit-vpc" {
  source = "./modules/vpc"
 
  name               = "${local.basename}-hub"
  vpc_pgw            = true
  tags               = var.tags
  resource_group_id  = local.resource_group_id
  vpc_subnet_address = cidrsubnet(var.vpc_subnet_range, 6, 0)
  vpc_subnet_zone    = var.zone

}


## Add ZeroTier VNF to Transit VPC
locals {
  vpc_subnets = [ {
    label = "hub"
    id    = module.transit-vpc.vpc_subnet_id
    zone  = var.zone
  } ]
}

data "ibm_is_ssh_key" "existing" {
  name = var.ssh_key_name
}

module "zerotier-vnf" {
  source = "github.com/timroster/terraform-vsi-zerotier-edge"

  resource_group_id   = local.resource_group_id
  region              = var.region
  ibmcloud_api_key    = var.ibmcloud_api_key
  ssh_key_id          = data.ibm_is_ssh_key.existing.id
  vpc_name            = module.transit-vpc.vpc_name
  vpc_subnet_count    = 1
  vpc_subnets         = local.vpc_subnets
  zt_network          = var.zt_network
  tags                = var.tags
}

output "private_ip_address" {
  value = module.zerotier-vnf.private_ips
}

output "zerotier_network_cidr" {
  description = "ZeroTier LAN address"
  value       = module.zerotier-vnf.zerotier_network_cidr
}

## Define spoke VPC
module "spoke-vpc" {
  depends_on      = [
    module.zerotier-vnf.private_ips
  ]
  source = "./modules/vpc"
  count = var.spoke_vpc_count
 
  name               = "${local.basename}-spoke${format("%02s", count.index)}"
  vpc_pgw            = false
  tags               = var.tags
  resource_group_id  = local.resource_group_id
  vpc_subnet_address = cidrsubnet(var.vpc_subnet_range, 6, (count.index+1))
  vpc_subnet_zone    = var.zone

}


## Create VPC custom routes in spokes
data "ibm_is_vpc_default_routing_table" "spoke_vpc_route" {
  count = var.spoke_vpc_count
  vpc = module.spoke-vpc[count.index].vpc_id
}

# add route to ZeroTier network through VNF
resource "ibm_is_vpc_routing_table_route" "zt_ibm_is_vpc_routing_table_route" {
  count = var.spoke_vpc_count

  vpc           = module.spoke-vpc[count.index].vpc_id
  routing_table = data.ibm_is_vpc_default_routing_table.spoke_vpc_route[count.index].id
  zone          = var.zone
  name          = "${local.basename}-spoke${format("%02s", count.index)}-ztgw"
  destination   = module.zerotier-vnf.zerotier_network_cidr[0]
  action        = "deliver"
  next_hop      = module.zerotier-vnf.private_ips[0]
}

# add ZeroTier network to spoke VPC default SG
resource ibm_is_security_group_rule zerotier_rule {
  count = var.spoke_vpc_count
  
  group     = module.spoke-vpc[count.index].vpc_default_sg
  direction = "inbound"
  remote    = module.zerotier-vnf.zerotier_network_cidr[0]
}

# add VPC network range to spoke VPC default SG
resource ibm_is_security_group_rule vpc_subnet_range {
  count = var.spoke_vpc_count
  
  group     = module.spoke-vpc[count.index].vpc_default_sg
  direction = "inbound"
  remote    = var.vpc_subnet_range
}

# TEST - add TimRo source IP to spoke VPC default SG
resource ibm_is_security_group_rule test_access {
  count = var.spoke_vpc_count
  
  group     = module.spoke-vpc[count.index].vpc_default_sg
  direction = "inbound"
  remote    = "76.21.108.221"
}

## Add VSI to spoke VPC
module "spoke-vsi" {
  depends_on      = [
    module.spoke-vpc.vpc_id
  ]
  source = "./modules/vsi"
  count = var.spoke_vpc_count
 
  name               = "${local.basename}-spoke${format("%02s", count.index)}"
  tags               = var.tags
  resource_group_id  = local.resource_group_id
  ssh_key_id         = data.ibm_is_ssh_key.existing.id
  vpc_id             = module.spoke-vpc[count.index].vpc_id
  vpc_subnet_id      = module.spoke-vpc[count.index].vpc_subnet_id
  vpc_subnet_zone    = var.zone
}


## Create Transit Gateway and link all VPCs to it
locals {
  all_vpc_crn = concat( [ module.transit-vpc.vpc_crn ], module.spoke-vpc[*].vpc_crn )
}

resource "ibm_tg_gateway" "hub_to_spoke"{
  name               = "${local.basename}-tgw"
  global             = false
  location           = var.region
  resource_group     = local.resource_group_id
  tags               = var.tags
} 

resource "ibm_tg_connection" "vpc" {
  count        = length(local.all_vpc_crn)

  gateway      = ibm_tg_gateway.hub_to_spoke.id
  network_type = "vpc"
  name         = "${local.basename}-vpc${format("%02s", count.index)}-conn"
  network_id   = local.all_vpc_crn[count.index]
}