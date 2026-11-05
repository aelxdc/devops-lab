# Bloco 5: Terraform em Nível Profissional

Este repositório contém a infraestrutura como código (IaC) modularizada e escalável desenvolvida na AWS utilizando o Terraform, contemplando boas práticas corporativas de isolamento de estado, consumo e desenvolvimento de módulos, refatoração segura sem indisponibilidade e validações estáticas de código e segurança.



## 1. Estrutura do Repositório

O projeto adota a separação arquitetural estrita entre declaração de infraestrutura reutilizável (módulos) e composição de ambientes (`environments`):

```text
.
├── .tflint.hcl                 # Configuração do linter avançado para AWS
├── README.md                   # Documentação técnica e comprovação dos entregáveis
├── modules/
│   └── app_cluster/            # Módulo próprio reutilizável (EC2 + ALB + SG)
│       ├── ec2.tf              # Declaração das instâncias e user_data Nginx
│       ├── lb.tf               # ALB, Target Group, Listeners e Attachments
│       ├── sg.tf               # Security Group da aplicação
│       ├── outputs.tf          # Dados exportados pelo módulo (DNS, IPs, etc.)
│       ├── variables.tf        # Parâmetros aceitos pelo módulo
│       └── versions.tf         # Versões de provider e HCL requeridas
└── environments/
    ├── dev/                    # Ambiente de Desenvolvimento
    │   ├── backend.tf          # Configuração do state remoto S3 com lock nativo
    │   ├── main.tf             # Orquestração: Módulo VPC (Registry) + app_cluster
    │   ├── outputs.tf          # Outputs expostos para o operador/pipeline
    │   └── versions.tf         # Definição do provider AWS e versões locais
    └── prd/                    # Ambiente de Produção
        ├── backend.tf          # State remoto isolado em prd/terraform-aws.tfstate
        ├── main.tf             # Orquestração dimensionada para alta disponibilidade
        ├── outputs.tf          # Outputs de produção
        └── versions.tf
```

## 2. State remoto

A gestão de estado foi configurada de forma remona no S3, utilizando a função do Terraform, introduzida nas versões mais novas.

```terraform {
  backend "s3" {
    bucket       = "bucket-thinkpad-console"
    key          = "dev/terraform-aws.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}
```

## 3. Módulos

Esse projeto combina o uso de módulos próprios com um módulo homologado do registry/comunidade.

### 1. Módulo próprio **modules/app_cluster**

- Junta a camada computacional, load balancer e security groups
- Separa o recurso de rede, pega o vpc_id e subnet via variavel de entrada

### 2. Consumo de módulo oficial do Registry

- Camada de newtorking é provisionada consumindo o módulo oficial de VPC com controle de versão

```
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "vpc-dev"
  cidr = "10.0.0.0/16"

  azs            = ["us-east-1a", "us-east-1b"]
  public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
}
```

## 4. Workspaces vs Diretórios

Na arquitetura desse repositorio, adotei a separação utilizando o modelo de diretorios isolados, **environments/dev** e **environments/prd**. A escolha dessa arquitetura se faz pelo modo como o workspaces funciona.

- Isola o **raio de destruição**  no Terraform. No Workspaces, todos os ambientes compartilham o mesmo arquivo state, então um erro ao executar um _terraform destroy_ pode atingir a produção sem querer. Na utilização de diretórios, os states ficam em contextos diferentes _dev/_ e _prd/_.

- Poder utiliar diferentes arquiteturas e dimensionamentos. Em um ambiente de produçaõ, pode existir uma demanda maior de recuros e portanto maquinas/shapes maiores. Já em um ambiente de desenvolviento, na maioria dos caso isso pode não ser necessário. Portanto, ter diretórios separados para cada projeto pode ajudar a economizar no ambiente de dev já que cada recurso fica isolado em seu contexto.

- Com o uso de diretórios é possivel testar uma versão major de um módulo em **dev**, sem forçar a atualização imediata em **prd**.

- Controle de acesso. Permite atrelar pipelines, permissões de credenciais e branches Git especificas para cada contexto.

## 5. Refatoração sem Downtime (**moved**, **import** e **-replace**)

### Usando o **moved**

Ao migrar recursos avulsos dentro de um módulo reutilizável, o bloco **moved {}** é utilizado para evitar que o Terraform destrua e recrie a infraestrutura

```
moved {
from = aws_instance.ec2create
 to   = module.app_cluster.aws_instance.ec2create
}
```

Atualiza o endereço do recurso diretamente no state, gerando um plano sem alteraões.

### Importação declarativa **import  {}**

Permite incorporar recursos criados previamente (via console ou legado) para a gestão do Terraform sem impacto:

```
import {
  to = aws_security_group.sg_legado
  id = "sg-0abc12345def67890"
}
```

### Recriação com **terraform apply -replace**

Substitui o comando antigo *terraform taint* sem alterar o state de forma preemptiva. Permite forçar a criação de uma instância com falaha, mantendo o resto da infraestrutura intacta.

```
terraform apply -replace="module.app_cluster.aws_instance.ec2create[0]"
```

## 6. Validação em camadas

Validação e consistencia do código com 3 ferramentas.

1. **terraform fmt -recursive**; Formatação automática que segue o padrão canônico da linguagem HCL
2. **terraform validate**: Validação de sintaxe e consistência interna entre recursos, variáveis e módulos, não se comunica com a nuvem.
3. **tflint --recursive**: Linter estático que conhece as regras do provider AWS configurado no arquivo **.tflint.hcl**:

```
 config {
   call_module_type = "all"
   force            = false
 }
 plugin "aws" {
   enabled = true
   version = "0.38.0"
   source  = "[github.com/terraform-linters/tflint-ruleset-aws](https://github.com/terraform-linters/tflint-ruleset-aws)"
 }
```

## 7. Scanners de segurança **Checkov** e **Trivy**

Utilizei as auditorias estáticas de vulnerabilidade utilizando o Checkov e Trivy

```
# Execução Checkov
checkov -d . --framework terraform

# Execução Trivy
trivy config .
```