# changelog.md — Registro de Mudanças

**⚠️ Arquivo vivo — atualizar a cada commit relevante**

---

## Formato

```
## [versão] — YYYY-MM-DD

### Adicionado
- Descrição do que foi adicionado

### Alterado
- Descrição do que foi alterado

### Corrigido
- Descrição do que foi corrigido

### Removido
- Descrição do que foi removido

### Próximos Passos
- O que vem a seguir
```

---

## [0.1.0] — 2026-05-30 — Sprint 0: Documentação Inicial

### Adicionado

**Documentação do Projeto:**
- `docs/project/SRS.md` — Especificação de Requisitos completa com módulos Operacional, Estoque, Gestão e Financeiro
- `docs/project/README.md` — README principal do projeto com stack, estrutura e instruções
- `docs/project/ROADMAP.md` — Roadmap completo Sprint 0 até fase Financeiro
- `docs/project/PRODUCT_BACKLOG.md` — Backlog inicial com épicos e user stories
- `docs/project/SPRINT_BACKLOG.md` — Sprint 0 com tasks detalhadas

**Decisões Arquiteturais (ADRs):**
- `docs/architecture/ADR/ADR-001-uuid-como-identificador.md` — UUID v4 obrigatório para offline-first
- `docs/architecture/ADR/ADR-002-fastify-como-framework.md` — Fastify sobre Express
- `docs/architecture/ADR/ADR-003-estrategia-offline-sync.md` — Event sourcing leve para sincronização

**Skills Files:**
- `docs/skills/code_style.md` — Padrões de nomenclatura, organização, commits e testes
- `docs/skills/project_context.md` — Contexto e arquitetura do projeto
- `docs/skills/changelog.md` — Este arquivo
- `docs/skills/learning_log.md` — Log de aprendizado
- `docs/skills/testing_strategy.md` — Estratégia de testes
- `docs/skills/mentorship_rules.md` — Dinâmica de mentoria

### Próximos Passos

Sprint 0 — Implementação da base técnica:
- [ ] Criar estrutura de pastas do projeto (`src/`)
- [ ] Configurar `docker-compose.yml` com todos os serviços
- [ ] Configurar TypeScript (`tsconfig.json`) com `strict: true`
- [ ] Instalar e configurar Fastify com health check
- [ ] Instalar e configurar Prisma com schema base
- [ ] Configurar ESLint + Prettier
- [ ] Criar GitHub Actions CI básico
