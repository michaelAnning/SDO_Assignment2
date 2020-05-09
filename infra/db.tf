# Deploy a Database in the Data Layer
resource "aws_db_instance" "default" {
  allocated_storage = 20
  engine            = "postgres"
  engine_version    = "12.2"
  instance_class    = "db.t2.micro"
  name              = "datadb"

  # Below are created along with the database. Don't need to be preset elsewhere.
  username = "username"
  password = "password"

  # Data Subnets
  db_subnet_group_name = "${aws_db_subnet_group.data.name}"

  # Security Group
  vpc_security_group_ids = [
  "${aws_security_group.allow_https_ssh.id}"]

  tags = {
    Name = "Data Layer Database"
  }

  # Added to allow myself to delete DBs before applying them. Reference: https://ndench.github.io/terraform/terraform-destroy-rds
  final_snapshot_identifier = "death"
}
