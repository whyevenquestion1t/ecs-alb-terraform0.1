# This file contains the VPC and all of the networking resources


# Produciton VPC 
resource "aws_vpc" "production_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "produciton VPC"
  }
}

# Public subents
resource "aws_subnet" "public_subnet1" {
  vpc_id            = aws_vpc.production_vpc.id
  cidr_block        = var.public_subnet_1_cidr
  availability_zone = var.availability_zones[0]
  tags = {
    Name = "public_subnet1"
  }
}

resource "aws_subnet" "public_subnet2" {
  vpc_id            = aws_vpc.production_vpc.id
  cidr_block        = var.public_subnet_2_cidr
  availability_zone = var.availability_zones[1]
  tags = {
    Name = "public_subnet2"
  }
}


# Private subnets
resource "aws_subnet" "private_subnet1" {
  vpc_id            = aws_vpc.production_vpc.id
  cidr_block        = var.private_subnet_1_cidr
  availability_zone = var.availability_zones[0]
  tags = {
    Name = "private_subnet1"
  }
}

resource "aws_subnet" "private_subnet2" {
  vpc_id            = aws_vpc.production_vpc.id
  cidr_block        = var.private_subnet_2_cidr
  availability_zone = var.availability_zones[1]
  tags = {
    Name = "private_subnet2"
  }
}


# Routing tables for the subnets
resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.production_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  depends_on = [aws_internet_gateway.gw]

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table" "private-route-table" {
  vpc_id = aws_vpc.production_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nt-gw.id
  }
  depends_on = [aws_nat_gateway.nt-gw]

  tags = {
    Name = "private-route-table"
  }
}


# Route table association with the subnets 
resource "aws_route_table_association" "public-route-association-1" {
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.public-route-table.id
}

resource "aws_route_table_association" "public-route-association-2" {
  subnet_id      = aws_subnet.public_subnet2.id
  route_table_id = aws_route_table.public-route-table.id
}

resource "aws_route_table_association" "private-route-association-1" {
  subnet_id      = aws_subnet.private_subnet1.id
  route_table_id = aws_route_table.private-route-table.id
}

resource "aws_route_table_association" "private-route-association-2" {
  subnet_id      = aws_subnet.private_subnet2.id
  route_table_id = aws_route_table.private-route-table.id
}


# Internet Gateway for the public subnet
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.production_vpc.id
  tags = {
    Name = "internet-gtw"
  }
}

# Elastic IP for the NAT Gateway
resource "aws_eip" "eip-nat" {
  vpc                       = true
  associate_with_private_ip = "10.0.0.5"
}


# NAT Gateway (will reside in public subnet but will route traffic for private)
resource "aws_nat_gateway" "nt-gw" {
  allocation_id = aws_eip.eip-nat.id
  subnet_id     = aws_subnet.public_subnet1.id
  depends_on    = [aws_eip.eip-nat]

  tags = {
    Name = "NAT-gtw"
  }
}