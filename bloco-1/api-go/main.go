package main

// a lib encoding/json tranforma a struct em json e o inverso, json em struct
import (
	"encoding/json"
	"fmt"
	"net/http"
)

// Em go o bloco "struct" modela os dados (equivalente a classes/objetos)
// struct tags (json tags)como mapear os campos do Go para as chaves do json

// campos de uma struct que começam com letra maiuscula são publicos (exportados). Se começam com minusculas
// ficam privados dentro do pacote e o conversor de json não consegue enxerga-los
type Task struct {
	ID        int    `json:"id"`
	Titulo    string `json:"titulo"`
	Concluida bool   `json:"concluida"`
} // As anotações entre crases dizem ao Go como esses campos deve se chamar quando forem convertidas para json

// Armazenamento em memória, pra usar no exemplo e não depender de um banco de dados por enquanto
// Essa "Slice" - Array dinâmico do GO e uma variavel para simular um auto-incremento de ID
var (
	task   = []Task{}
	nextID = 1
)

func tasksHandler(w http.ResponseWriter, r *http.Request) {
	// Sempre informamos ao cliente que a resposta é JSON
	w.Header().Set("Content-Type", "application/json")

	switch r.Method {
	case http.MethodGet:
		// Serializa o slice 'tasks' para json e escreve direto na resposta
		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(task)
	case http.MethodPost:
		var novaTask Task

		// Lê o JSON do corpo da requisição e preenche a variável 'novaTask'
		// Passamos &novaTask (ponteiro) para o decoder alterar o valor da struct
		err := json.NewDecoder(r.Body).Decode(&novaTask)
		if err != nil {
			w.WriteHeader(http.StatusBadRequest)
			json.NewEncoder(w).Encode(map[string]string{"erro": "Palyad JSON inválido"})
			return
		}

		// Atribui ID e adiciona ao slice
		novaTask.ID = nextID
		nextID++
		task = append(task, novaTask)

		//Retorna 201 Created com task criada
		w.WriteHeader(http.StatusCreated)
		json.NewEncoder(w).Encode(novaTask)

	default:
		// Se chamarem com PUT, DELETE, ou qualquer outro método não tratado aqui
		w.WriteHeader(http.StatusMethodNotAllowed)
		json.NewEncoder(w).Encode(map[string]string{"erro": "Método não permitido"})
	}

}

// Exemplo
func healthCheck(w http.ResponseWriter, r *http.Request) {
	// w (responseWriter) é onde escreve o corpo da resposta e headers
	// r (Request) contém os dados da requisição recebida (método, headers, body, URL)
	w.WriteHeader(http.StatusOK)
	fmt.Fprintf(w, "API online!")
}

func main() {
	// Associa o caminho "/" à função healtCheck
	http.HandleFunc("/health", healthCheck)
	http.HandleFunc("/tasks", tasksHandler)
	fmt.Println("Servidor rodando em http://localhost:8080")

	// sobe um servidor na porta 8080. Se falhar encerra com log de erro
	err := http.ListenAndServe(":8080", nil)
	if err != nil {
		fmt.Printf("Erro ao iniciar servidor: %v\n", err)
	}
}
