terraform {
  source = "../terraform"
}

inputs = {
  region      = "us-east-1"
  access_key  = "REEMPLAZAR_O_USAR_SECRETO"
  secret_key  = "REEMPLAZAR_O_USAR_SECRETO"
  ami_id      = "REEMPLAZAR_CON_AMI_DE_PACKER"
}
