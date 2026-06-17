# Oficina Mecânica — Sistema de Modelagem de Banco de Dados

> Projeto acadêmico de modelagem de banco de dados relacional para uma oficina mecânica. O foco é demonstrar uma base de dados bem estruturada com um sistema simples de cadastro (CRUD) de clientes e peças e controle de acesso por login.

---

## Índice

- [Objetivo do Projeto](#objetivo-do-projeto)
- [Escopo](#escopo)
- [Stack Tecnológica](#stack-tecnológica)
- [Modelo de Dados](#modelo-de-dados)
- [Perfis de Acesso](#perfis-de-acesso)
- [Pré-requisitos](#pré-requisitos)
- [Instalação e Execução](#instalação-e-execução)
- [Variáveis de Ambiente](#variáveis-de-ambiente)
- [Estrutura de Pastas](#estrutura-de-pastas)
- [Documentação](#documentação)

---

## Objetivo do Projeto

Este é um trabalho acadêmico cujo objetivo principal é **modelar um banco de dados relacional** para o domínio de uma oficina mecânica. Sobre essa base de dados, é construído um sistema mínimo, porém competente, que demonstra na prática como os dados são acessados e manipulados.

O sistema entrega:

- **Login** com dois perfis de acesso: **Gerente** e **Funcionário**
- **CRUD de Clientes** — cadastrar, listar, editar e remover clientes
- **CRUD de Peças** — cadastrar, listar, editar e remover peças do estoque

O sistema é deliberadamente simples: não há módulos financeiros, ordens de serviço, sincronização offline ou integrações externas. O valor do trabalho está na **modelagem do banco** e em um CRUD bem feito sobre ela.

---

## Escopo

### Dentro do escopo
- Modelagem relacional das entidades principais (Usuário, Cliente, Peça)
- Autenticação por login com dois perfis (Gerente e Funcionário)
- CRUD completo de Clientes
- CRUD completo de Peças

### Fora do escopo
- Ordens de serviço, veículos e agenda
- Módulo financeiro e emissão fiscal
- Operação offline e sincronização
- Relatórios avançados e dashboards

---

## Stack Tecnológica

| Camada | Tecnologia | Uso |
|--------|-----------|-----|
| Runtime | Node.js 20 LTS | Execução do backend |
| Linguagem | TypeScript 5.x | Tipagem estática |
| Framework HTTP | Fastify 4.x | API REST |
| Banco de Dados | PostgreSQL 16 | Banco relacional único |
| ORM | Prisma 5.x | Acesso e modelagem do banco |
| Validação | Zod 3.x | Validação de entrada |
| Infra local | Docker Compose | Subir o PostgreSQL |

> Banco único (PostgreSQL). O foco do trabalho é a modelagem relacional, então não há necessidade de bancos auxiliares ou mensageria.

---

## Modelo de Dados

Modelo conceitual (DER): [`docs/database/MODELO-CONCEITUAL.md`](docs/database/MODELO-CONCEITUAL.md).

```
┌────────────────────┐
│      Usuario       │
├────────────────────┤
│ id (uuid) PK       │
│ nome               │
│ email (único)      │
│ senhaHash          │
│ perfil             │  → GERENTE | FUNCIONARIO
│ createdAt          │
│ updatedAt          │
└────────────────────┘

┌────────────────────┐
│      Cliente       │
├────────────────────┤
│ id (uuid) PK       │
│ nome               │
│ tipo               │  → PF | PJ
│ cpfCnpj (único)    │
│ telefone           │
│ email              │
│ createdAt          │
│ updatedAt          │
└────────────────────┘

┌────────────────────┐
│        Peca        │
├────────────────────┤
│ id (uuid) PK       │
│ codigo (único)     │
│ descricao          │
│ unidade            │
│ precoUnitario      │
│ estoqueAtual       │
│ estoqueMinimo      │
│ createdAt          │
│ updatedAt          │
└────────────────────┘
```

> As entidades `Cliente` e `Peca` são independentes neste escopo. A modelagem prioriza clareza e boas práticas (chaves UUID, campos únicos, timestamps).

---

## Perfis de Acesso

| Perfil | Permissões |
|--------|-----------|
| **Gerente** | Acesso total: gerencia usuários, clientes e peças |
| **Funcionário** | Cadastra e consulta clientes e peças |

---

## Pré-requisitos

```bash
node >= 20.0.0
npm >= 10.0.0
docker >= 24.0.0
docker compose >= 2.20.0
```

---

## Instalação e Execução

### 1. Clone o repositório
```bash
git clone https://github.com/seu-usuario/oficina-mecanica.git
cd oficina-mecanica
```

### 2. Instale as dependências
```bash
npm install
```

### 3. Configure as variáveis de ambiente
```bash
cp .env.example .env
# Edite o arquivo .env com suas configurações
```

### 4. Suba o banco de dados
```bash
docker compose up -d
```

### 5. Execute as migrations e o seed
```bash
npm run db:migrate
npm run db:seed
```

### 6. Inicie o servidor
```bash
# Desenvolvimento
npm run dev

# Produção
npm run build && npm run start
```

---

## Variáveis de Ambiente

```env
# Aplicação
NODE_ENV=development
PORT=3000

# PostgreSQL
DATABASE_URL=postgresql://user:password@localhost:5432/oficina

# JWT (autenticação)
JWT_SECRET=seu-jwt-secret
JWT_EXPIRES_IN=8h
```

---
 
## Estrutura de Pastas

```
src/
├── modules/                 # Um módulo por área de negócio
│   ├── auth/                # login, JWT, hash de senha
│   ├── clientes/            # CRUD de clientes
│   └── pecas/               # CRUD de peças
│       ├── *.routes.ts      # rotas Fastify
│       ├── *.service.ts     # regras de acesso ao banco
│       └── *.schema.ts      # validação Zod
│
├── shared/
│   ├── errors/              # AppError + handler global
│   └── plugins/             # autenticação / autorização
│
├── lib/                     # cliente Prisma e variáveis de ambiente
├── app.ts                   # monta o Fastify e registra os módulos
└── server.ts                # inicia o servidor

prisma/
├── schema.prisma            # Modelagem do banco de dados
└── seed.ts                  # usuário gerente padrão
```

---

## Documentação

| Documento | Localização |
|-----------|-------------|
| SRS (Requisitos) | `docs/project/SRS.md` |
| Casos de Uso | `docs/project/USE_CASES.md` |
| Roadmap | `docs/project/ROADMAP.md` |
| Product Backlog | `docs/project/PRODUCT_BACKLOG.md` |
| Decisões de Arquitetura | `docs/architecture/` |

---

*Projeto acadêmico de modelagem de banco de dados. Última atualização: 2026-06-14*
