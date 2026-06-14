# Sprint Backlog — Sprint 0

**Sprint Goal:** Estabelecer base técnica e documental para que o time possa desenvolver features de negócio com qualidade, segurança e rastreabilidade.

**Período:** 2026-05-30 → 2026-06-13 (2 semanas)  
**Capacidade:** A definir com o time  
**Status:** 🔄 Em andamento

---

## Sprint Goal (detalhado)

> Ao final desta sprint, o projeto deve ter toda a documentação inicial criada, um ambiente de desenvolvimento funcional via Docker Compose, a estrutura de pastas do projeto configurada, TypeScript e Fastify rodando, Prisma conectado ao banco, e um pipeline CI/CD básico no GitHub Actions. Qualquer desenvolvedor deve conseguir clonar o repo e subir o ambiente com dois comandos.

---

## Itens da Sprint

| ID | Descrição | Pontos | Status | Responsável |
|----|-----------|--------|--------|-------------|
| PB-DOC-01 | SRS completo | 3 | ✅ Concluído | Engenharia |
| PB-DOC-02 | README do projeto | 2 | ✅ Concluído | Engenharia |
| PB-DOC-03 | ADRs 001, 002 e 003 | 3 | ✅ Concluído | Engenharia |
| PB-DOC-04 | Roadmap | 2 | ✅ Concluído | Engenharia |
| PB-DOC-05 | Product Backlog | 3 | ✅ Concluído | Engenharia |
| PB-DOC-06 | Skills files | 2 | ✅ Concluído | Engenharia |
| PB-001 | Docker Compose (infra local) | 5 | 🟡 Próximo | Dev |
| PB-002 | Setup TypeScript + Fastify | 3 | 🟡 Próximo | Dev |
| PB-003 | Setup Prisma + schema base | 5 | 🟡 Próximo | Dev |
| PB-004 | GitHub Actions CI básico | 3 | ⏳ Backlog | Dev |

**Total:** 31 pontos

---

## Tarefas Técnicas (Tasks) por Item

### PB-001 — Docker Compose

- [ ] Criar `docker-compose.yml` com serviços: postgres, mongodb, redis, rabbitmq
- [ ] Criar `docker-compose.override.yml` para configurações de dev
- [ ] Criar `.env.example` com todas as variáveis documentadas
- [ ] Testar conexão de cada serviço
- [ ] Documentar no README

### PB-002 — Setup TypeScript + Fastify

- [ ] Inicializar projeto Node.js (`npm init`)
- [ ] Instalar dependências: `fastify`, `typescript`, `@types/node`, `tsx`, `tsup`
- [ ] Criar `tsconfig.json` com `strict: true`
- [ ] Criar estrutura de pastas (`src/domain`, `src/application`, etc.)
- [ ] Implementar `src/interfaces/http/server.ts` com Fastify básico
- [ ] Implementar `GET /health` com status do banco
- [ ] Configurar scripts no `package.json`: `dev`, `build`, `start`, `lint`
- [ ] Configurar ESLint + Prettier

### PB-003 — Setup Prisma

- [ ] Instalar `prisma` e `@prisma/client`
- [ ] Inicializar Prisma (`npx prisma init`)
- [ ] Criar schema com entidades: `User`, `AuditLog`
- [ ] Criar primeira migration
- [ ] Criar seed básico (usuário admin)
- [ ] Documentar comandos no README

### PB-004 — GitHub Actions

- [ ] Criar `.github/workflows/ci.yml`
- [ ] Etapa: `lint`
- [ ] Etapa: `type-check`
- [ ] Etapa: `test`
- [ ] Etapa: `build`

---

## Impedimentos

*Nenhum no momento.*

---

## Retrospectiva (a ser preenchida ao final da sprint)

### O que foi bem?

*(preencher ao final)*

### O que pode melhorar?

*(preencher ao final)*

### Ações para próxima sprint

*(preencher ao final)*
