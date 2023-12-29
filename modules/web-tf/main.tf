data "aws_ami" "latest_amzn2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

resource "aws_lb_target_group" "webtargetgroup" {
  name = "WebLBtargetGroup-tf"
  port = 80
  protocol = "HTTP"
  vpc_id = var.web_exported.vpc_id
  target_type = "instance"
  health_check {
    path = "/health"
    port = 80
    protocol = "HTTP"
    timeout = 60
    interval = 61
  }
  tags = merge("${var.tags}",{environment = "${terraform.workspace}"}, {Name = "${var.name}-web_target_group"})
}

resource "aws_lb" "internet_lb" {
  name = "InternetLB-tf"
  subnets = var.web_exported.web_subnet_group
  security_groups = [var.web_exported.web_lb_security_group]
  tags = merge("${var.tags}",{environment = "${terraform.workspace}"}, {Name = "${var.name}-web_lb"})
} 

resource "aws_lb_listener" "web_lb_listener" {
  load_balancer_arn = aws_lb.internet_lb.arn
  port = 80
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.webtargetgroup.arn
  }
}


resource "aws_launch_template" "webtemplate" {
    name = "web-template-terraform"
    image_id = data.aws_ami.latest_amzn2.id
    instance_type = var.launch_config.instance_type
    key_name = var.key.key_pair_name
    vpc_security_group_ids = [var.web_exported.web_security_group]
    user_data =base64encode(templatefile("${path.module}/scripts/web_script.sh", {
        internal_lb_dns = var.web_exported.app_internal_loadbalancer_dns
    }))
    network_interfaces{
        associate_public_ip_address = true
        security_groups = [var.web_exported.web_security_group]
    }
    tags = merge("${var.tags}",{environment = "${terraform.workspace}"}, {Name = "${var.name}-web_launch_template"})
}

resource "aws_autoscaling_group" "web_asg" {
  name = "web_asg-tf"
  min_size = var.web_asg_config.min_size
  max_size = var.web_asg_config.max_size
  desired_capacity = var.web_asg_config.desired_capacity
  vpc_zone_identifier = var.web_exported.web_subnet_group
  target_group_arns = [aws_lb_target_group.webtargetgroup.arn]
  launch_template {
    id = aws_launch_template.webtemplate.id
    version = aws_launch_template.webtemplate.latest_version
  }

  tag {
    key   = "Name"
    value = "${var.name}-web_asg"
    propagate_at_launch = true
  }

  tag {
    key   = "defuse"
    value = var.tags["defuse"]
    propagate_at_launch = true
  }

  tag {
    key   = "environment"
    value = terraform.workspace
    propagate_at_launch = true
  }
}


