# Generate a new SSH key pair
resource "tls_private_key" "rsa_4096" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Declare the data source
data "aws_availability_zones" "available" {
  # use alias for resource
  # provider = aws.us
  state = "available"
}

# Add public key to AWS as a key pair
resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = tls_private_key.rsa_4096.public_key_openssh
}

# Find the latest Debian AMI
data "aws_ami" "ec2_image" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = [var.ami_name_filter]
  }
}

# Create a new AWS EC2 instance
resource "aws_instance" "web" {
  ami               = data.aws_ami.ec2_image.id
  instance_type     = var.instance_type
  availability_zone = data.aws_availability_zones.available.names[0]
  key_name          = aws_key_pair.deployer.key_name
  security_groups   = [ aws_security_group.web_sg.name ]
  user_data         = <<-EOF
    #!/bin/bash
    sudo apt update -y
    sudo apt install apache2 -y
    echo "Your very first web server" | sudo tee /var/www/html/index.html
    sudo systemctl enable apache2
    sudo systemctl start apache2
  EOF

  tags = {
    Name        = "Hello_World_terraform"
    Environment = "dev-test"
  }
}

# Save the private key to a local file
resource "local_file" "private_key" {
  content         = tls_private_key.rsa_4096.private_key_openssh
  filename        = "${path.module}/private.pem"
  file_permission = "0600"
  # lifecycle {
  #   prevent_destroy = true
  # }
}

# Save the public key to a local file
resource "local_file" "public_key" {
  content         = tls_private_key.rsa_4096.public_key_openssh
  filename        = "${path.module}/public.pem"
  file_permission = "0644"
  # lifecycle {
  #   prevent_destroy = true
  # }
}

data "aws_vpc" "default" {}

# read security group
resource "aws_security_group" "web_sg" {
  name        = "web_sg"
  description = "Security group for web server"
  vpc_id      = data.aws_vpc.default.id

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

  tags = {
    Name = "Web_SG"
  }
}

# Define variables for dynamic values
variable "ami_name_filter" {
  description = "Filter for finding the AMI image"
  default     = "debian-12-amd64-2025*"
}

variable "availability_zone" {
  description = "AWS availability zone to deploy the EC2 instance"
  default     = "us-east-1"
}

variable "instance_type" {
  description = "Type of EC2 instance to launch"
  default     = "t2.micro"
}
