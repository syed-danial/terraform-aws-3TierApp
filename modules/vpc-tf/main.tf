data "aws_availability_zones" "available" {}

resource "aws_vpc" "vpc" {
  cidr_block           = var.VPC.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = merge("${var.tags}",{environment = "${terraform.workspace}", Name = "${var.name}-VPC"})
}

resource "aws_internet_gateway" "igw" {
  vpc_id     = aws_vpc.vpc.id
  depends_on = [aws_vpc.vpc]
  tags = merge("${var.tags}",{environment = "${terraform.workspace}"}, {Name = "${var.name}-IGW"})
} 

resource "aws_subnet" "web" {
  count             = length(var.VPC.web_subnet_cidr_blocks)
  vpc_id            = aws_vpc.vpc.id
  availability_zone = data.aws_availability_zones.available.names[count.index % (length(data.aws_availability_zones.available.names))]
  cidr_block        = var.VPC.web_subnet_cidr_blocks[count.index]
  tags = merge("${var.tags}", { environment = "${terraform.workspace}", Name = "${var.name}-web_subnet-${count.index}"})
}

resource "aws_subnet" "app" {
  count             = length(var.VPC.app_subnet_cidr_blocks)
  vpc_id            = aws_vpc.vpc.id
  availability_zone = data.aws_availability_zones.available.names[count.index % (length(data.aws_availability_zones.available.names))]
  cidr_block        = var.VPC.app_subnet_cidr_blocks[count.index]

  tags = merge("${var.tags}",{environment = "${terraform.workspace}"}, {Name = "${var.name}-app_subnet-${count.index}"})
}

resource "aws_subnet" "db" {
  count             = length(var.VPC.db_subnet_cidr_blocks)
  vpc_id            = aws_vpc.vpc.id
  availability_zone = data.aws_availability_zones.available.names[count.index % (length(data.aws_availability_zones.available.names))]
  cidr_block        = var.VPC.db_subnet_cidr_blocks[count.index]

  tags = merge("${var.tags}",{environment = "${terraform.workspace}"}, {Name = "${var.name}-db_subnet-${count.index}"})
}

resource "aws_route_table" "publicroutetable" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = merge("${var.tags}",{environment = "${terraform.workspace}"}, {Name = "${var.name}-public_route_table"})
}

resource "aws_route_table" "privateroutetable" {
  vpc_id = aws_vpc.vpc.id
  tags = merge("${var.tags}",{environment = "${terraform.workspace}"}, {Name = "${var.name}-private_route_table"})
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"
  tags = merge("${var.tags}",{environment = "${terraform.workspace}"}, {Name = "${var.name}-nat_eip"})
}

resource "aws_nat_gateway" "default" {
  count         = var.VPC.create_nat_gateway ? 1 : 0
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.web[count.index].id
  tags = merge("${var.tags}",{environment = "${terraform.workspace}"}, {Name = "${var.name}-nat_gateway"})
}

resource "aws_route" "private_route" {
  count = var.VPC.create_nat_gateway ? 1: 0
  route_table_id         = aws_route_table.privateroutetable.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.default[0].id
}

resource "aws_route_table_association" "web_route" {
  count = length(var.VPC.web_subnet_cidr_blocks)
  subnet_id = element(aws_subnet.web.*.id, count.index)
  route_table_id = aws_route_table.publicroutetable.id
}

resource "aws_route_table_association" "app_route" {
  count = length(var.VPC.app_subnet_cidr_blocks)
  subnet_id = element(aws_subnet.app.*.id, count.index)
  route_table_id = aws_route_table.privateroutetable.id
}

resource "aws_route_table_association" "db_route" {
  count = length(var.VPC.db_subnet_cidr_blocks)
  subnet_id = element(aws_subnet.db.*.id, count.index)
  route_table_id = aws_route_table.privateroutetable.id
}