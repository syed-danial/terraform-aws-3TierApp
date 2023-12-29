variable "tags" {
  description = "Tags to identify ENV and prevent them from being nuked"
  type = map(string)
}

variable "name" {
  type        = string
  description = "Author Name"
}


variable "VPC" {
  description = "VPC Configuration"
  type = object ({
    vpc_cidr = string
    web_subnet_cidr_blocks = list(string)
    app_subnet_cidr_blocks = list(string)
    db_subnet_cidr_blocks = list(string)
    create_nat_gateway = bool
  })
}
