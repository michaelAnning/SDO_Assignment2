# # Setup S3 Bucket
# resource "aws_s3_bucket" "terraformState" {
#   bucket        = "ass2-bucket" # Alias to name. You're creating the bucket here, so just provide it's name here.
#   acl           = "public-read-write"
#   force_destroy = true

#   tags = {
#     Name = "Terraform Remote State"
#   }
# }

# resource "aws_s3_bucket_public_access_block" "example" {
#   bucket = "${aws_s3_bucket.terraformState.id}"

#   block_public_acls   = false
#   block_public_policy = false
# }

# # Setup DynamoDB
# resource "aws_dynamodb_table" "terraformStateLock" {
#   name           = "ass2-dynamodb"
#   read_capacity  = 20
#   write_capacity = 20
#   hash_key       = "StateLock"

#   # Establish Keys (Keys must be defined as attributes before they can be used)
#   attribute {
#     name = "StateLock"
#     type = "S"
#   }
# }

# Configure AWS provider
provider "aws" {
  version = "~> 2.0"
  region  = "us-east-1"
}

resource "random_string" "tfstatename" {
  length = 6
  special = false
  upper = false
}

# Create Makefile (Provide it Correct VPC Details)
data "template_file" "makefileRandom" {
  template = "${file("../../ansible/templates/makefileRandom.tpl")}"

  vars = {
    randomstring = "${random_string.tfstatename.result}"
  }
}

# Save Makefile
resource "local_file" "makefileRandom" {
  content = "${data.template_file.makefileRandom.rendered}"
  filename = "./randomstring.txt"
}

resource "aws_s3_bucket" "tfrmstate" {
  bucket = "rmit-tfstate-${random_string.tfstatename.result}"
  acl = "private"
  force_destroy = true

  tags = {
    Name = "TF Remote State"
  }
}

resource "aws_dynamodb_table" "terraform_statelock" {
  name = "RMIT-locktable-${random_string.tfstatename.result}"
  read_capacity = 20
  write_capacity = 20
  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}