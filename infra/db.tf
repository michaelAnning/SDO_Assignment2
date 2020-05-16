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
    "${aws_security_group.db_security_group.id}",
  ]

  # Snapshots won't be made in the database, eating up resource time.
  ## (If on the off-chance it is, removed the ability to do so and apply the changes.)
  skip_final_snapshot = true

  tags = {
    Name = "Data Layer Database"
  }
}

