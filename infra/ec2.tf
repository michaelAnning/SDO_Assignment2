# Setup an Ec2 Instance in the Private Layer
resource "aws_instance" "private_instance" {

  # Reference Amazon Linux 2 Image
  ami = "ami-0323c3dd2da7fb37d"

  key_name      = "${aws_key_pair.deployer.key_name}"
  instance_type = "t2.micro"

  # Only one Subnet is Needed/Allowed
  subnet_id = "${aws_subnet.private_az1.id}"

  vpc_security_group_ids = [
  "${aws_security_group.allow_https_ssh.id}"]

  tags = {
    Name = "Private Layer Ec2"
  }
}