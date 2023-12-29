resource "aws_db_subnet_group" "dbsubnet"{
    subnet_ids = var.db_subnet_group
    tags = merge("${var.tags}",{environment = "${terraform.workspace}"}, {Name = "${var.name}-db_subnet"})
}

resource "aws_secretsmanager_secret" "password" {
  name = var.secret_manager_info.password_secret_name
  description = "Database password"
  recovery_window_in_days = "0"

}

resource "aws_secretsmanager_secret_version" "password" {
  secret_id     = aws_secretsmanager_secret.password.id
  secret_string = var.rds.db_masterpassword
}

resource "aws_secretsmanager_secret" "username" {
  name = var.secret_manager_info.username_secret_name
  description = "Database username"
  recovery_window_in_days = "0"

}

resource "aws_secretsmanager_secret_version" "username" {
  secret_id     = aws_secretsmanager_secret.username.id
  secret_string = var.rds.db_masterusername
}

data "aws_secretsmanager_secret_version" "username" {
  secret_id = aws_secretsmanager_secret.username.id
  depends_on = [aws_secretsmanager_secret_version.username]
}

data "aws_secretsmanager_secret_version" "password" {
  secret_id = aws_secretsmanager_secret.password.id
  depends_on = [aws_secretsmanager_secret_version.password]
}

data "aws_availability_zones" "available" {}

resource "aws_rds_cluster" "main" {
    cluster_identifier = "test-cluster"
    database_name = var.rds.db_name
    engine = "aurora-mysql"
    engine_version = "5.7.mysql_aurora.2.11.2"
    skip_final_snapshot = true
    master_username = data.aws_secretsmanager_secret_version.username.secret_string
    master_password = data.aws_secretsmanager_secret_version.password.secret_string
    vpc_security_group_ids = [var.rds_security_group]
    db_subnet_group_name = aws_db_subnet_group.dbsubnet.name
    tags = merge("${var.tags}",{environment = "${terraform.workspace}"}, {Name = "${var.name}-rds_cluster"})
}

resource "aws_rds_cluster_instance" "writer" {
    engine = "aurora-mysql"
    identifier = "test-writer"
    engine_version = "5.7.mysql_aurora.2.11.2"
    instance_class = "db.t3.small"
    db_subnet_group_name = aws_db_subnet_group.dbsubnet.name
    cluster_identifier = aws_rds_cluster.main.id
    tags = merge("${var.tags}",{environment = "${terraform.workspace}"}, {Name = "${var.name}-rds_writer"})
}

resource "aws_rds_cluster_instance" "reader" {
    identifier = "test-reader"
    engine = "aurora-mysql"
    engine_version = "5.7.mysql_aurora.2.11.2"
    instance_class = "db.t3.small"
    db_subnet_group_name = aws_db_subnet_group.dbsubnet.name
    cluster_identifier = aws_rds_cluster.main.id
    tags = merge("${var.tags}",{environment = "${terraform.workspace}"}, {Name = "${var.name}-rds_reader"})
    depends_on = [aws_rds_cluster_instance.writer] 
}