resource "aws_security_group" "security_groups" {
    for_each = var.security_groups

    name_prefix = each.key
    description = each.value.description
    vpc_id      = var.vpc_info.vpc_id

    dynamic ingress {
        for_each = each.value.ingress_rules
        content {
            from_port       = ingress.value.from_port
            to_port         = ingress.value.to_port
            protocol        = ingress.value.protocol
            cidr_blocks = each.key == "web_sg" ? ["0.0.0.0/0", var.vpc_info.vpc_cidr] : each.key == "web_lb_sg" ? ["0.0.0.0/0"] : [var.vpc_info.vpc_cidr]
        }
    }

    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }

    tags = merge("${var.tags}",{environment = "${terraform.workspace}"}, {Name = "${var.name}-${each.key}_security_group"})
}