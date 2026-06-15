# Roadmap — Oficina Mecânica

**Última atualização:** 2026-06-14  
**Metodologia:** Scrum — Sprints de 2 semanas

---

## Visão Geral

```
Sprint 0        Sprint 1        Sprint 2        Sprint 3        Sprint 4
Fundação    ──► Autenticação ─► CRUD        ──► CRUD        ──► Testes e
e modelagem     e perfis        Clientes        Peças           estabilização
```

O escopo é deliberadamente enxuto: o foco é a modelagem do banco de dados relacional e um CRUD bem feito sobre ela (Clientes e Peças), com login por perfis.

---

## Sprint 0 — Fundação e Modelagem (Atual)
**Status:** Em andamento  
**Objetivo:** Estabelecer base técnica e a modelagem do banco antes do código de negócio

### Entregáveis
- [x] SRS (Software Requirements Specification)
- [x] README do projeto
- [x] ADR-001: UUID como identificador
- [x] ADR-002: Fastify como framework
- [x] ADR-003: PostgreSQL como banco único
- [x] Roadmap
- [x] Product Backlog inicial
- [ ] Estrutura de pastas do projeto
- [ ] Docker Compose com PostgreSQL
- [ ] Configuração TypeScript (tsconfig.json)
- [ ] Setup do Prisma com schema inicial (Usuario, Cliente, Peca)
- [ ] Pipeline CI/CD básico (GitHub Actions)
- [ ] Health check endpoint

---

## Sprint 1 — Autenticação e Perfis
**Dependências:** Sprint 0 concluída

- Setup de autenticação JWT
- Login com perfis GERENTE e FUNCIONARIO
- Hash de senha com bcrypt
- Middleware de autenticação e autorização
- Seed do usuário gerente padrão

---

## Sprint 2 — CRUD de Clientes
**Dependências:** Sprint 1 concluída

- CRUD completo de Clientes (PF/PJ)
- Validação de dados com Zod
- Unicidade de CPF/CNPJ
- Listagem com paginação e filtros (nome, CPF/CNPJ)

---

## Sprint 3 — CRUD de Peças
**Dependências:** Sprint 2 concluída

- CRUD completo de Peças
- Unicidade de código
- Controle de estoque atual e estoque mínimo
- Listagem com paginação e filtros (código, descrição)

---

## Sprint 4 — Testes e Estabilização
**Dependências:** Sprints 1–3 concluídas

- Cobertura de testes ≥ 80%
- Revisão de performance das queries
- Documentação de API (Swagger/OpenAPI)
