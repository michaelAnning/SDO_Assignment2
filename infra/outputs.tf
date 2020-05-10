output "instance_public_ip" {
  value = "${aws_instance.private_instance.instance_public_ip}"
}

output "lb_endpoint" {
  value = "${aws_lb.assignment2.lb_endpoint}"
}

output "db_endpoint" {
  value = "${aws_db_instance.default.db_endpoint}"
}

output "db_user" {
  value = "${aws_db_instance.default.db_user}"
}

output "db_pass" {
  value = "${aws_db_instance.default.db_pass}"
}