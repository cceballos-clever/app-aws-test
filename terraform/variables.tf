variable "region" {
  description = "AWS region"
  type        = string
}

variable "access_key" {
  description = "AWS Access Key"
  type        = string
  sensitive   = true
}

variable "secret_key" {
  description = "AWS Secret Key"
  type        = string
  sensitive   = true
}

variable "ami_id" {
  description = "AMI ID para la instancia EC2"
  type        = string
}

variable "vpc_id" {
  description = "ID de la VPC"
  type        = string
}

variable "db_username" {
  description = "Usuario para la base de datos"
  type        = string
}

variable "db_password" {
  description = "Contraseña para la base de datos"
  type        = string
  sensitive   = true
}

variable "domain_name" {
  description = "Nombre de dominio para Route53"
  type        = string
}

variable "public_subnet_ids" {
  description = "Lista de subnets públicas"
  type        = list(string)
}
