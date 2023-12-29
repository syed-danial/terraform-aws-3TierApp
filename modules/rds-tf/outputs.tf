output "rds_info" {
    description = "RDS Writer Info"
    value = {
        db_writer_endpoint = aws_rds_cluster_instance.writer.endpoint
        is_writer = aws_rds_cluster_instance.writer.writer
    }
}