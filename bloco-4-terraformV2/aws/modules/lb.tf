resource "aws_lb" "app_lb" {
    name = "app-lb"
    internal = false
    load_balancer_type = "application"
    security_groups = [aws_security_group.security_group_web-ssh.id]
    subnets = [
        aws_subnet.subnet_app.id,
        aws_subnet.subnet_app2.id
    ]
}

resource "aws_lb_target_group" "app_target" {
    name = "app-target"
    port = 80
    protocol = "HTTP"
    vpc_id = aws_vpc.vpc_app.id
    
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
  count            = length(aws_instance.example)
  target_group_arn = aws_lb_target_group.app_target.arn
  target_id        = aws_instance.example[count.index].id
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

