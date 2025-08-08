variable "region" {}
variable "aws_access_key_id" {}
variable "aws_secret_access_key" {}
variable "ami_id" {}
variable "vpc_id" {}
variable "subnet_ids" {
  type = list(string)
}
variable "db_password" {
  sensitive = true
}
variable "domain_name" {}
