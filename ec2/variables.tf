variable "ec2_ami_id" {
}

variable "ec2_instance_type" {
}

variable "ec2_public_ip" {
}

variable "ec2_subnet_ip" {
}

variable "ec2_security_gr" {
}

# variable "user_data" {
#   default = <<-EOF
#   #!/bin/bash
#   echo "*** Installing apache2"
#   sudo apt update -y
#   sudo apt install apache2 -y
#   echo "*** Completed Installing apache2"
#   EOF
# }

variable "ec2_name" {
}

variable "ec2_key_name" {
}

variable "ec2_connection_type" {
}

variable "ec2_connection_user" {
}

# variable "ec2_connection_host" {
# }

variable "ec2_connection_private_key" {
}

variable "ec2_provisioner_file_source" {
}

variable "ec2_provisioner_file_destination" {
}

variable "ec2_provisioner_inline" {
}