variable "region" {}
variable "access_key" {}
variable "secret_key" {}
variable "ami_id" {}
variable "vpc_id" {}
variable "subnet_ids" {
  type = list(string)
}
variable "db_password" {
  sensitive = true
}
variable "domain_name" {}
