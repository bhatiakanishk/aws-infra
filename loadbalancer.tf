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