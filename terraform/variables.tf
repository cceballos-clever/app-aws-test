variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
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

variable "db_username" {
  description = "Usuario para la base de datos"
  type        = string
}

variable "db_password" {
  description = "Contraseña para la base de datos"
  type        = string
  sensitive   = true
}

variable "key-name" {
  description = "Nombre del key pair para EC2"
  type        = string
}

variable "domain_name" {
  description = "Nombre de dominio para Route53"
  type        = string
}
