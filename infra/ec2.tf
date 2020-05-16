# Setup an Ec2 Instance in the Private Layer
resource "aws_instance" "private_instance" {
  # Reference Amazon Linux 2 Image
  ami = "ami-0323c3dd2da7fb37d" # Latest Linux Image

  # ami = "ami-055d18a0205f9ddb1" # Tutorial Week

  key_name      = "${aws_key_pair.deployer.key_name}"
  instance_type = "t2.micro"

  # Only one Subnet is Needed/Allowed
  subnet_id = "${aws_subnet.private_az1.id}"

  # Provide a Public IP to Access this Server from the Internet
  # Allows us to access it remotely.
  associate_public_ip_address = "true" # Reference: https://blog.albertoacuna.com/using-terraform-to-create-an-ec2-instance-within-a-public-subnet-in-aws/

  vpc_security_group_ids = [
    "${aws_security_group.allow_http_ssh.id}",
  ]

  tags = {
    Name = "Private Layer Ec2"
  }
  # Connect to ec2 via SSH command
  # ssh -i ~/.ssh ec2-user@"${aws_instance.private_instance.instance_public_ip}"
}

# # Create Makefile (Provide it Correct VPC Details)
# data "template_file" "makefileRandom" {
#   template = "${file("../../ansible/templates/makefileIP.tpl")}"

#   vars = {
#     ec2IP = "${aws_instance.private_instance.public_ip}"
#   }
# }

# # Save Makefile
# resource "local_file" "makefileRandom" {
#   content = "${data.template_file.makefileIP.rendered}"
#   filename = "../randomstring.txt"
# }
