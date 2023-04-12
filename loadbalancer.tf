// Load Balancer Security Group

resource "aws_security_group" "loadbalancer" {
  name        = "loadbalancer"
  description = "Security group for the load balancer to access the web application"
  vpc_id      = aws_vpc.my_vpc.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
output "loadbalancer_sg_id" {
  value = aws_security_group.loadbalancer.id
}

// Load Balancer

resource "aws_lb" "my_lb" {
  name                       = "my-lb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.loadbalancer.id]
  subnets                    = [for subnet in aws_subnet.public_subnet : subnet.id]
  enable_deletion_protection = false
  tags = {
    Name = "my-lb"
  }
}

// Load Balancer Target Group

resource "aws_lb_target_group" "my_target_group" {
  name     = "my-target-group"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_vpc.id
  health_check {
    interval            = 60
    path                = "/healthcheck"
    protocol            = "HTTP"
    port                = 8080
    timeout             = 45
    healthy_threshold   = 3
    unhealthy_threshold = 5
    matcher             = 200
  }
}

// Load Balancer Listener to forward from port 443 (HTTPS support)

variable "certificate_id" {
  default = "arn:aws:acm:us-east-1:936367200970:certificate/6f07e9d8-89e7-4935-8873-f40cc5513c3c"
}

resource "aws_lb_listener" "lblistener" {
  load_balancer_arn = aws_lb.my_lb.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = var.certificate_id
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_target_group.arn
  }
}