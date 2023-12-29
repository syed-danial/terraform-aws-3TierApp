variable "region" {
  type        = string
  description = "AWS Region"
}

variable "name" {
  type        = string
  description = "Author of code"
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(map(string))
}

variable "VPC" {
  description = "VPC Configuration"
  type = object({
    vpc_cidr               = string
    web_subnet_cidr_blocks = list(string)
    app_subnet_cidr_blocks = list(string)
    db_subnet_cidr_blocks  = list(string)
    create_nat_gateway     = bool
  })
  default = {
    vpc_cidr               = "10.0.0.0/16"
    web_subnet_cidr_blocks = ["10.0.0.0/24", "10.0.1.0/24"]
    app_subnet_cidr_blocks = ["10.0.2.0/24", "10.0.3.0/24"]
    db_subnet_cidr_blocks  = ["10.0.4.0/24", "10.0.5.0/24"]
    create_nat_gateway     = true
  }
}

variable "security_groups" {
  description = "Security Group Variable Configuration"
  type        = map(object({
    description     = string
    ingress_rules   = list(object({
      from_port       = number
      to_port         = number
      protocol        = string
    }))
  }))
}

variable "rds" {
  description = "RDS Configuration"
  type = object({
    db_name           = string
    db_masterpassword = string
    db_masterusername = string
  })
}

variable "key" {
  description = "AWS Key Configuration"
  type = object({
    public_key    = string
    key_pair_name = string
  })
}

variable "launch_config" {
  description = "Launch Template Configuration"
  type = object({
    instance_type = string
  })
}

variable "app_asg_config" {
  description = "Configuration for App SG"
  type = object({
    min_size         = number
    max_size         = number
    desired_capacity = number
  })
}

variable "web_asg_config" {
  description = "Configuration for Web SG"
  type = object({
    min_size         = number
    max_size         = number
    desired_capacity = number
  })
}

variable "secret_manager_info" {
  type = object({
    username_name = string
    password_name = string
  })
}

variable "listener_actions" {
  description = "A map of listener actions based on types"
  type        = map(object({
    type             = string
  }))
}


variable "alarms" {
  description = "A list of alarm configurations"
  type        = list(object({
    alarm_name          = string
    comparison_operator = string
    metric_name         = string
    period              = number
    evaluation_periods = number
    threshold           = number
    statistic           = string
    alarm_description   = string
    treat_missing_data  = string
    adjustment_type     = string
  }))
}

variable "auto_scaling_policies" {
  description = "A list of Auto Scaling policies to create"
  type        = map(object({
    name                 = string
    policy_type          = string
    scaling_adjustment   = number
    adjustment_type      = string
    bound = number
  }))
}

variable "alarm_policy_mapping" {
  description = "A mapping of alarm names to policy names."
  type        = map(string)
  default     = {}
}