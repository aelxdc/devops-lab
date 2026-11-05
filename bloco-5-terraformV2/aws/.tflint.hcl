config {
  call_module_type = "all"
  force  = false
}

plugin "aws" {
  enabled = true
  version = "0.38.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

# Garante a checagem de tipos de instância EC2 válidos na AWS
rule "aws_instance_invalid_type" {
  enabled = true
}

# Alerta sobre instâncias EC2 sem tags obrigatórias
rule "aws_instance_invalid_ami" {
  enabled = true
}
