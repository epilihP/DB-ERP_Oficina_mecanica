# SRS — Software Requirements Specification
## ERP/WMS para Oficina Mecânica

**Versão:** 1.0.0  
**Data:** 2026-05-30  
**Status:** Em elaboração  
**Autor:** Equipe de Engenharia

---

## 1. Introdução

### 1.1 Propósito

Este documento descreve os requisitos funcionais e não funcionais do sistema ERP/WMS para gerenciamento completo de uma oficina mecânica. O sistema deve operar em ambientes com conectividade instável, suportando operação offline prolongada com sincronização posterior de dados.

### 1.2 Escopo

O sistema cobre os seguintes domínios de negócio, em ordem de prioridade de desenvolvimento:

1. **Operacional** — Ordens de Serviço, Veículos, Clientes, Agenda
2. **Estoque/WMS** — Peças, Movimentações, Fornecedores, Inventário
3. **Gestão** — Relatórios, Dashboard, Usuários, Permissões
4. **Financeiro** — Contas a Receber, Fluxo de Caixa, Fiscal

### 1.3 Definições e Siglas

| Sigla | Significado |
|-------|-------------|
| OS | Ordem de Serviço |
| WMS | Warehouse Management System |
| ERP | Enterprise Resource Planning |
| UUID | Universally Unique Identifier |
| RBAC | Role-Based Access Control |
| PWA | Progressive Web App |
| CRDTs | Conflict-free Replicated Data Types |
| ETL | Extract, Transform, Load |

---

## 2. Visão Geral do Sistema

### 2.1 Perspectiva do Produto

Sistema web/desktop com capacidade offline-first. A oficina pode operar por dias sem conexão à internet. Toda operação realizada offline deve ser registrada localmente e sincronizada com o servidor central quando a conexão for restabelecida, com resolução automática de conflitos onde possível e alertas para conflitos que necessitem intervenção humana.

### 2.2 Usuários do Sistema

| Perfil | Responsabilidades |
|--------|-------------------|
| Administrador | Configuração geral, usuários, relatórios gerenciais |
| Recepcionista | Abertura/fechamento de OS, atendimento ao cliente |
| Mecânico | Execução de OS, registro de horas, solicitação de peças |
| Almoxarife | Controle de estoque, entrada/saída de peças |
| Financeiro | Contas a receber, pagamentos, relatórios financeiros |

### 2.3 Restrições Gerais

- O sistema deve funcionar sem conexão por até **7 dias consecutivos**
- Toda entidade deve usar **UUID v4** como identificador primário
- Operações críticas devem ser **idempotentes** para suportar re-sincronização
- O sistema deve suportar múltiplos terminais simultâneos na mesma rede local

---

## 3. Requisitos Funcionais

### 3.1 Módulo Operacional

#### RF-OP-001 — Gerenciamento de Clientes
- O sistema deve permitir cadastro, edição e consulta de clientes (PF e PJ)
- Campos obrigatórios: nome/razão social, CPF/CNPJ, telefone, email
- O sistema deve validar CPF/CNPJ em tempo real
- O histórico de atendimentos do cliente deve estar acessível na ficha

#### RF-OP-002 — Gerenciamento de Veículos
- Cada veículo deve ser vinculado a um ou mais clientes
- Campos obrigatórios: placa, marca, modelo, ano, cor
- O sistema deve integrar com API de consulta de placa (quando online)
- Histórico completo de OS por veículo deve estar acessível

#### RF-OP-003 — Ordens de Serviço
- Uma OS deve ter os seguintes estados: `RASCUNHO → ABERTA → EM_EXECUCAO → AGUARDANDO_PECA → CONCLUIDA → FATURADA → CANCELADA`
- Cada OS deve vincular: cliente, veículo, mecânico responsável, serviços, peças utilizadas
- O sistema deve registrar data/hora de entrada e saída do veículo
- Deve ser possível adicionar fotos do veículo na abertura da OS
- Cada transição de estado deve ser registrada com timestamp e usuário responsável

#### RF-OP-004 — Agenda de Mecânicos
- O sistema deve permitir agendamento de serviços por mecânico e data
- Deve exibir disponibilidade em tempo real
- Alertas de conflito de agenda devem ser exibidos

### 3.2 Módulo de Estoque/WMS

#### RF-EST-001 — Cadastro de Peças
- Campos obrigatórios: código interno, descrição, unidade, NCM, fornecedor principal
- Suporte a código de barras (EAN-13)
- Controle de estoque mínimo com alertas automáticos

