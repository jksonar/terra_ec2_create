output "aws_ec2_prob_ip" {
  value = resource.aws_instance.web.public_ip
}