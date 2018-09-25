# Data source. Fetched from the cloud provider (AWS)
data "aws_availability_zones" "all" {}

resource "aws_launch_configuration" "example" {
  # Ubuntu 18.04 AMI
  image_id      = "ami-07a09008cc59ea2eb"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.instance.id}"]

  user_data = <<-EOF
		#!/bin/bash
		echo "Hola Manola" > index.html
		nohup busybox httpd -f -p "${var.server_port}" &
		EOF
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "example" {
  launch_configuration = "${aws_launch_configuration.example.id}"
  availability_zones = ["${data.aws_availability_zones.all.names}"]

  min_size = 2
  max_size = 5

  tag {
    key			= "Name"
    value		= "terraform-asg-example"
    propagate_at_launch = true
  }
}

resource "aws_security_group" "instance" {
  name = "terraform-example-instance"

  ingress {
    from_port = "${var.server_port}"
    to_port = "${var.server_port}"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

variable "server_port" {
  description = "The port of the server for the HTTP request"
  default = 8080
}

