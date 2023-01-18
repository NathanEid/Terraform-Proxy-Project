module "public_subnet_01" {
  source = "./subnet"
  #resource_count = 1
  subnet_cidr_block = "10.0.0.0/24"
  sub_availability_zone = "us-east-1a"
  subnet_name = "public_subnet_01"
  sub_vpc_id = module.dev-vpc.vpc_id
}

module "public_subnet_02" {
  source = "./subnet"
  #resource_count = 1
  subnet_cidr_block = "10.0.2.0/24"
  sub_availability_zone = "us-east-1b"
  subnet_name = "public_subnet_02"
  sub_vpc_id = module.dev-vpc.vpc_id
}


module "public_route_table" {
  source = "./routetable"
  table_name = "public_table"
  table_vpc_id = module.dev-vpc.vpc_id
  table_destination_cidr_block = "0.0.0.0/0"
  table_gateway_id = module.internet_gateway.internet_gw_id
  table_subnet_id = { id1 = module.public_subnet_02.subnet_id, id2 = module.public_subnet_01.subnet_id }
  depends_on = [
    module.public_subnet_01.subnet_id,
    module.private_subnet_02.subnet_id
  ]
}


module "ec2_public_01" {
  source = "./ec2"
  ec2_ami_id = "ami-06878d265978313ca"
  ec2_instance_type = "t2.micro"
  ec2_name = "ec2_public_01"
  ec2_public_ip = true
  ec2_subnet_ip = module.public_subnet_01.subnet_id
  ec2_security_gr = [ module.security_group.secgr_id ]
  ec2_key_name = "mykey"
  ec2_connection_type = "ssh"
  ec2_connection_user = "ubuntu"
  ec2_connection_private_key = "./mykey.pem"
  ec2_provisioner_file_source = "./nginx.sh"
  ec2_provisioner_file_destination = "/tmp/nginx.sh"
  ec2_provisioner_inline = [ "chmod 777 /tmp/nginx.sh", "/tmp/nginx.sh ${module.lb_private.lb_public_dns}" ]
  depends_on = [
    module.public_subnet_01.subnet_id,
    module.public_route_table.route_table_id,
    module.lb_private.lb_public_dns
  ]
}

module "ec2_public_02" {
  source = "./ec2"
  ec2_ami_id = "ami-06878d265978313ca"
  ec2_instance_type = "t2.micro"
  ec2_name = "ec2_public_02"
  ec2_public_ip = true
  ec2_subnet_ip = module.public_subnet_02.subnet_id
  ec2_security_gr = [ module.security_group.secgr_id ]
  ec2_key_name = "mykey"
  ec2_connection_type = "ssh"
  ec2_connection_user = "ubuntu"
  ec2_connection_private_key = "./mykey.pem"
  ec2_provisioner_file_source = "./nginx.sh"
  ec2_provisioner_file_destination = "/tmp/nginx.sh"
  ec2_provisioner_inline = [ "chmod 777 /tmp/nginx.sh", "/tmp/nginx.sh ${module.lb_private.lb_public_dns}" ]
  depends_on = [
    module.public_subnet_02.subnet_id,
    module.public_route_table.route_table_id,
    module.lb_private.lb_public_dns
  ]
}

module "lb_public" {
  source = "./loadbalncer"

  target_name = "public"
  target_port = "80"
  target_protocol = "HTTP"
  target_vpc_id = module.dev-vpc.vpc_id

  attach_target_id = { id1 = module.ec2_public_01.ec2_id, id2 = module.ec2_public_02.ec2_id }
  attach_target_port = "80"

  lb_name = "public"
  lb_internal = false
  lb_type = "application"
  lb_security_group = [ module.security_group.secgr_id ]
  lb_subnet = [ module.public_subnet_01, module.public_subnet_02 ]

  listener_port = "80"
  listener_protocol = "HTTP"
  listener_type = "forward"

  depends_on = [
    module.dev-vpc,
    module.ec2_public_01,
    module.ec2_public_02,
    module.public_subnet_01,
    module.public_subnet_02
  ]

}

