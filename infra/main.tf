# Configure AWS provider
provider "aws" {
  version = "~> 2.0"
  region  = "us-east-1"
}

# Setup Security Groups
resource "aws_security_group" "allow_http_ssh" {
  name        = "allow_http_and_ssh"
  description = "Allow inbound SSH & HTTP traffic."
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    description = "SSH from the internet."
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP from the internet."
    from_port   = 80
    to_port     = 80
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
    Name = "Allow HTTP & SSH"
  }
}

resource "aws_security_group" "db_security_group" {
  name        = "allow_postgres_communication"
  description = "Allow inbound Postgres traffic."
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    description = "Allow VPC to Communicate with Postgres Port."
    from_port   = 5432
    to_port     = 5432
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
    Name = "Allow Postgres Communication"
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
  security_groups    = ["${aws_security_group.allow_http_ssh.id}"]
  subnets            = "${aws_db_subnet_group.public.subnet_ids}"
}

# Setup Load Balancer Target Group
resource "aws_lb_target_group" "ass2Group" {
  name = "ass-2-target-group"
  port = "80"
  protocol = "HTTP"
  vpc_id = "${aws_vpc.main.id}"
}

# Provide Routing to Load Balancer Via a Listener
resource "aws_lb_listener" "ass2Listener" {
  load_balancer_arn = "${aws_lb.assignment2.arn}"
  port = "80"
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = "${aws_lb_target_group.ass2Group.arn}"
  }
}

# Automatically Create the Inventory File
data "template_file" "inventory" { # 'data refers to an action with a stored output. We can get any data the output renders.
  # Reference Template File That'll Generate the Inventory
  template = "${file("../ansible/templates/inventory.tpl")}"

  # Pass Terraform Outputs to Inventory
  vars = {
    public_ip_of_private_server = "${aws_instance.private_instance.public_ip}" # Public Server
    database_endpoint = "${aws_db_instance.default.endpoint}"
    database_username = "${aws_db_instance.default.username}"
    database_password = "${aws_db_instance.default.password}"
  }
}

# Store Auto-Generated Inventory as a File in a Directory
resource "local_file" "save_inventory_to_directory" {
  content = "${data.template_file.inventory.rendered}"
  filename = "../ansible/inventory.yml"
}

# Create Script to Update Database
data "template_file" "update_db" {
  template = "${file("../ansible/templates/create_db_updater.tpl")}"

  vars = {
    public_ip_of_private_server = "${aws_instance.private_instance.public_ip}" # Public Server
    database_address = "${aws_db_instance.default.address}"
    database_name = "${aws_db_instance.default.name}"
    database_username = "${aws_db_instance.default.username}"
    database_password = "${aws_db_instance.default.password}"
  }
}

# Save it in the Ansible Directory
resource "local_file" "save_db_script_to_directory" {
  content = "${data.template_file.update_db.rendered}"
  filename = "../ansible/update_db.sh"
}

# Create Makefile (Provide it Correct VPC Details)
data "template_file" "create_makefile" {
  template = "${file("../ansible/templates/create_makefile.tpl")}"

  vars = {
    public_ip_of_private_server = "${aws_instance.private_instance.public_ip}" # Public Server
  }
}

# Save Makefile
resource "local_file" "save_makefile_to_directory" {
  content = "${data.template_file.create_makefile.rendered}"
  filename = "../Makefile"
}

# # Auto Run Ansible Playbook
# resource "template_file" "playbook" {
#   template = "${file("../ansible/templates/run_ansible.tpl")}"
# }

# # Setup Kubernetes
# resource "random_string" "tfstatename" {
#   length  = 6
#   special = false
#   upper   = false
# }

# resource "aws_s3_bucket" "kops_state" {
#   bucket        = "rmit-kops-state-${random_string.tfstatename.result}"
#   acl           = "private"
#   force_destroy = true

#   versioning {
#     enabled = true
#   }

#   tags = {
#     Name = "kops remote state"
#   }
# }

# output "kops_state_bucket_name" {
#   value = "${aws_s3_bucket.kops_state.bucket}"
# }