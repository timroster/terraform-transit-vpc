# Required variables
variable "name" {
  type        = string
  description = "The base name for resources created by the module"
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

variable "image_name" {
  type        = string
  description = "The name of the image to use for the virtual server"
  default     = "ibm-rocky-linux-8-5-minimal-amd64-1"
}

variable "profile_name" {
  type        = string
  description = "Instance profile to use for the zerotier instance"
  default     = "cx2-2x4"
}

variable "ssh_key_id" {
  type        = string
  description = "Existing SSH key ID to inject into the virtual server instance"
}

variable "vpc_id" {
  type        = string
  description = "The VPC to use for the VSI"
}

variable "vpc_subnet_id" {
  type        = string
  description = "The subnet id to use for the VSI"
}

variable "vpc_subnet_zone" {
  type        = string
  description = "The zone to use for the VSI"
}