module "dev-vpc" {
  source = "./vpc"
  vpc_cider = "10.0.0.0/16"
  vpc_name = "dev-vpc"
}

module "internet_gateway" {
  source = "./internetgateway"
  internet_gw_name = "my_internet_gateway"
  internet_vpc_id = module.dev-vpc.vpc_id
}

module "nat_gateway" {
  source = "./natgateway"
  nat_name = "my_nat_gateway"
  nat_subnet_id = module.public_subnet_01.subnet_id
  nat_depends_on = module.internet_gateway
}

module "security_group" {
  source = "./securitygroup"
  secgr_name = "security_group"
  secgr_description = "security_group"
  secgr_vpc_id = module.dev-vpc.vpc_id
  secgr_from_port_in = 22
  secgr_to_port_in = 80
  secgr_protocol_in = "tcp"
  secgr_cider = ["0.0.0.0/0"]
  secgr_from_port_eg = 0
  secgr_to_port_eg = 0
  secgr_protocol_eg = "-1"
}


