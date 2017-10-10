variable "aws_key_path" {default = ""}
variable "aws_key_name" {default = ""}

provider "aws" {
  region     = "eu-central-1"
}

resource "aws_security_group_rule" "allow_jenkins" {
    type            = "ingress"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]

    security_group_id = "${aws_security_group.ci_security_group.id}"
}

resource "aws_security_group_rule" "allow_artifactory" {
    type            = "ingress"
    from_port       = 8081
    to_port         = 8081
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]

    security_group_id = "${aws_security_group.ci_security_group.id}"
}

resource "aws_security_group_rule" "allow_ssh" {
    type            = "ingress"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]

    security_group_id = "${aws_security_group.ci_security_group.id}"
}

resource "aws_security_group_rule" "allow_all_outbound" {
    type            = "egress"
    from_port       = 10
    to_port         = 65000
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]

    security_group_id = "${aws_security_group.ci_security_group.id}"
}

resource "aws_security_group" "ci_security_group" {
    name = "vpc_ci"
    description = "Allow incoming http and ssh connections."
}

data "aws_ami" "ci_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["jenkins-artifactory-*"]
  }

  owners     = ["self"]
}


data "template_file" "user_data" {
  template = "user_data.sh"
}

resource "aws_instance" "ci" {
  ami                         = "${data.aws_ami.ci_ami.image_id}" # ubuntu 16.04 LTS on eu-central
  instance_type               = "m4.large"
  key_name                    = "${var.aws_key_name}"
  vpc_security_group_ids      = ["${aws_security_group.ci_security_group.id}"]
  associate_public_ip_address = true
  tags {
    Name = "CI System - Jenkins & Artifactory"
    Status = "keep"
    Maintainer = "mike@praqma.com"
  }
  user_data = "${file("user_data.sh")}"
}

resource "aws_eip" "lb" {
  instance = "${aws_instance.ci.id}"
  vpc      = true
}

output "ci_public_ip" {
 value = "${aws_instance.ci.public_ip}"
}
