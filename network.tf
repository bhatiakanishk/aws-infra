resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Create public and private subnets in 3 availability zones
locals {
  azs = data.aws_availability_zones.available.names
}

data "aws_availability_zones" "available" {}

resource "aws_subnet" "public_subnet" {
  count = 3
  cidr_block = "10.0.${count.index}.0/24"
  vpc_id = aws_vpc.my_vpc.id
  availability_zone = element(local.azs, count.index)

  tags = {
    Name = "public-subnet-${count.index}"
  }
}

resource "aws_subnet" "private_subnet" {
  count = 3
  cidr_block = "10.0.${count.index + 10}.0/24"
  vpc_id = aws_vpc.my_vpc.id
  availability_zone = element(local.azs, count.index)

  tags = {
    Name = "private-subnet-${count.index}"
  }
}

# Create internet gateway and attach it to the VPC
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "my-igw"
  }
}

# Create public route table and associate it with public subnets
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public_rta" {
  count = 3
  subnet_id = element(aws_subnet.public_subnet.*.id, count.index)
  route_table_id = aws_route_table.public_rt.id
}

# Create private route table and associate it with private subnets
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "private-route-table"
  }
}

resource "aws_route_table_association" "private_rta" {
  count = 3
  subnet_id = element(aws_subnet.private_subnet.*.id, count.index)
  route_table_id = aws_route_table.private_rt.id
}
