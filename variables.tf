# infra/terraform/variables.tf

variable "ssh_public_key" {
  description = "A chave pública SSH para ser usada na instância EC2."
  type        = string
  # Você pode criar um arquivo terraform.tfvars para preencher esta variável
}