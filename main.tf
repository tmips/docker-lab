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
    Name = "Instance lab6"
  }

  user_data = <<-EOF
    #!/bin/bash
    set -e

    # Update system
    apt-get update -y
    apt-get install -y ca-certificates curl gnupg git

    # Add Docker’s official GPG key
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg

    # Add Docker repo
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
      https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
      tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Install Docker
    apt-get update -y
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # Clone your repo (replace if needed)
    cd /home/ubuntu
    git clone https://github.com/tmips/docker-lab.git
    cd docker-lab

    # Build and run container
    docker build -t lab4 .
    docker run -d -p 80:80 --name lab4_cont lab4

    # Run Watchtower
    docker run -d \
      --name watchtower \
      --restart always \
      -v /var/run/docker.sock:/var/run/docker.sock \
      containrrr/watchtower \
      --interval 30 --cleanup
  EOF
}