#### RF-EST-002 — Movimentações de Estoque
- Tipos de movimentação: ENTRADA, SAIDA, TRANSFERENCIA, AJUSTE, DEVOLUCAO
- Toda movimentação deve ser rastreável (quem, quando, motivo, OS vinculada)
- O saldo de estoque deve ser recalculável a partir do histórico de movimentações

#### RF-EST-003 — Fornecedores
- Cadastro completo com dados fiscais (CNPJ, IE, dados bancários)
- Histórico de compras por fornecedor
- Prazo médio de entrega calculado automaticamente

#### RF-EST-004 — Inventário
- Suporte a contagem cíclica e inventário geral
- Geração de relatório de divergências
- Aprovação de ajustes por usuário autorizado

### 3.3 Módulo de Gestão

#### RF-GES-001 — Controle de Usuários e Permissões
- Autenticação via email/senha com JWT
- Suporte a RBAC com perfis configuráveis
- Log de acesso e ações críticas

#### RF-GES-002 — Dashboard
- Indicadores em tempo real: OS abertas, OS em execução, peças com estoque crítico
- Gráficos de desempenho por mecânico e período

#### RF-GES-003 — Relatórios
- Relatório de OS por período, cliente, mecânico, status
- Relatório de movimentação de estoque
- Exportação em PDF e CSV

### 3.4 Módulo Financeiro

#### RF-FIN-001 — Contas a Receber
- Geração automática de cobrança ao fechar uma OS
- Suporte a múltiplas formas de pagamento (dinheiro, cartão, PIX, boleto)
- Controle de parcelamento

#### RF-FIN-002 — Fluxo de Caixa
- Lançamentos de entrada e saída
- Conciliação bancária básica

#### RF-FIN-003 — Fiscal
- Emissão de NF-e/NFS-e (integração com SEFAZ)
- Configuração de alíquotas por produto/serviço

---

## 4. Requisitos Não Funcionais

### 4.1 Offline-First (CRÍTICO)

- **RNF-001:** O sistema deve operar completamente sem internet por até 7 dias
- **RNF-002:** A sincronização deve ser automática ao reconectar, sem intervenção do usuário
- **RNF-003:** Conflitos devem ser detectados, logados e resolvidos por regras de negócio definidas
- **RNF-004:** O sistema deve usar **UUID v4** em todas as entidades para evitar colisões de ID durante operação offline
- **RNF-005:** O timestamp de todas as operações deve ser armazenado em **UTC**

### 4.2 Performance

- **RNF-006:** Tempo de resposta de APIs < 200ms para operações simples (p95)
- **RNF-007:** Listagens paginadas com máximo 100 registros por página
- **RNF-008:** Queries ao banco devem ter planos de execução validados antes de produção

### 4.3 Segurança

- **RNF-009:** Senhas armazenadas com bcrypt (salt rounds ≥ 12)
- **RNF-010:** JWT com expiração de 8 horas, refresh token de 7 dias
- **RNF-011:** Rate limiting em todas as rotas públicas
- **RNF-012:** Todas as entradas validadas com Zod antes de chegar na camada de serviço
- **RNF-013:** Logs não devem conter dados sensíveis (senhas, tokens, CPF)

### 4.4 Observabilidade

- **RNF-014:** Logs estruturados em formato JSON com correlationId por requisição
- **RNF-015:** Métricas de latência, throughput e erros expostas para Prometheus
- **RNF-016:** Health check endpoint `/health` com status dos serviços dependentes

### 4.5 Escalabilidade

- **RNF-017:** A arquitetura deve permitir escalar horizontalmente sem mudanças de código
- **RNF-018:** Nenhuma sessão em memória — estado de autenticação apenas em JWT/Redis

---

## 5. Restrições Técnicas

- Backend: Node.js + TypeScript + Fastify
- ORM: Prisma (PostgreSQL) + Mongoose (MongoDB quando aplicável)
- Cache/Filas: Redis + RabbitMQ
- Infraestrutura: Docker + Docker Compose (dev) | Kubernetes + AWS (prod)
- CI/CD: GitHub Actions

---

## 6. Critérios de Aceite Globais

- [ ] Toda funcionalidade deve ter testes unitários com cobertura ≥ 80%
- [ ] Toda rota deve ter validação de entrada e saída tipada
- [ ] Toda transação financeira ou de estoque deve ser auditável
- [ ] O sistema deve inicializar via Docker Compose com um único comando
- [ ] A documentação de API deve ser gerada automaticamente via Swagger/OpenAPI
