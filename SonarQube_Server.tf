provider "aws" {
  region = "us-east-1" # Replace with your AWS region
}

resource "aws_security_group" "sonarqube_sg" {
  name_prefix = "sonarqube-sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # SSH access (restrict to your IP in production)
  }

  ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # SonarQube access
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "sonarqube" {
  ami                    = "ami-0e2c8caa4b6378d8c" # Replace with a valid AMI ID for your region (Ubuntu preferred)
  instance_type          = "t2.miduim" # Minimum requirement for SonarQube
  security_groups        = [aws_security_group.sonarqube_sg.name]
  key_name               = "sonarqube-key" # Replace with your AWS key pair name

  tags = {
    Name = "SonarQube-Server"
  }

  user_data =<<-EOF
    #!/bin/bash
    # Update and upgrade the system
    apt-get update -y
    apt-get upgrade -y

    # Install Docker
    apt-get install -y docker.io
    systemctl start docker
    systemctl enable docker

    # Run SonarQube Docker container
    docker run --name sonarqube --restart always -p 9000:9000 -d sonarqube

    # Set SSH password for the default user
    echo 'ubuntu:abderrazzak' | chpasswd
  EOF
}

output "sonarqube_public_ip" {
  value = aws_instance.sonarqube.public_ip
  description = "Public IP of the SonarQube server"
}
