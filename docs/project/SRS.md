# SRS — Software Requirements Specification
## Oficina Mecânica — Sistema de Modelagem de Banco de Dados

**Versão:** 1.0.0  
**Data:** 2026-06-14  
**Status:** Em elaboração  
**Autor:** Equipe de Engenharia

---

## 1. Introdução

### 1.1 Propósito

Este documento descreve os requisitos funcionais e não funcionais de um sistema acadêmico cujo objetivo principal é **modelar um banco de dados relacional** para o domínio de uma oficina mecânica. Sobre essa base de dados é construído um sistema mínimo, porém competente, que demonstra na prática como os dados são acessados e manipulados por meio de um CRUD.

### 1.2 Escopo

O sistema cobre os seguintes domínios, em ordem de prioridade de desenvolvimento:

1. **Autenticação** — Login com dois perfis de acesso (Gerente e Funcionário)
2. **Clientes** — Cadastro, listagem, edição e remoção de clientes (PF/PJ)
3. **Peças** — Cadastro, listagem, edição e remoção de peças do estoque

O sistema é deliberadamente simples: não há ordens de serviço, veículos, agenda, módulo financeiro, emissão fiscal, operação offline ou integrações externas. O valor do trabalho está na **modelagem do banco** e em um CRUD bem feito sobre ela.

### 1.3 Definições e Siglas

| Sigla | Significado |
|-------|-------------|
| ERP | Enterprise Resource Planning |
| UUID | Universally Unique Identifier |
| JWT | JSON Web Token |
| PF | Pessoa Física |
| PJ | Pessoa Jurídica |
| CRUD | Create, Read, Update, Delete |

---

## 2. Visão Geral do Sistema

### 2.1 Perspectiva do Produto

Sistema web (API REST) que roda contra um único banco de dados relacional PostgreSQL. O foco do trabalho é a modelagem relacional bem estruturada; o sistema de cadastro existe para exercitar essa modelagem.

### 2.2 Usuários do Sistema

| Perfil | Responsabilidades |
|--------|-------------------|
| Gerente | Acesso total: gerencia usuários, clientes e peças |
| Funcionário | Cadastra e consulta clientes e peças |

### 2.3 Restrições Gerais

- Toda entidade deve usar **UUID v4** como identificador primário
- O timestamp de todas as operações deve ser armazenado em **UTC**
- O sistema utiliza um **único banco de dados** (PostgreSQL), sem bancos auxiliares ou mensageria

---

## 3. Requisitos Funcionais

### 3.1 Módulo de Autenticação

#### RF-AUTH-001 — Login de Usuário
- O sistema deve permitir autenticação via email/senha com emissão de JWT
- Senhas devem ser armazenadas com hash (bcrypt), nunca em texto puro
- O sistema deve diferenciar os perfis GERENTE e FUNCIONARIO

#### RF-AUTH-002 — Controle de Acesso por Perfil
- O perfil GERENTE tem acesso total (usuários, clientes e peças)
- O perfil FUNCIONARIO pode cadastrar e consultar clientes e peças
- Rotas protegidas devem rejeitar requisições sem JWT válido (HTTP 401)

### 3.2 Módulo de Clientes

#### RF-CLI-001 — Cadastro de Clientes
- O sistema deve permitir cadastro, edição, consulta e remoção de clientes (PF e PJ)
- Campos: nome, tipo (PF/PJ), CPF/CNPJ, telefone, email
- O campo `cpfCnpj` deve ser único no sistema

#### RF-CLI-002 — Listagem de Clientes
- O sistema deve listar clientes com paginação
- Deve ser possível filtrar por nome e por CPF/CNPJ

### 3.3 Módulo de Peças

#### RF-PEC-001 — Cadastro de Peças
- O sistema deve permitir cadastro, edição, consulta e remoção de peças do estoque
- Campos: código, descrição, unidade, preço unitário, estoque atual, estoque mínimo
- O campo `codigo` deve ser único no sistema

#### RF-PEC-002 — Listagem de Peças
- O sistema deve listar peças com paginação
- Deve ser possível filtrar por código e por descrição
- O sistema pode sinalizar peças com `estoqueAtual` abaixo do `estoqueMinimo`

---

## 4. Requisitos Não Funcionais

### 4.1 Performance

- **RNF-001:** Tempo de resposta de APIs < 200ms para operações simples (p95)
- **RNF-002:** Listagens paginadas com máximo 100 registros por página

### 4.2 Segurança

- **RNF-003:** Senhas armazenadas com bcrypt (salt rounds ≥ 12)
- **RNF-004:** JWT com expiração de 8 horas
- **RNF-005:** Todas as entradas validadas com Zod antes de chegar na camada de serviço
- **RNF-006:** Logs não devem conter dados sensíveis (senhas, tokens, CPF/CNPJ)

### 4.3 Observabilidade

- **RNF-007:** Logs estruturados em formato JSON
- **RNF-008:** Health check endpoint `GET /health` com status do banco de dados

---

## 5. Restrições Técnicas

- Backend: Node.js 20 + TypeScript 5 + Fastify 4
- ORM: Prisma 5 (PostgreSQL 16 — banco único)
- Validação: Zod 3
- Infraestrutura local: Docker Compose (PostgreSQL)
- CI/CD: GitHub Actions

---

## 6. Critérios de Aceite Globais

- [ ] Toda funcionalidade deve ter testes unitários com cobertura ≥ 80%
- [ ] Toda rota deve ter validação de entrada tipada (Zod)
- [ ] O sistema deve inicializar via Docker Compose com um único comando
- [ ] A modelagem do banco deve usar UUID, campos únicos e timestamps
