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
}
output "loadbalancer_sg_id" {
    value = aws_security_group.loadbalancer.id
}

resource "aws_lb" "my_lb" {
    name                        = "my-lb"
    internal                    = false
    load_balancer_type          = "application"
    security_groups             = [aws_security_group.loadbalancer.id]
    subnets                     = aws_subnet.public_subnet.*.id
    enable_deletion_protection  = false
    tags = {
        Name = "my-lb"
    }
}

resource "aws_lb_target_group" "my_target_group" {
    name        = "my-target-group"
    port        = "8080"
    protocol    = "HTTP"
    vpc_id      = aws_vpc.my_vpc.id
    health_check {
        interval                = 300
        path                    = "/healthcheck"
        protocol                = "HTTP"
        timeout                 = 45
        healthy_threshold       = 3
        unhealthy_threshold     = 10
    }
}

resource "aws_lb_listener" "lblistner" {
    load_balancer_arn   = aws_lb.my_lb.arn
    port                = "80"
    protocol            = "HTTP"
    default_action {
        type = "forward"
        target_group_arn = aws_lb_target_group.my_target_group.arn
    }
}