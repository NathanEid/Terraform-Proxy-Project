resource "aws_lb_target_group" "ec2_target" {
  name     = var.target_name # "tf-example-lb-tg"
  port     = var.target_port # 80
  protocol = var.target_protocol # "HTTP"
  vpc_id   = var.target_vpc_id # aws_vpc.main.id
}

resource "aws_lb_target_group_attachment" "ec2_targr_attach" {
  target_group_arn = aws_lb_target_group.ec2_target.arn
  for_each = var.attach_target_id
  target_id        = each.value #aws_instance.test.id
  port             = var.attach_target_port #80
  depends_on = [
    aws_lb_target_group.ec2_target
  ]
}

resource "aws_lb" "app_lb" {
  name               = var.lb_name # "test-lb-tf"
  internal           = var.lb_internal # false
  load_balancer_type = var.lb_type # "application"
  security_groups    = var.lb_security_group #[aws_security_group.lb_sg.id]
  #for_each = var.lb_subnet
  subnets            = [for subnet in var.lb_subnet : subnet.subnet_id]
  tags = {
    Name = var.lb_name # "production"
  }
}

resource "aws_lb_listener" "listener_app_tar" {
  load_balancer_arn = aws_lb.app_lb.arn # aws_lb.front_end.arn
  port              = var.listener_port # "80"
  protocol          = var.listener_protocol # "HTTP"
  default_action {
    type             = var.listener_type #"forward"
    target_group_arn = aws_lb_target_group.ec2_target.arn #aws_lb_target_group.front_end.arn
  }
  depends_on = [
    aws_lb.app_lb,
    aws_lb_target_group.ec2_target
  ]
}