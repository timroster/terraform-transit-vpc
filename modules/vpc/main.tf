resource "ibm_is_vpc" "this" {
  name                      = "${var.name}-vpc"
  resource_group            = var.resource_group_id
  address_prefix_management = "auto"
  tags                      = var.tags
}

resource "ibm_is_public_gateway" "this" {
  count = var.vpc_pgw ? 1 : 0
  name           = "${var.name}-pgw"
  resource_group = var.resource_group_id
  vpc            = ibm_is_vpc.this.id
  zone           = var.vpc_subnet_zone
  tags           = var.tags
}

resource "ibm_is_vpc_address_prefix" "this" {
  name           = "${var.name}-prefix"
  zone           = var.vpc_subnet_zone
  vpc            = ibm_is_vpc.this.id
  cidr           = var.vpc_subnet_address
}

# Create subnet without public gateway... there will only be 1
resource "ibm_is_subnet" "nopgw" {
  count = var.vpc_pgw ? 0 : 1
  depends_on      = [
    ibm_is_vpc_address_prefix.this
  ]
  name            = "${var.name}-subnet"
  resource_group  = var.resource_group_id
  ipv4_cidr_block = var.vpc_subnet_address
  vpc             = ibm_is_vpc.this.id
  zone            = var.vpc_subnet_zone
  tags            = var.tags
}

# Create subnet with public gateway... there will only be 1
resource "ibm_is_subnet" "withpgw" {
  count = var.vpc_pgw ? 1 : 0
  depends_on      = [
    ibm_is_vpc_address_prefix.this
  ]
  name            = "${var.name}-subnet"
  resource_group  = var.resource_group_id
  ipv4_cidr_block = var.vpc_subnet_address
  vpc             = ibm_is_vpc.this.id
  zone            = var.vpc_subnet_zone
  public_gateway  = ibm_is_public_gateway.this[0].id
  tags            = var.tags
}