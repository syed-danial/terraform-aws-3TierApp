variable "db_subnet_group" {
    type = list(string)
    description = "Subnet ID of the DB subnet group"
}

variable "tags" {
  description = "Tags to identify ENV and prevent them from being nuked"
  type        = map(string)
}

variable "name" {
  type        = string
  description = "Author Name"
}

variable "rds" {
  description = "RDS Varibale Configuration"
  type = object({
    db_name           = string
    db_masterpassword = string
    db_masterusername = string
    
  })
}

variable "rds_security_group" {
    type = string
}

variable "secret_manager_info" {
  type = object({
    username_secret_name = string
    password_secret_name = string
  })
}