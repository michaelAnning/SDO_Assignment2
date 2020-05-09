# Configure AWS provider
provider "aws" {
  version = "~> 2.0"
  region  = "us-east-1"
}

# Setup Security Groups
resource "aws_security_group" "allow_https_ssh" {
  name        = "allow_https_and_ssh"
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

# Define Subnet Groups
resource "aws_db_subnet_group" "public" {
  name       = "pubsubs"
  subnet_ids = ["${aws_subnet.public_az1.id}", "${aws_subnet.public_az2.id}", "${aws_subnet.public_az3.id}"]

  tags = {
    Name = "Public Subnets Group"
  }
}

resource "aws_db_subnet_group" "private" {
  name       = "privsubs"
  subnet_ids = ["${aws_subnet.private_az1.id}", "${aws_subnet.private_az2.id}", "${aws_subnet.private_az3.id}"]

  tags = {
    Name = "Private Subnets Group"
  }
}

resource "aws_db_subnet_group" "data" {
  name       = "datsubs"
  subnet_ids = ["${aws_subnet.data_az1.id}", "${aws_subnet.data_az2.id}", "${aws_subnet.data_az3.id}"]

  tags = {
    Name = "Data Subnets Group"
  }
}

# Setup Public AZ Load Balancer
resource "aws_lb" "assignment2" {
  name               = "assignment2-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.allow_https_ssh.id}"]
  subnets            = "${aws_db_subnet_group.public.subnet_ids}"
}

# Setup Kubernetes
resource "random_string" "tfstatename" {
  length  = 6
  special = false
  upper   = false
}

resource "aws_s3_bucket" "kops_state" {
  bucket        = "rmit-kops-state-${random_string.tfstatename.result}"
  acl           = "private"
  force_destroy = true

  versioning {
    enabled = true
  }

  tags = {
    Name = "kops remote state"
  }
}

output "kops_state_bucket_name" {
  value = "${aws_s3_bucket.kops_state.bucket}"
}