variable region {
  type = string
}

variable "tags" {
  description = "Tags to identify ENV and prevent them from being nuked"
  type        = map(string)
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

variable "exported" {
  description = "Inherited from other modules"
  type = object({
    app_security_group = string
    app_lb_security_group = string
    writer_endpoint = string
    db_name = string
    app_subnet_group = list(string)
    vpc_id = string
  }) 
}

variable "app_asg_config" {
  description = "Configuration for App SG"
  type = object({
    min_size = number
    max_size = number
    desired_capacity = number
  })
}

variable "name" {
  type        = string
  description = "Author Name"
}

variable "secret_manager_info" {
  type = object({
    username_secret_name = string
    password_secret_name = string
  })
}

variable "listener_actions" {
  description = "A map of listener actions based on types"
  type        = map(object({
    type             = string
  }))
}