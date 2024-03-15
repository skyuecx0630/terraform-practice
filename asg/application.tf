data "aws_ami" "al2023_ami" {
  most_recent = true

  owners = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

module "alb" {
  source = "terraform-aws-modules/alb/aws"

  vpc_id = module.vpc.vpc_id
  name   = "${var.resource_name_tag_perfix}-alb"

  subnets               = module.vpc.public_subnets
  create_security_group = false
  security_groups       = [module.alb_sg.security_group_id]

  listeners = {
    http = {
      port     = 80
      protocol = "HTTP"

      forward = {
        arn = aws_lb_target_group.application_tg.arn
      }
    }
  }
}


resource "aws_lb_target_group" "application_tg" {
  vpc_id = module.vpc.vpc_id
  name   = "${var.resource_name_tag_perfix}-application-tg"

  target_type = "instance"
  protocol    = "HTTP"
  port        = 8080

  health_check {
    interval            = 5
    timeout             = 3
    healthy_threshold   = 5
    unhealthy_threshold = 2
    path                = "/health"
  }
  deregistration_delay = "30"
}


resource "aws_autoscaling_group" "application_asg" {
  name = "${var.resource_name_tag_perfix}-application-asg"

  vpc_zone_identifier = module.vpc.private_subnets

  target_group_arns = [aws_lb_target_group.application_tg.arn]

  launch_template {
    name    = aws_launch_template.application_launch_template.name
    version = aws_launch_template.application_launch_template.latest_version
  }

  min_size           = 2
  max_size           = 4
  desired_capacity   = 2
  capacity_rebalance = true
}


resource "aws_launch_template" "application_launch_template" {
  name = "${var.resource_name_tag_perfix}-application-lt"

  image_id  = data.aws_ami.al2023_ami.image_id
  user_data = filebase64("application/userdata.sh")

  instance_type = "t3.small"

  vpc_security_group_ids = [module.application_sg.security_group_id]
  monitoring {
    enabled = true
  }
}
