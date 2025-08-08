variable "vpc_id" {
  description = "VPC donde se despliega todo"
  type        = string
}

variable "public_subnet_ids" {
  description = "Lista de subnets públicas"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "Lista de subnets privadas"
  type        = list(string)
}

variable "ami_id" {
  description = "AMI ID para la instancia EC2"
  type        = string
}

variable "db_username" {
  description = "Usuario para la base de datos PostgreSQL"
  type        = string
}

variable "db_password" {
  description = "Password para la base de datos PostgreSQL"
  type        = string
  sensitive   = true
}

variable "domain_name" {
  description = "Dominio para Route53"
  type        = string
}
