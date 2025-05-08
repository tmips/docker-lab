provider "aws" {
  region = "us-east-1"
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "web_server_sg_tf" {
  name        = "web_server_sg_tf"
  description = "Allow HTTP and SSH"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["176.107.194.143/32"]
  }

  ingress {
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
}

resource "aws_instance" "web_server" {
  ami           = "ami-084568db4383264d4"
  instance_type = "t2.micro"
  key_name      = "keylab4"

  vpc_security_group_ids = [aws_security_group.web_server_sg_tf.id]

  tags = {
    Name = "Instance Lab6"
  }
}
