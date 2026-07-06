# infra/terraform/outputs.tf

output "instance_public_ip" {
  description = "O endereço IP público da instância EC2."
  value       = aws_instance.app_server.public_ip
}