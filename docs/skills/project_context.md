# project_context.md — Contexto do Projeto

**Versão:** 1.0.0  
**Última atualização:** 2026-05-30  
**⚠️ Arquivo vivo — atualizar a cada decisão arquitetural relevante**

---

## Visão Geral

**Nome do Produto:** MechanicOS  
**Tipo:** ERP/WMS para Oficina Mecânica  
**Característica Crítica:** Offline-First com sincronização posterior

O sistema gerencia o ciclo completo de uma oficina mecânica: desde a entrada do veículo, execução dos serviços, consumo de peças, até o faturamento e controle financeiro. Opera em ambientes com internet instável, podendo funcionar por até 7 dias sem conexão.

---

## Stack Completa

### Backend
| Camada | Tecnologia | Versão |
|--------|-----------|--------|
| Runtime | Node.js | 20 LTS |
| Linguagem | TypeScript | 5.x |
| Framework HTTP | Fastify | 4.x |
| ORM Principal | Prisma | 5.x |
| ODM (MongoDB) | Mongoose | 8.x |
| Validação | Zod | 3.x |
| Testes | Vitest | Latest |

### Infraestrutura
| Tecnologia | Uso |
|-----------|-----|
| PostgreSQL 16 | Dados transacionais |
| MongoDB 7 | Logs de auditoria, eventos |
| Redis 7 | Cache, rate limiting, filas |
| RabbitMQ 3 | Mensageria assíncrona |
| Docker | Containerização |
| Docker Compose | Orquestração local |
| GitHub Actions | CI/CD |

---

## Arquitetura

### Padrão: Clean Architecture + Ports and Adapters

```
src/
├── domain/           # NÚCLEO — sem dependências externas
│   ├── entities/     # Entidades com comportamento de negócio
│   ├── repositories/ # Interfaces (contratos/portas)
│   └── services/     # Domain services (regras que envolvem múltiplas entidades)
│
├── application/      # ORQUESTRAÇÃO — depende apenas do domain
│   ├── use-cases/    # Um arquivo por caso de uso
│   └── dtos/         # Objetos de transferência de dados
│
├── infrastructure/   # ADAPTADORES — implementações concretas
│   ├── database/
│   │   ├── prisma/   # Implementações de repositório com Prisma
│   │   └── mongoose/ # Implementações com Mongoose
│   ├── cache/        # Redis
│   └── messaging/    # RabbitMQ
│
├── interfaces/       # ENTRADA/SAÍDA do sistema
│   ├── http/
│   │   ├── controllers/
│   │   ├── routes/
│   │   ├── middlewares/
│   │   └── schemas/  # Zod schemas para validação de request/response
│   └── websocket/
│
└── shared/           # UTILITÁRIOS transversais
    ├── errors/       # Hierarquia de erros customizados
    ├── utils/
    └── types/
```

### Princípio de Dependência

```
interfaces → application → domain ← infrastructure
                                          ↑
                                   (implementa contratos do domain)
```

**Regra de ouro:** Nenhum arquivo em `domain/` pode importar de `infrastructure/`, `interfaces/` ou qualquer framework.

---

## Decisões Arquiteturais Registradas

| ADR | Decisão | Status |
|-----|---------|--------|
| ADR-001 | UUID v4 como identificador universal | ✅ Aceito |
| ADR-002 | Fastify como framework HTTP principal | ✅ Aceito |
| ADR-003 | Estratégia offline-first com event sourcing leve | ✅ Aceito |

---

## Módulos do Sistema

| Módulo | Status | Sprint Alvo |
|--------|--------|-------------|
| Operacional (OS, Clientes, Veículos) | ⏳ Planejado | Sprint 1–6 |
| Estoque/WMS | ⏳ Planejado | Sprint 7–9 |
| Gestão (Dashboard, Relatórios) | ⏳ Planejado | Sprint 10–11 |
| Financeiro | ⏳ Planejado | Sprint 12–14 |

---

## Convenções Críticas

1. **Identificadores:** Sempre UUID v4 — nunca auto-increment
2. **Timestamps:** Sempre em UTC — `new Date()` → sempre UTC no Node.js
3. **Deleção:** Sempre soft delete — campo `deletedAt: DateTime?`
4. **Versionamento de entidades:** Campo `version: Int` para controle otimista
5. **Erros:** Sempre `AppError` ou subclasses — nunca `throw new Error()`
6. **Logs:** Sempre estruturados via logger do Fastify — nunca `console.log`
7. **Validação:** Sempre Zod no boundary de entrada (controllers) antes de chegar no use case

---

## Contexto de Negócio

### Perfis de Usuário
| Perfil | Pode fazer |
|--------|-----------|
| ADMIN | Tudo |
| RECEPCIONISTA | OS, Clientes, Veículos, Agenda |
| MECANICO | Execução de OS, Registro de horas |
| ALMOXARIFE | Estoque, Movimentações, Inventário |
| FINANCEIRO | Contas, Relatórios financeiros |

### Fluxo Principal de Negócio
```
Cliente chega → OS aberta → Diagnóstico → Aprovação →
Execução → Peças consumidas → Conclusão → Faturamento → Pagamento
```

### Estados da OS
```
RASCUNHO → ABERTA → EM_EXECUCAO → AGUARDANDO_PECA → CONCLUIDA → FATURADA
                                                                      ↓
                              CANCELADA ←─────────────────────────────
```
