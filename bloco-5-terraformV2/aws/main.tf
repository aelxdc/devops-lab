# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  #profile = var.profile
}

## o bloco abaixo faz com que o tfstate vá para um bucket na aws, e não fique localmente
terraform {
  backend "s3" {
    bucket = "bucket-thinkpad-console"
    key = "terraform-aws.tfstate"
    region = "us-east-1"
  }
}