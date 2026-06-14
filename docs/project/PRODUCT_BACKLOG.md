# Product Backlog — MechanicOS

**Última atualização:** 2026-05-30  
**Product Owner:** Equipe de Engenharia  
**Formato:** User Story com critérios de aceite e estimativa em Story Points (Fibonacci)

---

## Legenda de Status

| Símbolo | Status |
|---------|--------|
| 🔴 | Bloqueado |
| 🟡 | Em refinamento |
| 🟢 | Pronto para desenvolvimento (Definition of Ready atendida) |
| 🔵 | Em desenvolvimento |
| ✅ | Concluído |

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
- [ ] Testes de integração escritos e passando
- [ ] Documentação de API atualizada (Swagger)
- [ ] Sem alertas de lint
- [ ] Deploy no ambiente de staging bem-sucedido
- [ ] Critérios de aceite validados

---

## ÉPICO 0 — Fundação Técnica

### PB-001 — Setup da Infraestrutura Local 🟢
**Story Points:** 5  
**Prioridade:** Crítica

> Como desenvolvedor, quero ter um ambiente de desenvolvimento completamente configurado com um único comando para focar no desenvolvimento de features.

**Critérios de Aceite:**
- [ ] `docker compose up -d` sobe PostgreSQL, MongoDB, Redis e RabbitMQ
- [ ] Conexões testadas e funcionando
- [ ] `.env.example` documentado com todas as variáveis necessárias
- [ ] README com instruções de instalação

---

### PB-002 — Configuração TypeScript e Fastify 🟢
**Story Points:** 3  
**Prioridade:** Crítica

> Como desenvolvedor, quero a estrutura base do projeto com TypeScript estrito e Fastify configurado para desenvolver de forma produtiva.

**Critérios de Aceite:**
- [ ] `tsconfig.json` com `strict: true`
- [ ] Fastify inicializa na porta configurada via `.env`
- [ ] Health check `GET /health` retorna status dos serviços
- [ ] `npm run dev` inicia com hot-reload
- [ ] `npm run build` gera bundle de produção sem erros

---

### PB-003 — Setup Prisma e Schema Inicial 🟢
**Story Points:** 5  
**Prioridade:** Crítica

> Como desenvolvedor, quero o Prisma configurado com o schema inicial para começar a modelar os dados do sistema.

**Critérios de Aceite:**
- [ ] Prisma conecta ao PostgreSQL
- [ ] `npm run db:migrate` aplica migrations
- [ ] `npm run db:seed` popula dados iniciais de desenvolvimento
- [ ] Schema com entidades base: User, AuditLog

---

### PB-004 — Pipeline CI/CD GitHub Actions 🟡
**Story Points:** 3  
**Prioridade:** Alta

> Como desenvolvedor, quero que todo PR passe por validação automática para garantir qualidade do código antes do merge.

**Critérios de Aceite:**
- [ ] Pipeline roda em todo PR para `main`
- [ ] Etapas: lint → type-check → test → build
- [ ] Build falha se cobertura de testes < 80%

---

## ÉPICO 1 — Autenticação e Autorização

### PB-005 — Cadastro e Login de Usuário 🟡
**Story Points:** 8  
**Prioridade:** Crítica

> Como administrador, quero criar usuários com perfis de acesso para controlar quem pode fazer o quê no sistema.

**Critérios de Aceite:**
- [ ] `POST /auth/register` cria usuário com senha hasheada (bcrypt, 12 rounds)
- [ ] `POST /auth/login` retorna JWT (8h) + refresh token (7 dias)
- [ ] `POST /auth/refresh` renova JWT via refresh token válido
- [ ] `POST /auth/logout` invalida refresh token
- [ ] Senha nunca exposta em nenhuma resposta
- [ ] Rate limiting: máx 5 tentativas de login por IP/minuto

---

### PB-006 — Controle de Acesso por Perfil (RBAC) 🟡
**Story Points:** 5  
**Prioridade:** Alta

> Como sistema, quero bloquear acesso a recursos baseado no perfil do usuário para garantir segurança e segregação de funções.

**Critérios de Aceite:**
- [ ] Perfis: ADMIN, RECEPCIONISTA, MECANICO, ALMOXARIFE, FINANCEIRO
- [ ] Middleware de autorização bloqueia com HTTP 403 em acesso não autorizado
- [ ] Cada rota tem permissões documentadas

---

## ÉPICO 2 — Clientes e Veículos

### PB-007 — CRUD de Clientes 🟡
**Story Points:** 5  
**Prioridade:** Alta

