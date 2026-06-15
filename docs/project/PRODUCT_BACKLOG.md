# Product Backlog — Oficina Mecânica

**Última atualização:** 2026-06-14  
**Product Owner:** Equipe de Engenharia  
**Formato:** User Story com critérios de aceite e estimativa em Story Points (Fibonacci)

---

## Legenda de Status

| Símbolo | Status |
|---------|--------|
| Bloqueado | Bloqueado |
| Em refinamento | Em refinamento |
| Pronto | Pronto para desenvolvimento (Definition of Ready atendida) |
| Em desenvolvimento | Em desenvolvimento |
| Concluído | Concluído |

---

## Definition of Ready (DoR)

Um item está **pronto para entrar numa sprint** quando:
- [ ] Tem descrição clara de user story
- [ ] Tem critérios de aceite definidos
- [ ] Tem estimativa de Story Points
- [ ] Não tem dependências bloqueantes
- [ ] O time entende o escopo (sem ambiguidades)

## Definition of Done (DoD)

Um item está **concluído** quando:
- [ ] Código implementado e revisado
- [ ] Testes unitários escritos e passando (cobertura ≥ 80%)
- [ ] Documentação de API atualizada (Swagger)
- [ ] Sem alertas de lint
- [ ] Critérios de aceite validados

---

## ÉPICO 0 — Fundação Técnica

### PB-001 — Setup da Infraestrutura Local (Pronto)
**Story Points:** 3  
**Prioridade:** Crítica

> Como desenvolvedor, quero um ambiente de desenvolvimento configurado com um único comando para focar no desenvolvimento de features.

**Critérios de Aceite:**
- [ ] `docker compose up -d` sobe o PostgreSQL
- [ ] Conexão testada e funcionando
- [ ] `.env.example` documentado com todas as variáveis necessárias
- [ ] README com instruções de instalação

---

### PB-002 — Configuração TypeScript e Fastify (Pronto)
**Story Points:** 3  
**Prioridade:** Crítica

> Como desenvolvedor, quero a estrutura base do projeto com TypeScript estrito e Fastify configurado para desenvolver de forma produtiva.

**Critérios de Aceite:**
- [ ] `tsconfig.json` com `strict: true`
- [ ] Fastify inicializa na porta configurada via `.env`
- [ ] Health check `GET /health` retorna status do banco
- [ ] `npm run dev` inicia com hot-reload
- [ ] `npm run build` gera bundle de produção sem erros

---

### PB-003 — Setup Prisma e Schema Inicial (Pronto)
**Story Points:** 5  
**Prioridade:** Crítica

> Como desenvolvedor, quero o Prisma configurado com o schema inicial para modelar os dados do sistema.

**Critérios de Aceite:**
- [ ] Prisma conecta ao PostgreSQL
- [ ] `npm run db:migrate` aplica migrations
- [ ] `npm run db:seed` cria o usuário gerente padrão
- [ ] Schema com entidades: `Usuario`, `Cliente`, `Peca`

---

### PB-004 — Pipeline CI/CD GitHub Actions (Em refinamento)
**Story Points:** 3  
**Prioridade:** Alta

> Como desenvolvedor, quero que todo PR passe por validação automática para garantir a qualidade do código antes do merge.

**Critérios de Aceite:**
- [ ] Pipeline roda em todo PR para `main`
- [ ] Etapas: lint → type-check → test → build
- [ ] Build falha se cobertura de testes < 80%

---

## ÉPICO 1 — Autenticação e Autorização

### PB-005 — Login de Usuário (Em refinamento)
**Story Points:** 5  
**Prioridade:** Crítica

> Como usuário, quero fazer login para acessar o sistema de acordo com o meu perfil.

**Critérios de Aceite:**
- [ ] `POST /auth/login` retorna JWT (8h)
- [ ] Senha hasheada com bcrypt (12 rounds)
- [ ] Senha nunca exposta em nenhuma resposta
- [ ] Credenciais inválidas retornam HTTP 401 com mensagem genérica

---

### PB-006 — Controle de Acesso por Perfil (Em refinamento)
**Story Points:** 3  
**Prioridade:** Alta

> Como sistema, quero restringir o acesso aos recursos com base no perfil do usuário para garantir a segregação de funções.

**Critérios de Aceite:**
- [ ] Perfis: GERENTE e FUNCIONARIO
- [ ] Middleware de autenticação bloqueia rotas sem JWT (HTTP 401)
- [ ] Gerente tem acesso total; Funcionário cadastra e consulta clientes e peças
- [ ] Acesso não autorizado retorna HTTP 403

---

## ÉPICO 2 — Clientes

### PB-007 — CRUD de Clientes (Em refinamento)
**Story Points:** 5  
**Prioridade:** Alta

> Como funcionário, quero cadastrar e consultar clientes para manter os dados da oficina organizados.

**Critérios de Aceite:**
- [ ] `POST /clientes` — cria cliente PF ou PJ
- [ ] `GET /clientes` — lista com paginação e filtros (nome, CPF/CNPJ)
- [ ] `GET /clientes/:id` — detalhe do cliente
- [ ] `PUT /clientes/:id` — atualiza dados
- [ ] `DELETE /clientes/:id` — remove cliente
- [ ] Unicidade de CPF/CNPJ com erro claro em duplicidade

---

## ÉPICO 3 — Peças

### PB-008 — CRUD de Peças (Em refinamento)
**Story Points:** 5  
**Prioridade:** Alta

> Como funcionário, quero cadastrar e consultar peças do estoque para controlar o inventário da oficina.

**Critérios de Aceite:**
- [ ] `POST /pecas` — cria peça
- [ ] `GET /pecas` — lista com paginação e filtros (código, descrição)
- [ ] `GET /pecas/:id` — detalhe da peça
- [ ] `PUT /pecas/:id` — atualiza dados
- [ ] `DELETE /pecas/:id` — remove peça
- [ ] Unicidade de código com erro claro em duplicidade
- [ ] Sinalização de peças com estoque atual abaixo do estoque mínimo
