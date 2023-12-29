output "SG_ids" {
    description = "Security Group Ids"
    value  = {
        web_lb_sg_id = aws_security_group.security_groups["web_lb_sg"].id
        web_sg_id = aws_security_group.security_groups["web_sg"].id
        app_lb_sg_id = aws_security_group.security_groups["app_lb_sg"].id
        app_sg_id = aws_security_group.security_groups["app_sg"].id
        db_sg_id = aws_security_group.security_groups["db_sg"].id
    }
}