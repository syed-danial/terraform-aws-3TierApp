module "vpc" {
  source = "./modules/vpc-tf"
  name = var.name
  tags   = var.tags["VPC"]
  VPC = {
    vpc_cidr               = var.VPC.vpc_cidr
    web_subnet_cidr_blocks = var.VPC.web_subnet_cidr_blocks
    app_subnet_cidr_blocks = var.VPC.app_subnet_cidr_blocks
    db_subnet_cidr_blocks  = var.VPC.db_subnet_cidr_blocks
    create_nat_gateway     = var.VPC.create_nat_gateway
  }
}

module "securitygroups" {
  source = "./modules/securitygroups-tf"
  name = var.name
  vpc_info = {
    vpc_id = module.vpc.network_info.vpc_id
    vpc_cidr = var.VPC.vpc_cidr
  }
  tags   = var.tags["security_groups"]
  security_groups = var.security_groups
}

module "rds" {
  source = "./modules/rds-tf"
  tags   = var.tags["rds"]
  name = var.name
  rds = {
    db_name           = var.rds.db_name
    db_masterusername = var.rds.db_masterusername
    db_masterpassword = var.rds.db_masterpassword
  }

  secret_manager_info = {
    username_secret_name = var.secret_manager_info.username_name
    password_secret_name = var.secret_manager_info.password_name
  }

  rds_security_group = module.securitygroups.SG_ids.db_sg_id
  db_subnet_group    = module.vpc.subnet_info.private_db_subnet_id
}

module "app" {
  source = "./modules/app-tf"
  tags   = var.tags["app"]
  region = var.region
  name = var.name
  listener_actions = var.listener_actions
  key = {
    key_pair_name = var.key.key_pair_name
    public_key    = var.key.public_key
  }

  launch_config = {
    instance_type = var.launch_config.instance_type
  }

  secret_manager_info = {
    username_secret_name = var.secret_manager_info.username_name
    password_secret_name = var.secret_manager_info.password_name
  }
  
  exported = {
    app_subnet_group      = module.vpc.subnet_info.private_app_subnet_id
    app_security_group    = module.securitygroups.SG_ids.app_sg_id
    app_lb_security_group = module.securitygroups.SG_ids.app_lb_sg_id
    writer_endpoint       = module.rds.rds_info.db_writer_endpoint
    db_name               = var.rds.db_name
    vpc_id                = module.vpc.network_info.vpc_id
  }

  app_asg_config = {
    min_size         = var.app_asg_config.min_size
    max_size         = var.app_asg_config.max_size
    desired_capacity = var.app_asg_config.desired_capacity
  }
}

module "web" {
  source = "./modules/web-tf"
  tags   = var.tags["web"]
  name = var.name
  key = {
    key_pair_name = var.key.key_pair_name
    public_key    = var.key.public_key
  }

  web_exported = {
    web_subnet_group              = module.vpc.subnet_info.public_web_subnet_id
    web_lb_security_group         = module.securitygroups.SG_ids.web_lb_sg_id
    web_security_group            = module.securitygroups.SG_ids.web_sg_id
    vpc_id                        = module.vpc.network_info.vpc_id
    app_internal_loadbalancer_dns = module.app.ilb_info.internal_lb_dns
  }

  web_asg_config = {
    min_size         = var.web_asg_config.min_size
    max_size         = var.web_asg_config.max_size
    desired_capacity = var.web_asg_config.desired_capacity
  }

  launch_config = {
    instance_type = var.launch_config.instance_type
  }
}

module "alarms" {
  source = "./modules/alarms-tf"
  tags   = var.tags["alarms"]
  name = var.name
  alarms = var.alarms
  alarm_policy_mapping = var.alarm_policy_mapping
  auto_scaling_policies = var.auto_scaling_policies
  web_asg_info = {
    web_asg_name = module.web.web_asg_info.name
  }
}

module "route53" {
  source = "./modules/route53-tf"
  lb_info = {
    internet_lb_name = module.web.internetlb_info.internet_lb_dns
    internet_lb_zone = module.web.internetlb_info.internet_hosted_zone
  }
  depends_on = [module.web]
}