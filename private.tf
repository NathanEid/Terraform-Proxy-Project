module "private_subnet_01" {
  source = "./subnet"
  #resource_count = 1
  subnet_cidr_block = "10.0.1.0/24"
  sub_availability_zone = "us-east-1a"
  subnet_name = "private_subnet_01"
  sub_vpc_id = module.dev-vpc.vpc_id
}

module "private_subnet_02" {
  source = "./subnet"
  #resource_count = 1
  subnet_cidr_block = "10.0.3.0/24"
  sub_availability_zone = "us-east-1b"
  subnet_name = "private_subnet_02"
  sub_vpc_id = module.dev-vpc.vpc_id
}


module "private_route_table" {
  source = "./routetable"
  table_name = "private_table"
  table_vpc_id = module.dev-vpc.vpc_id
  table_destination_cidr_block = "0.0.0.0/0"
  table_gateway_id = module.nat_gateway.nat_gw_id
  table_subnet_id = {id1 = module.private_subnet_02.subnet_id, id2 = module.private_subnet_01.subnet_id }
}


module "ec2_private_02" {
  source = "./private_ec2"
  ec2_ami_id = "ami-06878d265978313ca"
  ec2_instance_type = "t2.micro"
  ec2_name = "ec2_private_02"
  ec2_subnet_ip = module.private_subnet_02.subnet_id
  ec2_security_gr = [ module.security_group.secgr_id ]
  ec2_key_name = "mykey"
  user_data = <<-EOF
    #!/bin/bash
    sudo apt update -y
    sudo apt install nginx -y
    sudo systemctl start nginx
    sudo systemctl enable nginx
    sudo chmod 777 /var/www/html
    sudo chmod 777 /var/www/html/index.nginx-debian.html
    sudo echo "<h1>Hello World! - Nathan from private EC2 01</h1>" > /var/www/html/index.nginx-debian.html
    sudo systemctl restart nginx
  EOF
}


module "ec2_private_01" {
  source = "./private_ec2"
  ec2_ami_id = "ami-06878d265978313ca"
  ec2_instance_type = "t2.micro"
  ec2_name = "ec2_private_01"
  ec2_subnet_ip = module.private_subnet_01.subnet_id
  ec2_security_gr = [ module.security_group.secgr_id ]
  ec2_key_name = "mykey"
  user_data = <<-EOF
    #!/bin/bash
    sudo apt update -y
    sudo apt install nginx -y
    sudo systemctl start nginx
    sudo systemctl enable nginx
    sudo chmod 777 /var/www/html
    sudo chmod 777 /var/www/html/index.nginx-debian.html
    sudo echo "<h1>Hello World! - Nathan from private EC2 02</h1>" > /var/www/html/index.nginx-debian.html
    sudo systemctl restart nginx
  EOF
}



module "lb_private" {
  source = "./loadbalncer"

  target_name = "private"
  target_port = "80"
  target_protocol = "HTTP"
  target_vpc_id = module.dev-vpc.vpc_id

  attach_target_id = { id1 = module.ec2_private_01.ec2_id, id2 = module.ec2_private_02.ec2_id }
  attach_target_port = "80"

  lb_name = "private"
  lb_internal = true
  lb_type = "application"
  lb_security_group = [ module.security_group.secgr_id ]
  lb_subnet = [ module.private_subnet_01, module.private_subnet_02 ]

  listener_port = "80"
  listener_protocol = "HTTP"
  listener_type = "forward"

  depends_on = [
    module.dev-vpc,
    module.ec2_private_01,
    module.ec2_private_02,
    module.private_subnet_01,
    module.private_subnet_02
  ]

}
