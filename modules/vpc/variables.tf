# Required variables
variable "name" {
  type        = string
  description = "The base name for resources created by the module"
}

variable "vpc_pgw" {
  type        = bool
  description = "Flag to add a public gateway for this VPC"
  default     = false   
}

variable "tags" {
  type        = list(string)
  description = "Tags that should be added to the resources"
  default     = []
}

variable "resource_group_id" {
  type        = string
  description = "The id of the IBM Cloud resource group where the VPC will be provisioned."
}

variable "vpc_subnet_address" {
  type        = string
  description = "The network to use for VPC prefix and subnet"
}

variable "vpc_subnet_zone" {
  type        = string
  description = "The zone to use for VPC subnet"
}