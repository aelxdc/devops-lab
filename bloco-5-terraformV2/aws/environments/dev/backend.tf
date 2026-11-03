## o bloco abaixo faz com que o tfstate vá para um bucket na aws, e não fique localmente
terraform {
  backend "s3" {
    bucket = "bucket-thinkpad-console"
    key = "dev/terraform-aws.tfstate"
    region = "us-east-1"
    use_lockfile = true ##habilita o lockstate do tfstate
  }
}