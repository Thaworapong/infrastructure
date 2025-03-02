resource "aws_vpc" "my_vpc" {
  cidr_block           = "10.123.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "dev"
  }
}

resource "aws_subnet" "my_vpc_public_subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.123.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1a"

  tags = {
    Name = "dev-public"
  }
}

resource "aws_internet_gateway" "my_vpc_internet_gateway" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "dev-igw"
  }
}

resource "aws_route_table" "my_vpc_public_rt" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "dev-public-rt"
  }
}

resource "aws_route" "default_route" {
  route_table_id            = aws_route_table.my_vpc_public_rt.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.my_vpc_internet_gateway.id
}

resource "aws_route_table_association" "my_vpc_public_assoc" {
  subnet_id = aws_subnet.my_vpc_public_subnet.id
  route_table_id = aws_route_table.my_vpc_public_rt.id
}

resource "aws_security_group" "my_vpc_sg" {
  name        = "dev-sg"
  description = "dev security group"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "name" {
  key_name = "my_vpc_key"
  public_key = file("~/.ssh/my_vpc_key.pub")
}
