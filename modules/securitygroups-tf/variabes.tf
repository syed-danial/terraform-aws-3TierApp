variable "tags" {
  description = "Tags to identify ENV and prevent them from being nuked"
  type        = map(string)
}

variable "name" {
  type        = string
  description = "Author Name"
}

variable "vpc_info" {
  description = "RDS Configuration"
  type = object({
    vpc_id = string
    vpc_cidr = string
  })
}

variable "security_groups" {
  description = "Security Group Variable Configuration"
  type = map(object({
    description = string
    ingress_rules = list(object({
      from_port   = number
      to_port     = number
      protocol    = string
    }))
  }))
}

