variable "zone_name" {
  default = "dev.kanishkbhatia.me"
}

data "aws_route53_zone" "selected" {
  name         = var.zone_name
  private_zone = false
}

// # Creates a Route53 A record for the root domain using an ALB alias

resource "aws_route53_record" "root" {
  zone_id   = data.aws_route53_zone.selected.zone_id
  name      = data.aws_route53_zone.selected.name
  count     = 1
  alias {
    name                    = aws_lb.my_lb.dns_name
    zone_id                 = aws_lb.my_lb.zone_id
    evaluate_target_health  = true
  }
}