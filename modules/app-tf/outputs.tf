output "ilb_info" {
    description = "Internal Load Balancer Info"
    value = {
        internal_lb_dns = aws_lb.internal_lb.dns_name
    }
}

output "app_asg_info" {
    description = "Internal Load Balancer Info"
    value = {
        name = aws_autoscaling_group.app_asg.name
    }
}