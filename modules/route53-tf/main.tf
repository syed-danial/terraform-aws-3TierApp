data "aws_route53_zone" "domain" {
  name = "groveops.net"
  private_zone = false
}

resource "aws_route53_record" "subdomain" {
  zone_id = data.aws_route53_zone.domain.zone_id
  name    = "danial.groveops.net"  
  type    = "A"
  alias {
    name                   = var.lb_info.internet_lb_name 
    zone_id                = var.lb_info.internet_lb_zone  
    evaluate_target_health = true
  }
}