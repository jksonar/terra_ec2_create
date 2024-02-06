
# crate new ssh key
resource "tls_private_key" "rsa-4096-example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# add public key to aws key
resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = resource.tls_private_key.rsa-4096-example.public_key_openssh
}

# find ami image
data "aws_ami" "ec2_image" {
  most_recent = true

  filter {
    # AMI name = debian-12-amd64-20231013-1532
    name   = "name"
    values = ["debian-12-amd64-20231013-1532"]
  }
}

# create new aws ec2 server 
resource "aws_instance" "web" {
  ami               = data.aws_ami.ec2_image.id
  instance_type     = "t2.micro"
  availability_zone = "us-east-1a"
  key_name          = resource.aws_key_pair.deployer.key_name
  user_data         = <<-EOF
  #!/bin/bash
  sudo apt update -y
  sudo apt install apache2 -y
  sudo bash -c 'echo your very first web server > /var/www/html/index.html'
  sudo systemctl start apache2
  EOF
  tags = {
    Name = "Hello_World_terraform"
    env  = "dev-test"
  }
}

resource "local_file" "key_file" {
  content         = resource.tls_private_key.rsa-4096-example.private_key_openssh
  filename        = "${path.module}/privat.pem"
  file_permission = 0600
}

resource "local_file" "pub_key_file" {
  content         = resource.tls_private_key.rsa-4096-example.public_key_openssh
  filename        = "${path.module}/public.pem"
  file_permission = 0600
}

