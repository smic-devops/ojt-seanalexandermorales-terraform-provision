output "ec2_instance_private_dns" {
  description = "EC2 Instance Private DNS"
  value       = aws_instance.web.private_dns
}