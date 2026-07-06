# infra/terraform/main.tf

# Bloco de configuração do Terraform.
# Especifica a versão do Terraform e os provedores necessários.
terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configura o provedor da AWS, definindo a região onde os recursos serão criados.
provider "aws" {
  region = "us-east-1"
}

# Declara o nosso primeiro recurso: uma Virtual Private Cloud (VPC).
# Esta será a rede isolada para a nossa aplicação na AWS.
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "axes-bank-vpc"
  }

  # Bloco de provisionamento: executa comandos na instância após sua criação.
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/provision.sh",
      "/tmp/provision.sh"
    ]
  }

  # Copia o script de provisionamento para a instância.
  provisioner "file" {
    source      = "provision.sh"
    destination = "/tmp/provision.sh"
  }

  # Configura a conexão SSH para os provisionadores.
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("~/.ssh/id_rsa") # IMPORTANTE: Substitua pelo caminho da sua chave privada.
    host        = self.public_ip
  }
}