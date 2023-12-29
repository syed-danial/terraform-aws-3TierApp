region = "us-west-2"
name = "danial"

tags = {
  VPC = {
    cidr_block = "10.0.0.0/16"
  }

  security_groups = {
    name = "sg-id"
  }

  rds = {
    resource = "rds-cluster"
    engine = "aurora-mysql"
    multi-az  = "true"
    number_of_subnets = "2"
    subnet_cidr_block = "10.0.4.0/24, 10.0.5.0/24"
  }

  app = {
    subnet_cidr_block = "10.0.2.0/24, 10.0.3.0/24"
    template = "amazon-linux2"
    vpc_cidr = "10.0.0.0/16"
    number_of_subnets = "2"
    key_pair = "terraform-danial"
  }

  web = {
    subnet_cidr_block = "10.0.0.0/24, 10.0.1.0/24"
    template = "amazon-linux2"
    vpc_cidr = "10.0.0.0/16"
    number_of_subnets = "2"
    key_pair = "terraform-danial"
  }

  alarms = {
    threshold = 50
    metric = "CPUUtilization"
    adjustmentType = "Change in Capacity"
  }
}

VPC = {
  vpc_cidr               = "10.0.0.0/16"
  web_subnet_cidr_blocks = ["10.0.0.0/24", "10.0.1.0/24"]
  app_subnet_cidr_blocks = ["10.0.2.0/24", "10.0.3.0/24"]
  db_subnet_cidr_blocks  = ["10.0.4.0/24", "10.0.5.0/24"]
  create_nat_gateway     = true
}

rds = {
  db_name           = "test"
  db_masterusername = "admin"
  db_masterpassword = "adminadmin"
}

key = {
  public_key    = "terraform-danial.pub"
  key_pair_name = "terraform-danial"
}

launch_config = {
  instance_type = "t2.micro"
}

app_asg_config = {
  min_size         = 1
  max_size         = 1
  desired_capacity = 1
}

web_asg_config = {
  min_size         = 1
  max_size         = 4
  desired_capacity = 2
}

secret_manager_info = {
  username_name = "danial/3tier/username"
  password_name = "danial/3tier/password"
}

security_groups = {
  web_lb_sg = {
    description = "Web LB Security Group"
    ingress_rules = [
      {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
      },
    ]
  },
  web_sg = {
    description = "Web Security Group"
    ingress_rules = [
      {
        from_port = 22
        to_port = 22
        protocol = "tcp"
      },
      {
        from_port = 80
        to_port = 80
        protocol = "tcp"
      }
    ]
  },
  app_lb_sg = {
    description = "App LB Security Group"
    ingress_rules = [
      {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
      },
    ]
  }, 
  app_sg = {
    description = "App Security Group"
    ingress_rules = [
      {
        from_port = 4000
        to_port = 4000
        protocol = "tcp"
      },
      {
        from_port = 22
        to_port = 22
        protocol = "tcp"
      }
    ]
  },
  db_sg = {
    description = "DB security group"
    ingress_rules = [
      {
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
      }
    ]
  }
}

listener_actions = {
  forward_action = {
    type             = "forward"
  }
  fixed_response_action = {
    type = "fixed-response"
  }
  redirect = {
    type = "redirect"
  }
}

alarms = [
  {
    alarm_name          = "scale_out_alarm"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    metric_name         = "CPUUtilization"
    period              = 60
    evaluation_periods = 1
    threshold           = 50
    statistic           = "Minimum"
    alarm_description   = "Alarm for scaling out instances"
    treat_missing_data  = "notBreaching"
    adjustment_type     = "ChangeInCapacity"
  },
  {
    alarm_name          = "scale_in_alarm"
    comparison_operator = "LessThanOrEqualToThreshold"
    metric_name         = "CPUUtilization"
    period              = 60
    evaluation_periods = 1
    threshold           = 50
    statistic           = "Minimum"
    alarm_description   = "Alarm for scaling in instances"
    treat_missing_data  = "notBreaching"
    adjustment_type     = "ChangeInCapacity"
  }
]

auto_scaling_policies = {
  scale_out_policy = {
    name                 = "scaling_out_policy"
    policy_type          = "StepScaling"
    scaling_adjustment   = 1
    adjustment_type      = "ChangeInCapacity"
    bound = 0
  },
  scale_in_policy = {
    name                 = "scaling_in_policy"
    policy_type          = "StepScaling"
    scaling_adjustment   = -1
    adjustment_type      = "ChangeInCapacity"
    bound = 0
  }
}

alarm_policy_mapping = {
  "scale_out_alarm" = "scaling_out_policy"
  "scale_in_alarm"  = "scaling_in_policy"
}