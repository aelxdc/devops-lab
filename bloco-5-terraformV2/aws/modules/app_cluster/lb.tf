resource "aws_lb" "app_lb" {
  name               = "${var.name_instance}-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.security_group_web_ssh.id]
  subnets            = var.subnets
}

resource "aws_lb_target_group" "app_target" {
  name     = "${var.name_instance}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group_attachment" "instance_app" {
  count            = length(aws_instance.ec2create)
  target_group_arn = aws_lb_target_group.app_target.arn
  target_id        = aws_instance.ec2create[count.index].id
  port             = 80
}

resource "aws_lb_listener" "web_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_target.arn
  }
}