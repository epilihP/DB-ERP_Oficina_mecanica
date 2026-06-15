# Use Cases — Oficina Mecânica

**Versão:** 1.0.0  
**Última atualização:** 2026-06-14  
**Escopo:** Autenticação + CRUD de Clientes + CRUD de Peças

---

## Convenções

- **Ator Principal:** quem inicia o caso de uso
- **Pré-condições:** o que deve ser verdade antes do caso de uso iniciar
- **Fluxo Principal:** caminho feliz (happy path)
- **Fluxos Alternativos:** variações do fluxo principal
- **Fluxos de Exceção:** erros e situações inválidas
- **Pós-condições:** o que é verdade após a execução bem-sucedida

---

## UC-001 — Autenticar Usuário

**Ator Principal:** Qualquer usuário do sistema (Gerente ou Funcionário)  
**Módulo:** Autenticação

### Pré-condições
- Usuário possui cadastro no sistema

### Fluxo Principal
1. Usuário informa email e senha
2. Sistema valida formato dos dados (Zod)
3. Sistema busca usuário pelo email
4. Sistema compara hash da senha informada com hash armazenado (bcrypt)
5. Sistema gera JWT com expiração de 8 horas
6. Sistema retorna o token ao cliente

### Fluxos de Exceção
- **FE-001:** Email não encontrado → HTTP 401 com mensagem genérica (não revelar se email existe)
- **FE-002:** Senha incorreta → HTTP 401 com mensagem genérica

### Pós-condições
- JWT válido emitido para o usuário

---

## UC-002 — Criar Cliente

**Ator Principal:** Gerente, Funcionário  
**Módulo:** Clientes

### Pré-condições
- Usuário autenticado

### Fluxo Principal
1. Usuário informa dados do cliente (nome, tipo PF/PJ, CPF/CNPJ, telefone, email)
2. Sistema valida formato dos dados (Zod)
3. Sistema verifica se o CPF/CNPJ já existe no banco
4. Sistema cria o registro com UUID gerado pela aplicação
5. Sistema retorna o cliente criado com código HTTP 201

### Fluxos Alternativos
- **FA-001:** Cliente pessoa jurídica (PJ) → o CPF/CNPJ informado é um CNPJ

### Fluxos de Exceção
- **FE-001:** Dados inválidos → HTTP 422
- **FE-002:** CPF/CNPJ já cadastrado → HTTP 409 "CPF/CNPJ já cadastrado"

### Pós-condições
- Cliente criado e persistido no banco

---

## UC-003 — Listar, Editar e Remover Clientes

**Ator Principal:** Gerente, Funcionário (remoção: Gerente)  
**Módulo:** Clientes

### Pré-condições
- Usuário autenticado

### Fluxo Principal (Listar)
1. Usuário solicita a lista de clientes
2. Sistema retorna clientes com paginação
3. Usuário pode filtrar por nome ou CPF/CNPJ

### Fluxo Principal (Editar)
1. Usuário informa o id do cliente e os dados a atualizar
2. Sistema valida os dados (Zod)
3. Sistema atualiza o registro e o campo `updatedAt`
4. Sistema retorna o cliente atualizado

### Fluxo Principal (Remover)
1. Gerente solicita a remoção de um cliente pelo id
2. Sistema remove o registro
3. Sistema retorna HTTP 204

### Fluxos de Exceção
- **FE-001:** Cliente não encontrado → HTTP 404
- **FE-002:** Novo CPF/CNPJ já usado por outro cliente → HTTP 409

### Pós-condições
- Lista retornada, ou cliente atualizado/removido conforme a operação

---

## UC-004 — Criar Peça

**Ator Principal:** Gerente, Funcionário  
**Módulo:** Peças

### Pré-condições
- Usuário autenticado

### Fluxo Principal
1. Usuário informa dados da peça (código, descrição, unidade, preço unitário, estoque atual, estoque mínimo)
2. Sistema valida formato dos dados (Zod)
3. Sistema verifica se o código já existe no banco
4. Sistema cria o registro com UUID gerado pela aplicação
5. Sistema retorna a peça criada com código HTTP 201

### Fluxos de Exceção
- **FE-001:** Dados inválidos → HTTP 422
- **FE-002:** Código já cadastrado → HTTP 409 "Código já cadastrado"

### Pós-condições
- Peça criada e persistida no banco

---

## UC-005 — Listar, Editar e Remover Peças

**Ator Principal:** Gerente, Funcionário (remoção: Gerente)  
**Módulo:** Peças

### Pré-condições
- Usuário autenticado

### Fluxo Principal (Listar)
1. Usuário solicita a lista de peças
2. Sistema retorna peças com paginação
3. Usuário pode filtrar por código ou descrição
4. Sistema pode sinalizar peças com estoque atual abaixo do estoque mínimo

### Fluxo Principal (Editar)
1. Usuário informa o id da peça e os dados a atualizar
2. Sistema valida os dados (Zod)
3. Sistema atualiza o registro e o campo `updatedAt`
4. Sistema retorna a peça atualizada

### Fluxo Principal (Remover)
1. Gerente solicita a remoção de uma peça pelo id
2. Sistema remove o registro
3. Sistema retorna HTTP 204

### Fluxos de Exceção
- **FE-001:** Peça não encontrada → HTTP 404
- **FE-002:** Novo código já usado por outra peça → HTTP 409

### Pós-condições
- Lista retornada, ou peça atualizada/removida conforme a operação
