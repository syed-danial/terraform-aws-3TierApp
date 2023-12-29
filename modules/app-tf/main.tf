resource "aws_key_pair" "main" {
    key_name = var.key.key_pair_name
    public_key = file("${path.module}/scripts/${var.key.public_key}")
    tags = merge("${var.tags}",{environment = "${terraform.workspace}"}, {Name = "${var.name}-public_key"})
}

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

resource "aws_iam_policy" "secrets_manager_policy" {
  name        = "SecretsManagerPolicy"
  description = "IAM policy to allow access to Secrets Manager"
  policy = file("${path.module}/scripts/secret_manager_policy.json")
}

resource "aws_iam_role" "ec2_role" {
  name = "app_ec2_role"
  assume_role_policy = file("${path.module}/scripts/assume_role_policy.json")
}

resource "aws_iam_policy_attachment" "ssm_read_permissions" {
  name       = "SecretManagersAttachment"
  policy_arn = aws_iam_policy.secrets_manager_policy.arn
  roles      = [aws_iam_role.ec2_role.name]
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "app_ec2_profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_launch_template" "apptemplate" {
    name = "apptemplate-terraform"
    image_id = data.aws_ami.latest_amzn2.id
    instance_type = var.launch_config.instance_type
    key_name = aws_key_pair.main.key_name
    vpc_security_group_ids = [var.exported.app_security_group]
    iam_instance_profile { name = aws_iam_instance_profile.ec2_profile.name }
    user_data =base64encode(templatefile("${path.module}/scripts/app_script.sh", {
        rds_writer_endpoint = var.exported.writer_endpoint,
        database_name = var.exported.db_name
        region = var.region
        secret_username = var.secret_manager_info.username_secret_name
        secret_password = var.secret_manager_info.password_secret_name
    }))
    tags = merge("${var.tags}",{environment = "${terraform.workspace}"}, {Name = "${var.name}-app_template"})
}

resource "aws_lb_target_group" "apptargetgroup" {
  name = "AppLBtargetGroup-tf"
  port = 4000
  protocol = "HTTP"
  vpc_id = var.exported.vpc_id
  target_type = "instance"
  health_check {
    path = "/health"
    port = 80
    protocol = "HTTP"
  }
  tags = merge("${var.tags}",{environment = "${terraform.workspace}"}, {Name = "${var.name}-app_target_group"})
}

resource "aws_lb" "internal_lb" {
  name = "InternalLB-tf"
  subnets = var.exported.app_subnet_group
  security_groups = [var.exported.app_lb_security_group]
  internal = true
  tags = merge("${var.tags}",{environment = "${terraform.workspace}"}, {Name = "${var.name}-app_LB"})
} 

resource "aws_lb_listener" "app_lb_listener" {
  load_balancer_arn = aws_lb.internal_lb.arn
  port = 80
  protocol = "HTTP"
  dynamic "default_action" {
    for_each = var.listener_actions
    content {
      type             = default_action.value.type
      target_group_arn = aws_lb_target_group.apptargetgroup.arn
    }
  }
}

resource "aws_autoscaling_group" "app_asg" {
  name = "app_asg-tf"
  min_size = var.app_asg_config.min_size
  max_size = var.app_asg_config.max_size
  desired_capacity = var.app_asg_config.desired_capacity
  vpc_zone_identifier = var.exported.app_subnet_group
  target_group_arns = [aws_lb_target_group.apptargetgroup.arn]
  launch_template {
    id = aws_launch_template.apptemplate.id
  }

  tag {
    key   = "Name"
    value = "${var.name}-app_ilb"
    propagate_at_launch = true
  }

  tag {
    key   = "defuse"
    value = var.tags.defuse
    propagate_at_launch = true
  }

  tag {
    key   = "environment"
    value = terraform.workspace
    propagate_at_launch = true
  }
}