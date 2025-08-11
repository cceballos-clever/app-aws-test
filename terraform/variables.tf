variable "region" {}
variable "access_key" {}
variable "secret_key" {}
variable "ami_id" {}
variable "vpc_id" {}
variable "db_username" {}
variable "db_password" {
  sensitive = true
}
variable "domain_name" {}

variable "public_subnet_id" {
  description = "List of public subnet IDs"
  type        = string
}

variable "private_subnet_id" {
  description = "List of private subnet IDs"
  type        = string
}
