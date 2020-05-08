# Configure AWS provider
provider "aws" {
  version = "~> 2.0"
  region  = "us-east-1"
}

# Create a VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Assignment2 VPC"
  }
}

# Create a VPC Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.main.id}"

  tags = {
    Name = "Assignment2 Internet Gateway"
  }
}

# Create Default Routing Table
resource "aws_default_route_table" "default_table" {
  default_route_table_id = "${aws_vpc.main.default_route_table_id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags = {
    Name = "Default Table"
  }
}

# Establish Subnets For VPC

## Public Availability Zones
resource "aws_subnet" "public_az1" {
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "10.0.0.0/22"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public AZ1"
  }
}

resource "aws_subnet" "public_az2" {
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "10.0.4.0/22"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public AZ2"
  }
}

resource "aws_subnet" "public_az3" {
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "10.0.8.0/22"
  availability_zone       = "us-east-1c"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public AZ3"
  }
}

## Private Availability Zones
resource "aws_subnet" "private_az1" {
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "10.0.16.0/22"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Private AZ1"
  }
}

resource "aws_subnet" "private_az2" {
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "10.0.20.0/22"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "Private AZ2"
  }
}

resource "aws_subnet" "private_az3" {
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "10.0.24.0/22"
  availability_zone       = "us-east-1c"
  map_public_ip_on_launch = true

  tags = {
    Name = "Private AZ3"
  }
}

## Data Availability Zones
resource "aws_subnet" "data_az1" {
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "10.0.32.0/22"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Data AZ1"
  }
}

resource "aws_subnet" "data_az2" {
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "10.0.36.0/22"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "Data AZ2"
  }
}

resource "aws_subnet" "data_az3" {
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "10.0.40.0/22"
  availability_zone       = "us-east-1c"
  map_public_ip_on_launch = true

  tags = {
    Name = "Data AZ3"
  }
}

# Setup Security Groups
resource "aws_security_group" "allow_https_ssh" {
  description = "Allow inbound SSH & HTTPs traffic."
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    description = "SSH from the internet."
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from the internet."
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Allow HTTPs & SSH"
  }
}

# Setup Public AZ Load Balancer
resource "aws_lb" "assignment2" {
  name               = "assignment2-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.allow_https_ssh.id}"]
  subnets            = ["${aws_subnet.public_az1.id}", "${aws_subnet.public_az2.id}", "${aws_subnet.public_az3.id}"]
}