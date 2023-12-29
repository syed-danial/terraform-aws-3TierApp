variable "web_asg_config" {
  description = "Configuration for Web SG"
  type = object({
    min_size = number
    max_size = number
    desired_capacity = number
  })
}

variable "key" {
  description = "AWS Key Configuration"
  type = object({
    public_key    = string
    key_pair_name = string
  })
}

variable "tags" {
  description = "Tags to identify ENV and prevent them from being nuked"
  type        = map(string)
}

variable "name" {
  type        = string
  description = "Author Name"
}

variable "web_exported" {
    description = "Exported variables from different modules"
    type = object({
        vpc_id = string
        web_security_group = string
        web_lb_security_group = string
        web_subnet_group = list(string)
        app_internal_loadbalancer_dns = string
    })
}

variable "launch_config" {
  description = "Launch Template Configuration"
  type = object({
    instance_type = string
  })
}