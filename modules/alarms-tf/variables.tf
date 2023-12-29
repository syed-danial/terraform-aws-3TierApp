variable "tags" {
  description = "Tags to identify ENV and prevent them from being nuked"
  type        = map(string)
}

variable "web_asg_info" {
  description = "Web ASG info"
  type = object({
    web_asg_name = string
  })
}

variable "name" {
  type        = string
  description = "Author Name"
}

variable "alarms" {
  description = "A list of alarm configurations"
  type = list(object({
    alarm_name          = string
    comparison_operator = string
    metric_name         = string
    period              = number
    evaluation_periods  = number
    threshold           = number
    statistic           = string
    alarm_description   = string
    treat_missing_data  = string
    adjustment_type     = string
  }))
}

variable "auto_scaling_policies" {
  description = "A list of Auto Scaling policies to create"
  type = map(object({
    name                   = string
    policy_type            = string
    scaling_adjustment     = number
    adjustment_type        = string
    bound                  = number
  }))
}

variable "alarm_policy_mapping" {
  description = "A mapping of alarm names to policy names."
  type        = map(string)
  default     = {}
}