resource "aws_security_group" "anki" {
  name_prefix = "anki-sg-"
  description = "Security group for Anki server"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "anki" {
  ami           = "ami-0c94855ba95c71c99" # Amazon Linux 2 AMI (HVM), SSD Volume Type
  instance_type = "t2.micro"
  # key_name      = "your_key_pair_name"
  vpc_security_group_ids = [aws_security_group.anki.id]

  user_data = <<-EOF
    #!/bin/bash

    yum update -y
    yum install -y bzip2

    curl -O https://apps.ankiweb.net/downloads/current/anki-2.1.45-linux-amd64.tar.bz2
    tar -xjf anki-2.1.45-linux-amd64.tar.bz2 -C /opt/
    rm anki-2.1.45-linux-amd64.tar.bz2

    /opt/anki-2.1.45-linux-amd64/bin/anki &
  EOF
}

output "public_ip" {
  value = aws_instance.anki.public_ip
}
