# Required variables
variable "project" {
  type        = string
  description = "The project name for all instances"
}

variable "zt_network" {
  type = string

  validation {
    condition     = length(var.zt_network) == 16
    error_message = "The zt_network id must be be 16 characters long."
  }
}

variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud api token"
}

variable "ssh_key_name" {
  type        = string
  description = "Name of existing SSH key ID to inject into the virtual server instance"
}

# Optional variables
variable "spoke_vpc_count" {
  type        = number
  description = "Number of spoke VPC to create and connect to the transit network"
  default     = 1
}

variable "spoke_vpc_pgw" {
  type        = bool
  description = "Flag to add a public gateway for each spoke VPC"
  default     = false   
}

variable "tags" {
  type        = list(string)
  description = "Tags that should be added to the instance"
  default     = []
}

variable "resource_group_name" {
  type        = string
  description = "The id of the IBM Cloud resource group where the VPC has been provisioned."
  default     = null
}

variable "region" {
  type        = string
  description = "The IBM Cloud region where the cluster will be/has been installed."
  default     = "us-south"
}

variable "zone" {
  type        = string
  description = "The IBM Cloud VPC zone where resources will be created, will change with multi-zone impl"
  default     = "us-south-2"
}

variable "environment" {
  type        = string
  description = "The environment name for all instances"
  default     = "vpc"
}

variable "vpc_subnet_range" {
  type        = string
  description = "The network block(s) to use for VPC subnets"
  default     = "172.20.64.0/18"
}