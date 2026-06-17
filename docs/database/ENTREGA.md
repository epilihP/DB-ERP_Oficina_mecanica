# Entrega — Projeto de Modelagem de Banco de Dados

**Disciplina:** Modelagem de Banco de Dados  
**Domínio:** ERP Oficina Mecânica (projeto integrador)  
**Apresentação:** 17/06/2026  
**Entrega do conteúdo:** até 18/06/2026

---

## Integrantes do grupo

| # | Nome | RA |
|---|------|-----|
| 1 | _(preencher)_ | _(preencher)_ |
| 2 | _(preencher)_ | _(preencher)_ |
| 3 | _(preencher)_ | _(preencher)_ |
| 4 | _(preencher)_ | _(preencher)_ |
| 5 | _(preencher)_ | _(preencher)_ |
| 6 | _(preencher)_ | _(preencher)_ |

> Máximo 6 integrantes. Preencher antes da entrega formal.

---

## Entregáveis do edital

| Camada | Documento / artefato | Link |
|--------|----------------------|------|
| **Modelo conceitual** | DER com entidades, atributos e cardinalidades (MVP + estendido) | [MODELO-CONCEITUAL.md](MODELO-CONCEITUAL.md) |
| **Modelo lógico** | Tabelas, PK, FK, UK (visualizável e validável) | [MODELO-LOGICO.md](MODELO-LOGICO.md) |
| **Justificativas** | Relacionamentos, tipos de dados, normalização | [JUSTIFICATIVAS.md](JUSTIFICATIVAS.md) |
| **Modelo físico — DDL** | Scripts de criação de tabelas | [schema_mvp.sql](../../database/mysql/schema_mvp.sql) · [schema_extended.sql](../../database/mysql/schema_extended.sql) |
| **Modelo físico — dados** | Scripts de inserção (seed) | [seed_mvp.sql](../../database/mysql/seed_mvp.sql) · [seed_extended.sql](../../database/mysql/seed_extended.sql) |
| **Modelo físico — consultas** | Queries de validação e análise | [queries_analiticas.sql](../../database/mysql/queries_analiticas.sql) |
| **Roteiro de apresentação** | Checklist de perguntas e demo | [CHECKLIST-APRESENTACAO.md](CHECKLIST-APRESENTACAO.md) |
| **Execução MySQL** | Como rodar e validar | [database/mysql/README.md](../../database/mysql/README.md) |

---

## Como validar o modelo físico (MySQL 8+)

Na raiz do repositório:

```bash
# Modelo estendido (relacionamentos + FKs) — principal para validação
mysql -u root -p < database/mysql/schema_extended.sql
mysql -u root -p oficina_extended < database/mysql/seed_extended.sql
mysql -u root -p oficina_extended < database/mysql/queries_analiticas.sql

# Modelo MVP (3 tabelas, sem FK)
mysql -u root -p < database/mysql/schema_mvp.sql
mysql -u root -p oficina_mvp < database/mysql/seed_mvp.sql
```

**Verificação rápida:**

```sql
SHOW TABLES FROM oficina_extended;
SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS
WHERE CONSTRAINT_SCHEMA = 'oficina_extended' AND CONSTRAINT_TYPE = 'FOREIGN KEY';
-- Esperado: 8 FKs
```

---

## Nota sobre tecnologia

- **Entrega acadêmica:** scripts em **MySQL 8** (`database/mysql/`).
- **Projeto integrador (API futura):** ADR-003 prevê **PostgreSQL** — decisão de implementação da aplicação, não altera o modelo lógico relacional documentado aqui.

---

## Objetivo da atividade

Validar modelagem **conceitual**, **lógica** e **física** do domínio oficina mecânica, com justificativa de relacionamentos, tipos de dados e normalização — conforme edital da disciplina.
