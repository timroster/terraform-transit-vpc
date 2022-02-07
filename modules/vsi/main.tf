data ibm_is_image image {
  name = var.image_name
}

resource "ibm_is_instance" "this" {
  name           = "${var.name}-vsi"
  image          = data.ibm_is_image.image.id
  profile        = var.profile_name
  resource_group = var.resource_group_id

  primary_network_interface {
    name   = "eth0"
    subnet = var.vpc_subnet_id
    allow_ip_spoofing = false
  }

  vpc  = var.vpc_id
  zone = var.vpc_subnet_zone
  keys = tolist(setsubtract([var.ssh_key_id], [""]))
  tags = var.tags

  //VPC VSI timeouts
  timeouts {
    create = "15m"
    update = "15m"
    delete = "15m"
  }
}