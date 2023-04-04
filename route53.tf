variable "zone_name" {
  default = "dev.kanishkbhatia.me"
}

data "aws_route53_zone" "selected" {
  name         = var.zone_name
  private_zone = false
}

// Creates a DNS A record in Route 53 for the EC2 instance's public IP

resource "aws_route53_record" "root" {
  zone_id   = data.aws_route53_zone.selected.zone_id
  name      = data.aws_route53_zone.selected.name
  type      = "A"
  # ttl       = "300"
  count     = 1
  # records = [aws_instance.my_ec2_instance[0].public_ip]
  alias {
    name                    = aws_lb.my_lb.dns_name
    zone_id                 = aws_lb.my_lb.zone_id
    evaluate_target_health  = true
  }
}