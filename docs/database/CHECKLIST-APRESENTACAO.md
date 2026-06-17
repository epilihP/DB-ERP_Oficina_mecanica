# Checklist Antes da Apresentação

Respostas para o roteiro de apresentação do projeto de banco de dados — ERP Oficina Mecânica.

**Referências:** [MODELO-CONCEITUAL.md](MODELO-CONCEITUAL.md) · [MODELO-LOGICO.md](MODELO-LOGICO.md) · [Scripts MySQL](../database/mysql/) · [ENTREGA.md](ENTREGA.md)

---

## 1. Qual o problema que o banco resolve?

O banco organiza e persiste os dados de uma **oficina mecânica**, permitindo:

- **Autenticação** de usuários com perfis (Gerente e Funcionário).
- **Cadastro de clientes** (pessoa física e jurídica) com documento único.
- **Controle de peças** em estoque, com preço e alerta de estoque mínimo.

**Visão MVP (entrega atual):** resolve o cadastro independente de usuários, clientes e peças — suficiente para consultas e CRUD básico.

**Visão estendida (evolução conceitual):** adiciona veículos dos clientes, catálogo de serviços e **ordens de serviço** com peças e serviços aplicados — modelando o fluxo real da oficina (1:N e N:N).

---

## 2. Quais são as entidades?

### MVP (3 entidades)

| Entidade | Descrição |
|----------|-----------|
| **Usuario** | Quem acessa o sistema (gerente ou funcionário) |
| **Cliente** | Cliente da oficina (PF ou PJ) |
| **Peca** | Item de estoque da oficina |

### Visão estendida (+5 entidades)

| Entidade | Descrição |
|----------|-----------|
| **Veiculo** | Automóvel vinculado a um cliente |
| **Servico** | Catálogo de serviços (troca de óleo, alinhamento, etc.) |
| **OrdemServico** | Ordem de serviço (OS) |
| **ItemOrdemPeca** | Entidade associativa — peça usada em uma OS |
| **ItemOrdemServico** | Entidade associativa — serviço executado em uma OS |

---

## 3. Quais são os relacionamentos?

### MVP

**Nenhum relacionamento** entre as entidades. `Usuario`, `Cliente` e `Peca` são independentes neste escopo.

### Visão estendida

| Relacionamento | Entidades | Tipo |
|----------------|-----------|------|
| **Possui** | Cliente → Veiculo | Binário |
| **Solicita** | Cliente → OrdemServico | Binário |
| **Recebe** | Veiculo → OrdemServico | Binário |
| **Responsavel** | Usuario → OrdemServico | Binário |
| **Contem** | OrdemServico → ItemOrdemPeca → Peca | N:N via associativa |
| **Inclui** | OrdemServico → ItemOrdemServico → Servico | N:N via associativa |

---

## 4. Quais são as cardinalidades?

### MVP

Sem relacionamentos — cardinalidades não se aplicam entre as três entidades.

### Visão estendida

| Relacionamento | Cardinalidade | Notação (min,max) |
|----------------|---------------|-------------------|
| Cliente — Possui — Veiculo | **1:N** | Cliente `(1,N)` — Veiculo `(1,1)` |
| Cliente — Solicita — OrdemServico | **1:N** | Cliente `(1,N)` — OrdemServico `(1,1)` |
| Veiculo — Recebe — OrdemServico | **1:N** | Veiculo `(1,N)` — OrdemServico `(1,1)` |
| Usuario — Responsavel — OrdemServico | **1:N** | Usuario `(1,N)` — OrdemServico `(1,1)` |
| OrdemServico ↔ Peca | **N:N** | Via `ItemOrdemPeca` |
| OrdemServico ↔ Servico | **N:N** | Via `ItemOrdemServico` |

Cada lado N:N decomposto:

- OrdemServico `(1,N)` — ItemOrdemPeca `(1,1)`
- Peca `(1,N)` — ItemOrdemPeca `(1,1)`
- OrdemServico `(1,N)` — ItemOrdemServico `(1,1)`
- Servico `(1,N)` — ItemOrdemServico `(1,1)`

---

## 5. Quais são as PKs?

Todas as entidades usam **UUID v4** como chave primária (`id`).

| Entidade | PK |
|----------|-----|
| Usuario | `id` |
| Cliente | `id` |
| Peca | `id` |
| Veiculo | `id` |
| Servico | `id` |
| OrdemServico | `id` |
| ItemOrdemPeca | `id` |
| ItemOrdemServico | `id` |

No modelo físico MySQL: `CHAR(36)` com `DEFAULT (UUID())`.

---

## 6. Quais são as FKs?

### MVP

**Nenhuma foreign key.**

