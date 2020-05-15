output "instance_public_ip" {
  value = "${aws_instance.private_instance.public_ip}"
}

output "lb_endpoint" {
  value = "${aws_lb.assignment2.dns_name}"
}

output "db_endpoint" {
  value = "${aws_db_instance.default.address}"
}

output "db_user" {
  value = "${aws_db_instance.default.username}"
}

output "db_pass" {
  value = "${aws_db_instance.default.password}"
}