output "network_info" {
  description = "Network Information"
  value = {
    vpc_id = aws_vpc.vpc.id
    public_route_table_id = aws_route_table.publicroutetable.id
    private_route_table_id = aws_route_table.privateroutetable.id
    internet_gateway_id = aws_internet_gateway.igw.id
  }
} 

output "subnet_info" {
  description = "Subnet Information"
  value = {
    public_subnet_main = aws_subnet.web[0].id
    public_web_subnet_id = aws_subnet.web.*.id
    private_app_subnet_id = aws_subnet.app.*.id
    private_db_subnet_id = aws_subnet.db.*.id 
  }
}