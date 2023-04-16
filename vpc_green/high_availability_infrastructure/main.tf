resource "aws_launch_template" "lt" {
  name = "my-launch-template"
  image_id = var.ami_id
  instance_type = "t2.micro"

  vpc_security_group_ids = [var.security_group_id]
}

resource "aws_autoscaling_group" "asg" {
  name = "my-asg"
  desired_capacity = 3
  min_size = 2
  max_size = 3
  launch_template {
    id = aws_launch_template.lt.id
  }

  vpc_zone_identifier = var.subnets
}

resource "aws_lb" "alb" {
  name = "my-alb"
  internal = false
  load_balancer_type = "application"
  security_groups = [var.security_group_id]
  subnets = var.subnets
}

resource "aws_lb_target_group" "tg" {
  name = "my-tg"
  port = 80
  protocol = "HTTP"
  vpc_id = var.vpc_id
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port = 80
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.asg.id
  alb_target_group_arn = aws_lb_target_group.tg.arn
}
