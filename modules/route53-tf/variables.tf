variable "lb_info" {
    description = "Exported variables from different modules"
    type = object({
        internet_lb_name = string
        internet_lb_zone = string
    })
}
