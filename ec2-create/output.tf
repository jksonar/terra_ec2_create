output "instance_public_ip" {
  value       = aws_instance.web.public_ip
  description = "Public IP of the EC2 instance"
}

output "instance_public_dns" {
  value       = aws_instance.web.public_dns
  description = "Public DNS of the EC2 instance"
}