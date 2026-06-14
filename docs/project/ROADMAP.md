# Roadmap — MechanicOS

**Última atualização:** 2026-05-30  
**Metodologia:** Scrum — Sprints de 2 semanas

---

## Visão de Longo Prazo

```
2026 Q2          2026 Q3          2026 Q4          2027 Q1
   │                │                │                │
   ▼                ▼                ▼                ▼
Sprint 0        Módulo           Módulo           Módulo
Fundação    ──► Operacional  ──► Estoque/WMS  ──► Gestão
                                                      │
                                                      ▼
                                                  Módulo
                                                 Financeiro
```

---

## Sprint 0 — Fundação (Atual)
**Status:** 🔄 Em andamento  
**Objetivo:** Estabelecer base técnica e documental sólida antes de qualquer código de negócio

### Entregáveis
- [x] SRS (Software Requirements Specification)
- [x] README do projeto
- [x] ADR-001: UUID como identificador
- [x] ADR-002: Fastify como framework
- [x] ADR-003: Estratégia offline-first
- [x] Roadmap
- [x] Product Backlog inicial
- [x] Skills files (code_style, project_context, etc.)
- [ ] Estrutura de pastas do projeto
- [ ] Docker Compose com PostgreSQL, MongoDB, Redis, RabbitMQ
- [ ] Configuração TypeScript (tsconfig.json)
- [ ] Setup do Prisma com schema inicial
- [ ] Pipeline CI/CD básico (GitHub Actions)
- [ ] Health check endpoint

---

## Fase 1 — Módulo Operacional
**Sprints estimadas:** 4–6 sprints  
**Dependências:** Sprint 0 concluída

### Sprint 1 — Autenticação e Base
- Setup de autenticação JWT
- CRUD de Usuários com RBAC básico
- Middleware de autenticação e autorização
- Logs estruturados integrados

### Sprint 2 — Clientes e Veículos
- CRUD completo de Clientes (PF/PJ)
- CRUD completo de Veículos
- Vinculação cliente ↔ veículo
- Validações de CPF/CNPJ

### Sprint 3 — Ordens de Serviço (Core)
- Criação e abertura de OS
- Máquina de estados da OS
- Vinculação OS ↔ Cliente ↔ Veículo ↔ Mecânico
- Registro de transições com auditoria

### Sprint 4 — Ordens de Serviço (Serviços e Peças)
- Adição de serviços à OS
- Adição de peças à OS (integração básica com estoque)
- Cálculo de valor total da OS
- Fechamento e conclusão de OS

### Sprint 5 — Agenda
- Agenda por mecânico
- Detecção de conflitos de horário
- Visualização semanal

### Sprint 6 — Testes e Estabilização Operacional
- Cobertura de testes ≥ 80%
- Revisão de performance
- Documentação de API (Swagger)

---

## Fase 2 — Módulo Estoque/WMS
**Sprints estimadas:** 3–4 sprints  
**Dependências:** Fase 1 concluída

### Sprint 7 — Cadastro de Peças e Fornecedores
- CRUD de Peças com código de barras
- CRUD de Fornecedores
- Configuração de estoque mínimo

### Sprint 8 — Movimentações
- Entrada de peças (compra)
- Saída de peças (consumo em OS)
- Ajuste de estoque com aprovação
- Alertas de estoque crítico

### Sprint 9 — Inventário e Relatórios de Estoque
- Contagem cíclica
- Relatório de divergências
- Histórico completo de movimentações

---

## Fase 3 — Módulo de Gestão
**Sprints estimadas:** 2–3 sprints  
**Dependências:** Fases 1 e 2 concluídas

### Sprint 10 — Dashboard e Relatórios
- KPIs em tempo real
- Relatórios de OS por período
- Relatórios de performance por mecânico
- Exportação CSV/PDF

### Sprint 11 — Configurações e Administração
- Gestão avançada de usuários e permissões
- Configurações globais do sistema
- Auditoria e logs de acesso

---

## Fase 4 — Módulo Financeiro
**Sprints estimadas:** 3–4 sprints  
**Dependências:** Fases 1, 2 e 3 concluídas

### Sprint 12 — Contas a Receber
- Geração de cobrança ao fechar OS
- Controle de pagamentos
- Múltiplas formas de pagamento

### Sprint 13 — Fluxo de Caixa
- Lançamentos manuais
- Conciliação bancária básica
- Relatório de fluxo de caixa

### Sprint 14 — Fiscal
- Integração NF-e (SEFAZ)
- Configuração tributária
- Emissão e cancelamento de NF

---

## Fases Futuras (Backlog)

| Funcionalidade | Prioridade | Observações |
|----------------|-----------|-------------|
| App Mobile (PWA) | Alta | Para mecânicos na baia |
| Integração WhatsApp | Média | Notificações ao cliente |
| Portal do Cliente | Média | Acompanhamento de OS online |
| Integração com fornecedores | Baixa | Cotação automática de peças |
| BI e Analytics avançado | Baixa | Após dados históricos suficientes |
