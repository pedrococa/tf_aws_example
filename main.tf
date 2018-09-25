resource "aws_instance" "example" {
  ami		= "ami-07a09008cc59ea2eb"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.instance.id}"]

  user_data = <<-EOF
		#!/bin/bash
		echo "Hola Manola" > index.html
		nohup busybox httpd -f -p 8080 &
		EOF

  tags {
    Name = "pcoca-demo"
  }
}

resource "aws_security_group" "instance" {
  name = "terraform-example-instance"

  ingress {
    from_port = "8080"
    to_port = "8080"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "public_ip" {
  value = "${aws_instance.example.public_ip}"
}
