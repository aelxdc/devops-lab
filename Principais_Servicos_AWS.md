# Principais Serviços AWS

Modelos de deploy: CDK, SAM Serverless framework, CloudFormation, Terraform, CI/CD (GithubActions), Kubernetes.

###

###

### **Armazenamento: Amazon S3 Bucket (Simple Storage Service)**

* **Conceito**: Funciona como um repositório de arquivos ("balde") para documentos, backups, mídias estáticas, arquivamentoe até hospedagem de páginas estáticas simples.
* **Prós**: Custo baixo para armazenamento (para maioria dos casos) e capacidade de escala praticamente ilimitada.
* **Contras**: Não possui poder de computação nem sistema de arquivos tradicional; Latência; acessos constantes e requisições frequentes podem encarecer a conta caso seja usado incorretamente como banco de dados.

### **Computação: Amazon EC2 (Elastic Compute Cloud)**

* **Conceito**: Servidores virtuais / Instâncias sob demanda (máquinas virtuais) com especificações e capacidade definidas pelo usuário, servindo tanto para servidores web quanto para processamento em segundo plano.
* **Modelo de Cobrança**: Paga-se pelo tempo em que a instância permanece ligada, independentemente de ela estar sendo utilizada a 1% ou 100% da sua capacidade, isso pode ser positivo ou negativo, você pode estar pagando uma infraestrutura mais cara do que realmente precisa.

### **Orquestração: Amazon ECS (Elastic Container Service)**

* **Conceito** : Serviço voltado para orquestração de contêineres Docker, permitindo criar clusters de servidores para evitar pontos únicos de falha. Geralmente é usado em dependencia de instâncias EC2, mas não é obrigatório, da pra usar sem dependere de EC2.
* Prós: Facilita a escalabilidade conforme a demanda (horários de pico versus horários ociosos).
* Contras: Complexidade maior de configuração e início do ***vendor lock-in*** (dependência do ecossistema da AWS).

### **Distribuição de Tráfego: Load Balancer (ALB)**

* **Função** : Distribui requisições/load entre instâncias e destinos variados (EC2, contêineres, Lambdas) para evitar a sobrecarga de uma única máquina.
* **Recursos Avançados**: Atua na camada de aplicação (camada 7), permitindo roteamento inteligente baseado no caminho da URL (ex.: `/produtos` vs `/admin`), terminação SSL e verificação contínua de saúde das instâncias (*health checks*).
* Prós: Routing Avançado, SSL Termination, WebSockets
* Contra: **CUSTO**, Complexidade de configuração

### **Computação sem Servidor de Contêineres: AWS Fargate**

* **Conceito**: Motor de computação *serverless* para contêineres que abstrai completamente o gerenciamento das máquinas virtuais subjacentes.
* **Prós e Contras**: Reduz muito a manutenção operacional, mas o custo por recurso alocado pode ser sensivelmente superior ao de gerenciar suas próprias instâncias EC2.

### **&#x20;Plataforma Gerenciada: AWS Elastic Beanstalk**

* **Conceito (PaaS)**: Plataforma como serviço para deploy ágil de aplicações web tradicionais (Node.js, Django, Spring Boot, Go, etc.).
* Prós: Configuração simples, boa previsibilidade de custos operacionais e provisionamento automático de balanceadores e instâncias.
* Contras: Menos flexível para cenários avançados de arquitetura e atua com comportamento de "caixa-preta".

### **Funções Severless: AWS Lambda**

* **Conceito**: Execução de código por evento com cobrança estritamente pelo tempo e memória consumidos durante cada chamada (*pay-per-use*).
* Prós: Custo mínimo para aplicações com poucas chamadas e escalabilidade automática quase instantânea.
* Contras:
  * *Timeouts* e limite de memória configurável.
  * *Cold starts* (latência na primeira execução após inatividade).
  * **Custo de tempo ocioso (*****idle time*****)**: Se a função gasta 14 segundos apenas aguardando uma API ou banco de dados externo responder, você paga por todo esse tempo de espera, o que pode encarecer a solução se comparada a um servidor convencional.

### **Roteamento de APIs: Amazon API Gateway**

* **Conceito**: Porta de entrada HTTP/REST que recebe o tráfego externo e direciona para endpoints internos, autentica usuários e integra-se diretamente ao AWS Lambda.
* **Trade-offs**: Adiciona uma pequena latência adicional e custos cobrados por quantidade de requisições processadas.

### **Orquestração de Processos: AWS Step Functions**

* **Conceito**: Criação de máquinas de estado visuais para gerenciar fluxos complexos de etapas encadeadas com controle de sucesso, falha e reprocessamento (*retry*).
* Obs: Alto nível de *vendor lock-in*, sendo mais justificável para regras de negócio específicas do que para tarefas simples de mensagens/eventos.

### **Bancos de Dados: RDS e DynamoDB**

* **Amazon RDS**: Instâncias dedicadas a bancos relacionais (SQL) como PostgreSQL e MySQL, trazendo automação de backups e métricas de observabilidade.
* **Amazon DynamoDB**: Banco NoSQL chave-valor altamente performático com escalabilidade global (*Global Tables*) e latência extremamente baixa, cobrado geralmente por leitura/gravação.

### **Serviços Utilitários Essenciais**

* **Amazon SQS**: Serviço de filas assíncronas para desacoplar componentes.
* **Amazon SNS**: Sistema de mensageria no formato Publicador/Assinante (*Pub/Sub*).
* **Amazon CloudWatch**: Monitoramento, alertas e centralização de logs do sistema.
* **AWS Secrets Manager**: Armazenamento seguro de chaves de API, senhas e credenciais.
* **Amazon CloudFront**: Rede de distribuição de conteúdo (CDN) para acelerar a entrega de sites e assets ao redor do mundo.
* **AWS Amplify**: Plataforma para publicação rápida de aplicações *full-stack* e SPAs (como React e Next.js), indicada principalmente para protótipos e MVPs.

