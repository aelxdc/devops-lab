Aqui está um modelo de `README.md` simples, direto e pronto para documentar a sua API:

```markdown
# E-Commerce Orders API

API RESTful desenvolvida com **FastAPI**, **SQLAlchemy** e **PostgreSQL**, estruturada para práticas de DevOps com suporte a fila assíncrona via **Redis** e **RQ Worker**.

---

## ⚙️ Variáveis de Ambiente (.env)

Antes de executar a aplicação, crie um arquivo chamado `.env` na raiz do projeto com as credenciais de acesso ao banco de dados e serviços:

```env
DBUSER=postgres
DBPASS=suasenha123
DBDB=ecommerce_db
DBURL=postgresql+psycopg2://${DBUSER}:${DBPASS}@postgres:5432/${DBDB}
REDIS_URL=redis://redis:6379/0

```

---

## 🚀 Executando com Docker Compose

Suba a API, o banco PostgreSQL, o Redis e o Worker com um único comando:

```bash
docker compose up -d --build

```

A API estará disponível em: `http://localhost:8000`

Documentação interativa Swagger: `http://localhost:8000/docs`

---

## 📡 Endpoints da API

### 🏥 Healthcheck

* **`GET /health`**
* Verifica a conectividade real com o PostgreSQL e o Redis.
* **Retornos:** `200 OK` (Healthy) ou `503 Service Unavailable` (Unhealthy).



---

### 👤 Clientes (`/customers/`)

#### 1. Cadastrar Cliente

* **Método:** `POST /customers/`
* **Exemplo de Corpo (JSON):**
```json
{
  "name": "Maria Silva",
  "email": "maria.silva@exemplo.com",
  "status": "active"
}

```


* **Retorno:** `201 Created`

#### 2. Listar Clientes

* **Método:** `GET /customers/?skip=0&limit=100`
* **Retorno:** `200 OK` (Array com a lista de clientes cadastrados).

#### 3. Obter Detalhes de um Cliente

* **Método:** `GET /customers/{customer_id}`
* **Retorno:** `200 OK` (Dados do cliente e lista de pedidos associados).

---

### 📦 Pedidos (`/orders/`)

#### 1. Criar Pedido

* **Método:** `POST /orders/`
* **Descrição:** Cria o pedido no banco e enfileira uma tarefa no Redis para processamento assíncrono pelo worker.
* **Exemplo de Corpo (JSON):**
```json
{
  "customer_id": 1,
  "description": "Teclado Mecânico e Mousepad",
  "total_amount": 250.50
}

```


* **Retorno:** `201 Created`

#### 2. Listar Pedidos

* **Método:** `GET /orders/?skip=0&limit=100`
* **Retorno:** `200 OK` (Array com os pedidos).

#### 3. Editar Status do Pedido

* **Método:** `PATCH /orders/{order_id}/status`
* **Descrição:** Atualiza a situação de um pedido existente (`pendente`, `processando`, `enviado`, `entregue`, `cancelado`).
* **Exemplo de Corpo (JSON):**
```json
{
  "status": "enviado"
}

```


* **Retorno:** `200 OK` (Objeto do pedido atualizado).

```

```