### Visão estendida (8 FKs)

| Tabela | Coluna FK | Referência |
|--------|-----------|------------|
| `veiculo` | `cliente_id` | `cliente(id)` |
| `ordem_servico` | `cliente_id` | `cliente(id)` |
| `ordem_servico` | `veiculo_id` | `veiculo(id)` |
| `ordem_servico` | `usuario_id` | `usuario(id)` |
| `item_ordem_peca` | `ordem_servico_id` | `ordem_servico(id)` |
| `item_ordem_peca` | `peca_id` | `peca(id)` |
| `item_ordem_servico` | `ordem_servico_id` | `ordem_servico(id)` |
| `item_ordem_servico` | `servico_id` | `servico(id)` |

**Restrição de negócio (sem FK):** o veículo de uma OS deve pertencer ao mesmo cliente da OS — validada na aplicação.

---

## 7. O modelo lógico está correto?

**Sim** — documentado em [MODELO-LOGICO.md](MODELO-LOGICO.md) e implementado em [`schema_extended.sql`](../../database/mysql/schema_extended.sql).

| Critério | Situação |
|----------|----------|
| Entidades com PK única | OK — UUID em todas |
| Atributos únicos (UK) | OK — `email`, `cpf_cnpj`, `codigo`, `placa`, `numero` |
| Normalização | OK — ver [JUSTIFICATIVAS.md](JUSTIFICATIVAS.md) §3 |
| N:N resolvido por associativa | OK — `item_ordem_peca`, `item_ordem_servico` |
| MVP sem FKs forçadas | OK — alinhado ao escopo documentado |
| Timestamps UTC | OK — `created_at`, `updated_at` |
| Domínios enumerados | OK — perfil, tipo cliente, status OS |

O modelo conceitual está em [MODELO-CONCEITUAL.md](MODELO-CONCEITUAL.md); o modelo lógico em [MODELO-LOGICO.md](MODELO-LOGICO.md); o físico em [database/mysql/](../../database/mysql/).

---

## 8. O modelo físico foi implementado?

**Sim** — scripts MySQL em [`database/mysql/`](../database/mysql/):

| Script | Database | Conteúdo |
|--------|----------|----------|
| `schema_mvp.sql` | `oficina_mvp` | 3 tabelas, 0 FK |
| `schema_extended.sql` | `oficina_extended` | 8 tabelas, 8 FK |
| `seed_mvp.sql` | `oficina_mvp` | Dados de demo |
| `seed_extended.sql` | `oficina_extended` | Dados de demo |

**Como executar:**

```bash
mysql -u root -p < database/mysql/schema_mvp.sql
mysql -u root -p oficina_mvp < database/mysql/seed_mvp.sql
```

**Nota:** ADR-003 define PostgreSQL para a API futura; a implementação física atual usa **MySQL 8** para a apresentação acadêmica.

---

## 9. Todos os integrantes conseguem explicar o projeto?

Use esta seção na apresentação — cada integrante cobre um tópico (preencher nomes em [ENTREGA.md](ENTREGA.md)):

| Integrante | Tópico | Pontos-chave |
|------------|--------|--------------|
| Integrante 1 _(nome)_ | Problema e escopo | Oficina mecânica; MVP vs estendida; sem financeiro/fiscal |
| Integrante 2 _(nome)_ | Entidades MVP | Usuario, Cliente, Peca — atributos e UKs |
| Integrante 3 _(nome)_ | Modelo estendido | Veiculo, OS, serviços, associativas N:N |
| Integrante 4 _(nome)_ | Cardinalidades + lógico | 1:N `(1,N)`—`(1,1)`; N:N; [MODELO-LOGICO.md](MODELO-LOGICO.md) |
| Integrante 5 _(nome)_ | Justificativas + físico | [JUSTIFICATIVAS.md](JUSTIFICATIVAS.md); scripts MySQL; 8 FKs |
| Integrante 6 _(nome)_ | Demonstração | Estoque crítico; OS com JOINs; queries analíticas |

> Preencher nomes e RA em [ENTREGA.md](ENTREGA.md) antes da entrega (18/06).

---

## Consultas rápidas para a demo

```sql
-- MVP: peças em estoque crítico
USE oficina_mvp;
SELECT codigo, descricao, estoque_atual, estoque_minimo
FROM peca WHERE estoque_atual < estoque_minimo;

-- Estendido: OS completa
USE oficina_extended;
SELECT os.numero, c.nome, v.placa, u.nome AS responsavel
FROM ordem_servico os
JOIN cliente c ON c.id = os.cliente_id
JOIN veiculo v ON v.id = os.veiculo_id
JOIN usuario u ON u.id = os.usuario_id;
```
