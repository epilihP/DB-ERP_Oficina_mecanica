# 🔧 MechanicOS — ERP/WMS para Oficina Mecânica

> Sistema de gestão completo para oficinas mecânicas com suporte offline-first, sincronização automática e arquitetura modular escalável.

---

## 📋 Índice

- [Visão Geral](#visão-geral)
- [Stack Tecnológica](#stack-tecnológica)
- [Arquitetura](#arquitetura)
- [Módulos](#módulos)
- [Pré-requisitos](#pré-requisitos)
- [Instalação e Execução](#instalação-e-execução)
- [Variáveis de Ambiente](#variáveis-de-ambiente)
- [Estrutura de Pastas](#estrutura-de-pastas)
- [Testes](#testes)
- [Documentação](#documentação)
- [Contribuindo](#contribuindo)

---

## Visão Geral

O **MechanicOS** é um sistema ERP/WMS desenvolvido para o contexto de oficinas mecânicas que operam em ambientes com conectividade instável. O sistema é capaz de funcionar completamente offline por vários dias e sincronizar os dados automaticamente quando a conexão for restabelecida.

### Características Principais

- ✅ **Offline-First** — Opera sem internet por até 7 dias consecutivos
- ✅ **Multiusuário** — Múltiplos terminais simultâneos
- ✅ **Modular** — Módulos independentes e de baixo acoplamento
- ✅ **Escalável** — Arquitetura preparada para crescimento horizontal
- ✅ **Auditável** — Todo evento crítico é rastreado
- ✅ **Observável** — Logs, métricas e tracing integrados

---

## Stack Tecnológica

### Backend
| Tecnologia | Versão | Uso |
|-----------|--------|-----|
| Node.js | 20 LTS | Runtime |
| TypeScript | 5.x | Linguagem |
| Fastify | 4.x | Framework HTTP |
| Prisma | 5.x | ORM / PostgreSQL |
| Zod | 3.x | Validação de schemas |

### Banco de Dados
| Tecnologia | Uso |
|-----------|-----|
| PostgreSQL 16 | Dados relacionais (principal) |
| MongoDB 7 | Dados de auditoria e logs |
| Redis 7 | Cache, sessões, filas |

### Infraestrutura
| Tecnologia | Uso |
|-----------|-----|
| Docker | Containerização |
| Docker Compose | Orquestração local |
| RabbitMQ | Mensageria assíncrona |
| GitHub Actions | CI/CD |

### Frontend *(não prioritário)*
| Tecnologia | Uso |
|-----------|-----|
| React 18 | Interface |
| Redux Toolkit | Estado global |
| Material UI | Componentes |

---

## Arquitetura

O sistema segue os princípios de **Clean Architecture** com **Ports and Adapters**, garantindo que as regras de negócio sejam completamente independentes de frameworks e infraestrutura.

```
┌─────────────────────────────────────────────┐
│                 Interfaces                  │  ← HTTP, WebSocket, CLI
├─────────────────────────────────────────────┤
│               Application                  │  ← Use Cases, DTOs
├─────────────────────────────────────────────┤
│                  Domain                     │  ← Entidades, Regras de Negócio
├─────────────────────────────────────────────┤
│              Infrastructure                 │  ← DB, Redis, RabbitMQ
└─────────────────────────────────────────────┘
```

> Nenhuma regra de negócio depende diretamente de um framework ou banco de dados.

---

## Módulos

| # | Módulo | Status | Descrição |
|---|--------|--------|-----------|
| 1 | **Operacional** | 🔄 Em desenvolvimento | OS, Clientes, Veículos, Agenda |
| 2 | **Estoque/WMS** | ⏳ Backlog | Peças, Movimentações, Fornecedores |
| 3 | **Gestão** | ⏳ Backlog | Dashboard, Relatórios, Usuários |
| 4 | **Financeiro** | ⏳ Backlog | Contas, Fluxo de Caixa, Fiscal |

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
git clone https://github.com/seu-usuario/mechanicos.git
cd mechanicos
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

### 4. Suba a infraestrutura local
```bash
docker compose up -d
```

### 5. Execute as migrations
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
APP_SECRET=sua-chave-secreta-aqui

# PostgreSQL
DATABASE_URL=postgresql://user:password@localhost:5432/mechanicos

# MongoDB
MONGODB_URL=mongodb://localhost:27017/mechanicos_logs

# Redis
REDIS_URL=redis://localhost:6379

# RabbitMQ
RABBITMQ_URL=amqp://localhost:5672

# JWT
JWT_SECRET=seu-jwt-secret
JWT_EXPIRES_IN=8h
JWT_REFRESH_EXPIRES_IN=7d
```

---

## Estrutura de Pastas

```
src/
├── domain/                  # Entidades, interfaces, regras puras de negócio
│   ├── entities/
│   ├── repositories/        # Interfaces (contratos)
│   └── services/            # Domain services
│
├── application/             # Casos de uso, DTOs, orquestradores
│   ├── use-cases/
│   └── dtos/
│
├── infrastructure/          # Implementações concretas
│   ├── database/
│   │   ├── prisma/
│   │   └── mongoose/
│   ├── cache/               # Redis
│   ├── messaging/           # RabbitMQ
│   └── repositories/        # Implementações dos contratos
│
├── interfaces/              # Entrada e saída do sistema
│   ├── http/
│   │   ├── controllers/
│   │   ├── routes/
│   │   ├── middlewares/
│   │   └── schemas/         # Zod schemas para validação
│   └── websocket/
│
├── shared/                  # Utilitários, erros, helpers globais
│   ├── errors/
│   ├── utils/
│   └── types/
│
└── tests/
    ├── unit/
    ├── integration/
    └── e2e/
```

---

## Testes

```bash
# Todos os testes
npm test

# Apenas unitários
npm run test:unit

# Apenas integração
npm run test:integration

# Com cobertura
npm run test:coverage

# E2E
npm run test:e2e
```

**Meta de cobertura:** ≥ 80% em todas as camadas

---

## Documentação

| Documento | Localização |
|-----------|-------------|
| SRS | `docs/project/SRS.md` |
| Arquitetura | `docs/architecture/` |
| ADRs | `docs/architecture/ADR/` |
| Roadmap | `docs/project/ROADMAP.md` |
| Changelog | `docs/skills/CHANGELOG.md` |
| API (Swagger) | `http://localhost:3000/docs` (quando rodando) |

---

## Contribuindo

Este projeto segue um fluxo de desenvolvimento estruturado:

1. Nenhuma funcionalidade sem requisito documentado no SRS
2. Nenhum código sem testes
3. Toda mudança arquitetural registrada em ADR
4. Commits seguem o padrão **Conventional Commits**

```
feat(os): adiciona transição de estado para OS
fix(estoque): corrige cálculo de saldo em movimentação de ajuste
docs(srs): atualiza requisitos do módulo financeiro
test(os): adiciona testes de integração para criação de OS
```

---

*Documentação mantida pela equipe de engenharia. Última atualização: 2026-05-30*
