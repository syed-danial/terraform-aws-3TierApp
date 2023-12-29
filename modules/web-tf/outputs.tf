output "internetlb_info" {
    description = "Internet Load Balancer Info"
    value = {
        internet_lb_dns = aws_lb.internet_lb.dns_name
        internet_hosted_zone = aws_lb.internet_lb.zone_id
    }
}

output "web_asg_info" {
    description = "Web AutoScaling Group Info"
    value = {
        name = aws_autoscaling_group.web_asg.name
    }
}