> Como recepcionista, quero cadastrar e consultar clientes para vincular às ordens de serviço.

**Critérios de Aceite:**
- [ ] `POST /clientes` — cria cliente PF ou PJ
- [ ] `GET /clientes` — lista com paginação e filtros (nome, CPF/CNPJ)
- [ ] `GET /clientes/:id` — detalhe com histórico de OS
- [ ] `PUT /clientes/:id` — atualiza dados
- [ ] `DELETE /clientes/:id` — soft delete (não apaga fisicamente)
- [ ] Validação de CPF e CNPJ
- [ ] Erro claro ao tentar cadastrar CPF/CNPJ já existente

---

### PB-008 — CRUD de Veículos 🟡
**Story Points:** 5  
**Prioridade:** Alta

> Como recepcionista, quero cadastrar veículos vinculados a clientes para identificar o objeto de cada OS.

**Critérios de Aceite:**
- [ ] `POST /veiculos` — cria veículo vinculado a um cliente
- [ ] `GET /veiculos` — lista com filtros (placa, cliente, marca/modelo)
- [ ] `GET /veiculos/:id` — detalhe com histórico de OS
- [ ] Placa validada no formato brasileiro (AAA-0000 ou AAA-0A00)
- [ ] Soft delete

---

## ÉPICO 3 — Ordens de Serviço

### PB-009 — Criação e Abertura de OS 🟡
**Story Points:** 8  
**Prioridade:** Crítica

> Como recepcionista, quero abrir uma ordem de serviço para registrar a entrada de um veículo na oficina.

**Critérios de Aceite:**
- [ ] `POST /os` — cria OS no estado RASCUNHO
- [ ] `POST /os/:id/abrir` — transiciona para ABERTA com registro de timestamp
- [ ] OS vincula: cliente, veículo, recepcionista, descrição do problema
- [ ] Geração de código legível: `OS-2026-0001`
- [ ] Registro de data/hora de entrada do veículo

---

### PB-010 — Máquina de Estados da OS 🟡
**Story Points:** 13  
**Prioridade:** Crítica

> Como sistema, quero que a OS siga um fluxo de estados controlado para garantir a integridade do processo de atendimento.

**Critérios de Aceite:**
- [ ] Estados: RASCUNHO → ABERTA → EM_EXECUCAO → AGUARDANDO_PECA → CONCLUIDA → FATURADA → CANCELADA
- [ ] Transições inválidas retornam erro HTTP 422
- [ ] Cada transição registra: usuário, timestamp, observação opcional
- [ ] Histórico de transições acessível via `GET /os/:id/historico`

---

### PB-011 — Serviços e Peças na OS 🟡
**Story Points:** 8  
**Prioridade:** Alta

> Como mecânico, quero registrar os serviços realizados e as peças utilizadas na OS para compor o valor final.

**Critérios de Aceite:**
- [ ] Adicionar/remover serviços com valor e descrição
- [ ] Adicionar/remover peças do estoque com quantidade
- [ ] Cálculo automático do valor total (serviços + peças)
- [ ] Reserva de peças no estoque ao adicionar na OS
- [ ] Liberação da reserva ao cancelar OS

---

## ÉPICO 4 — Estoque/WMS

### PB-012 — CRUD de Peças 🟡
**Story Points:** 5  
**Prioridade:** Alta

> Como almoxarife, quero cadastrar peças do estoque para controlar o inventário da oficina.

*(critérios detalhados no refinamento da Sprint 7)*

---

### PB-013 — Movimentações de Estoque 🟡
**Story Points:** 13  
**Prioridade:** Alta

> Como almoxarife, quero registrar entradas e saídas de peças para manter o saldo de estoque sempre atualizado.

*(critérios detalhados no refinamento da Sprint 8)*

---

## ÉPICO 5 — Sync Offline

### PB-014 — Módulo de Sincronização 🔴
**Story Points:** 21  
**Prioridade:** Alta  
**Bloqueio:** Requer módulos Operacional e Estoque estáveis

> Como usuário, quero que o sistema sincronize automaticamente minhas operações offline quando a internet retornar, para não perder nenhuma informação.

*(detalhamento técnico no ADR-003)*

---

## Backlog Não Refinado (Épicos Futuros)

- **ÉPICO 6** — Dashboard e Relatórios
- **ÉPICO 7** — Módulo Financeiro
- **ÉPICO 8** — Emissão de NF-e
- **ÉPICO 9** — Notificações (WhatsApp/Email)
- **ÉPICO 10** — Portal do Cliente
