# process.md — Processos de Desenvolvimento

**Versão:** 1.0.0  
**Última atualização:** 2026-06-14

---

## 1. Fluxo de Desenvolvimento

Nenhuma funcionalidade é implementada sem passar por todas as etapas abaixo, nesta ordem:

```
1. PLANEJAMENTO      → O quê vamos construir? Está no backlog?
        ↓
2. REFINAMENTO       → Por que vamos construir? Critérios de aceite claros?
        ↓
3. DOCUMENTAÇÃO      → SRS, use case, ADR (se decisão arquitetural)
        ↓
4. MODELAGEM         → Como os dados serão estruturados? Schema Prisma?
        ↓
5. ARQUITETURA       → Como as camadas se organizam? Interfaces definidas?
        ↓
6. ISSUES            → Tarefa criada no GitHub Issues com contexto completo
        ↓
7. IMPLEMENTAÇÃO     → Código escrito seguindo code_style.md
        ↓
8. TESTES            → Unitários + integração antes do PR
        ↓
9. CODE REVIEW       → PR aberto, revisão estruturada (tech lead)
        ↓
10. DEPLOY           → Merge em main, CI passa, deploy em staging
```

---

## 2. Cerimônias Scrum

### Sprint Planning (início de cada sprint)
**Duração:** ~1 hora  
**Participantes:** Tech Lead + Dev  
**Agenda:**
1. Revisão da Sprint Goal
2. Seleção de itens do Product Backlog
3. Breakdown em tasks técnicas
4. Estimativa (Planning Poker / Fibonacci)
5. Confirmação de capacidade

### Daily Standup (simulado a cada sessão)
**Formato:**
- O que foi feito desde a última sessão?
- O que vou fazer nesta sessão?
- Há algum impedimento?

### Sprint Review (fim de cada sprint)
**Formato:**
- Demo das funcionalidades entregues
- Atualização do changelog
- Atualização do Product Backlog

### Sprint Retrospectiva (fim de cada sprint)
**Formato (Start / Stop / Continue):**
- Start: O que deveríamos começar a fazer?
- Stop: O que deveríamos parar de fazer?
- Continue: O que está funcionando bem?

---

## 3. Fluxo de Git

### Branches

```
main              ← Produção — sempre estável
  └─ develop      ← Integração contínua
       └─ feat/clientes-crud         ← Feature branch
       └─ fix/peca-codigo-duplicado
       └─ chore/update-dependencies
       └─ docs/adr-004
```

### Nomenclatura de Branches

```
feat/<escopo>-<descricao-curta>
fix/<escopo>-<descricao-curta>
chore/<descricao-curta>
docs/<descricao-curta>
test/<escopo>-<descricao-curta>
refactor/<escopo>-<descricao-curta>
```

Exemplos:
```
feat/clientes-crud
feat/auth-jwt-login
fix/peca-codigo-duplicado
docs/adr-004-estrategia-cache
```

### Pull Request

Todo PR deve ter:
- [ ] Título no formato Conventional Commits
- [ ] Descrição: o quê, por quê, como testar
- [ ] Referência à issue (`Closes #42`)
- [ ] CI passando (lint + tests + build)
- [ ] Sem conflitos com a branch base

### Proteção da Main

- Nenhum commit direto na `main`
- Todo merge requer PR com CI verde
- Squash merge para manter histórico limpo

---

## 4. Padrão de Issue no GitHub

```markdown
## Contexto
Breve descrição do problema ou funcionalidade.

## Critérios de Aceite
- [ ] Critério 1
- [ ] Critério 2
- [ ] Critério 3

## Notas Técnicas
Referências a ADRs, use cases, ou decisões técnicas relevantes.

## Definition of Ready
- [ ] Requisito documentado no SRS
- [ ] Use case definido
- [ ] Estimativa de pontos
- [ ] Sem dependências bloqueantes
```

---

## 5. Política de Qualidade

### O que NUNCA deve ir para main

- Código com erros de TypeScript (`tsc --noEmit` falhando)
- Código com erros de lint
- Testes falhando
- Cobertura de testes < 80% em código novo
- `console.log` em código de produção
- Credenciais ou segredos commitados
- `TODO` sem issue vinculada

### Checklist de Code Review

**Arquitetura:**
- [ ] Respeitou a separação modular (`modules/`, `shared/`, `lib/`)?
- [ ] Regras de acesso ao banco isoladas no `*.service.ts`?
- [ ] Validação Zod no `*.schema.ts`?

**Código:**
- [ ] Nomenclatura consistente com o restante do projeto?
- [ ] Erros customizados (AppError) em vez de Error genérico?
- [ ] Logs estruturados sem dados sensíveis?
- [ ] Sem lógica de negócio na rota (controller)?

**Testes:**
- [ ] Unitários para lógica de domínio?
- [ ] Integração para fluxo de controller → banco?
- [ ] Cenário de erro testado?

**Segurança:**
- [ ] Entrada validada com Zod antes de chegar no use case?
- [ ] Autorização verificada?
- [ ] Dados sensíveis nunca expostos na resposta?

---

## 6. Versionamento Semântico

O projeto segue [SemVer](https://semver.org/):

```
MAJOR.MINOR.PATCH

MAJOR — mudança incompatível na API
MINOR — nova funcionalidade retrocompatível
PATCH — correção de bug retrocompatível
```

Exemplos:
- `0.1.0` → Autenticação e perfis
- `0.2.0` → CRUD de Clientes
- `0.3.0` → CRUD de Peças
- `1.0.0` → Sistema completo (CRUD + login) estável
