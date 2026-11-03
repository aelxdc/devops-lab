terraform {
  backend "s3" {
    bucket       = "bucket-thinkpad-console"
    key          = "prd/terraform.tfstate" # Chave exclusiva de produção
    region       = "us-east-1"
    use_lockfile = true
  }
}