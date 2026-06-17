# Justificativas de Modelagem

**Projeto:** ERP Oficina Mecânica — Modelagem de Banco de Dados  
**Data:** 2026-06-16

Documento de suporte à apresentação: relacionamentos, tipos de dados e normalização.

---

## 1. Relacionamentos

### 1.1 MVP sem foreign keys

No escopo mínimo (MVP), `Usuario`, `Cliente` e `Peca` são **independentes**. Isso reflete o SRS e o ADR-003 do projeto integrador: o foco inicial é cadastro e estoque sem ordens de serviço. Não há associação de negócio documentada entre essas três entidades nesta fase.

### 1.2 Relacionamentos 1:N (visão estendida)

| Relacionamento | Cardinalidade | Justificativa |
|--------------|---------------|---------------|
| Cliente → Veículo | 1:N | Um cliente pode ter vários carros; cada veículo pertence a um único cliente. |
| Cliente → Ordem de serviço | 1:N | Histórico de OS por cliente. |
| Veículo → Ordem de serviço | 1:N | Cada OS refere um veículo específico em manutenção. |
| Usuário → Ordem de serviço | 1:N | Mecânico/responsável pela OS; um usuário pode ter várias OS. |

FKs em `veiculo.cliente_id`, `ordem_servico.cliente_id`, `ordem_servico.veiculo_id` e `ordem_servico.usuario_id` materializam esses 1:N no modelo lógico.

### 1.3 Relacionamentos N:N via entidades associativas

| Relacionamento | Associativa | Justificativa |
|--------------|-------------|---------------|
| Ordem de serviço ↔ Peca | `item_ordem_peca` | Uma OS pode usar várias peças; a mesma peça aparece em várias OS. Atributos próprios: `quantidade`, `preco_unitario` (snapshot no momento da OS). |
| Ordem de serviço ↔ Servico | `item_ordem_servico` | Uma OS pode incluir vários serviços; um serviço pode constar em várias OS. Atributos: `quantidade_horas`, `preco` (snapshot). |

**Por que não um N:N direto?** Sem a tabela associativa, não é possível registrar quantidade e preço por item sem repetir colunas ou violar normalização. A associativa é o padrão relacional correto para N:N com atributos.

### 1.4 Restrição de negócio (sem FK)

O veículo de uma OS deve pertencer ao mesmo cliente da OS. Isso não é imposto por uma FK simples; validação na aplicação ou constraint composta futura.

---

## 2. Tipos de dados

| Tipo lógico | Uso no modelo | Justificativa |
|-------------|---------------|---------------|
| **UUID** (`CHAR(36)`) | PK de todas as tabelas | Identificador único global; padrão do projeto (ADR-001); evita exposição de sequência. |
| **VARCHAR** | Nome, email, código, placa | Texto variável com limite adequado ao domínio. |
| **ENUM** | `perfil`, `tipo`, `status` | Domínios fechados e estáveis; validação no banco. |
| **DECIMAL(10,2)** | Preços, horas | Valores monetários sem erro de ponto flutuante. |
| **INT** | Estoque, quantidade, ano | Contadores e anos discretos. |
| **DATETIME** | `created_at`, `updated_at`, datas da OS | Timestamps em UTC (SRS §2.3). |
| **TEXT** | `observacoes` | Texto longo opcional na OS. |

**Snapshot de preço:** `item_ordem_peca.preco_unitario` e `item_ordem_servico.preco` guardam o valor na abertura da OS, independente de alterações futuras no catálogo (`peca.preco_unitario`, `servico.preco_base`).

---

## 3. Normalização

### 3.1 Primeira forma normal (1FN)

- Atributos **atômicos**: sem listas embutidas (ex.: um telefone por coluna; múltiplos veículos em linhas separadas em `veiculo`).
- Cada coluna contém um único valor do domínio.

### 3.2 Segunda forma normal (2FN)

- Todas as tabelas têm **PK simples** (`id` UUID).
- Não há dependência parcial: atributos dependem da PK inteira, não de parte dela.
- Nas associativas, `quantidade` e `preco` dependem da linha completa (`id` da item), não só de `peca_id` ou `servico_id`.

### 3.3 Terceira forma normal (3FN)

- Sem dependência **transitiva** indesejada: dados do cliente não são repetidos em `veiculo` além de `cliente_id`.
- Preço na OS **não** duplica o catálogo em colunas redundantes na mesma tabela `ordem_servico`; fica na associativa com snapshot — decisão de negócio (histórico), não redundância por falta de normalização.

### 3.4 N:N e normalização

`item_ordem_peca` e `item_ordem_servico` eliminam o padrão anti-relacional de múltiplas colunas `peca_1`, `peca_2`, … na tabela `ordem_servico`.

---

## 4. Resumo para slides

1. **Relacionamentos:** MVP isolado; estendido com 1:N e N:N via associativas.
2. **Tipos:** UUID, DECIMAL para dinheiro, ENUM para domínios fixos.
3. **Normalização:** 1FN/2FN/3FN atendidas; N:N decomposto corretamente.

---

## Referências

- [Modelo conceitual](MODELO-CONCEITUAL.md)
- [Modelo lógico](MODELO-LOGICO.md)
- [ADR-001 — UUID](../architecture/ADR-001-uuid-como-identificador.md)
