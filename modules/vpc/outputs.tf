output "vpc_id" {
  description = "The id of the vpc that was created"
  value       = ibm_is_vpc.this.id
}

output "vpc_name" {
  description = "Name of the newly created VPC"
  value       = ibm_is_vpc.this.name
}

output "vpc_crn" {
  description = "CRN of the newly created VPC"
  value       = ibm_is_vpc.this.crn
}

output "vpc_default_sg" {
  description = "Default security group of the newly created VPC"
  value       = ibm_is_vpc.this.default_security_group
}

locals {
  subnet_this_id = var.vpc_pgw ? ibm_is_subnet.withpgw[0].id : ibm_is_subnet.nopgw[0].id
}

output "vpc_subnet_id" {
  description = "The id of the subnet that was created"
  value       = local.subnet_this_id
}