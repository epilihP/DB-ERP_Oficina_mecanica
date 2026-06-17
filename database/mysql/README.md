# MySQL — Modelo Físico

Scripts SQL standalone para o modelo físico do ERP Oficina Mecânica, derivados do [modelo conceitual](../docs/database/MODELO-CONCEITUAL.md).

**Requisito:** MySQL 8.0+ (uso de `DEFAULT (UUID())`).

> A API futura do projeto prevê PostgreSQL (ADR-003). Estes scripts usam **MySQL** para implementação física e demonstração acadêmica.

## Arquivos

| Arquivo | Database | Descrição |
|---------|----------|-----------|
| `schema_mvp.sql` | `oficina_mvp` | 3 tabelas, sem FKs |
| `schema_extended.sql` | `oficina_extended` | 8 tabelas, com FKs e associativas |
| `seed_mvp.sql` | `oficina_mvp` | Dados de demonstração MVP |
| `seed_extended.sql` | `oficina_extended` | Dados de demonstração estendido |
| `queries_analiticas.sql` | `oficina_extended` | Consultas analíticas (demo/apresentação) |

## Execução

### Linha de comando

Na raiz do repositório:

```bash
mysql -u root -p < database/mysql/schema_mvp.sql
mysql -u root -p oficina_mvp < database/mysql/seed_mvp.sql

mysql -u root -p < database/mysql/schema_extended.sql
mysql -u root -p oficina_extended < database/mysql/seed_extended.sql
```

### Docker (MySQL 8)

```bash
docker run -d --name oficina-mysql -e MYSQL_ROOT_PASSWORD=root -p 3306:3306 mysql:8

# Aguardar o servidor iniciar (~30s), depois:
docker exec -i oficina-mysql mysql -uroot -proot < database/mysql/schema_mvp.sql
docker exec -i oficina-mysql mysql -uroot -proot oficina_mvp < database/mysql/seed_mvp.sql
docker exec -i oficina-mysql mysql -uroot -proot < database/mysql/schema_extended.sql
docker exec -i oficina-mysql mysql -uroot -proot oficina_extended < database/mysql/seed_extended.sql
```

### MySQL Workbench

1. Abrir `schema_mvp.sql` ou `schema_extended.sql`
2. Executar o script completo
3. Opcional: executar o `seed_*.sql` correspondente

## Consultas de demonstração

### MVP — estoque crítico

```sql
USE oficina_mvp;

SELECT codigo, descricao, estoque_atual, estoque_minimo
FROM peca
WHERE estoque_atual < estoque_minimo;
```

### Estendido — OS com cliente, veículo e itens

```sql
USE oficina_extended;

SELECT
  os.numero,
  os.status,
  c.nome AS cliente,
  v.placa,
  v.modelo,
  u.nome AS responsavel
FROM ordem_servico os
JOIN cliente c ON c.id = os.cliente_id
JOIN veiculo v ON v.id = os.veiculo_id
JOIN usuario u ON u.id = os.usuario_id;

SELECT
  os.numero,
  p.codigo AS peca,
  iop.quantidade,
  iop.preco_unitario
FROM item_ordem_peca iop
JOIN ordem_servico os ON os.id = iop.ordem_servico_id
JOIN peca p ON p.id = iop.peca_id;

SELECT
  os.numero,
  s.codigo AS servico,
  ios.quantidade_horas,
  ios.preco
FROM item_ordem_servico ios
JOIN ordem_servico os ON os.id = ios.ordem_servico_id
JOIN servico s ON s.id = ios.servico_id;
```

## Validação

**Status:** validado em 2026-06-17 com MySQL 8 (Docker `mysql:8`).

| Verificação | MVP (`oficina_mvp`) | Estendido (`oficina_extended`) |
|-------------|---------------------|--------------------------------|
| Script `schema_*.sql` | OK | OK |
| Tabelas criadas | 3 (`usuario`, `cliente`, `peca`) | 8 |
| Foreign keys | 0 | 8 |
| Seed aplicado | OK | OK |
| Estoque crítico (PEC-003) | 1 registro | 1 registro em `peca` |
| JOIN OS → cliente → veículo → usuário | — | OK (`OS-2026-001`) |

### Checklist de verificação manual

| Verificação | MVP | Estendido |
|-------------|-----|-----------|
| Database criado | `oficina_mvp` | `oficina_extended` |
| Tabelas | 3 | 8 |
| Foreign keys | 0 | 8 |
| Seeds aplicados | 1 usuário, 2 clientes, 3 peças | + veículos, serviços, 1 OS com itens |
| Estoque crítico (PEC-003) | 1 registro | 1 registro |
| OS com JOINs | — | OK |

### Comandos de inspeção

```sql
SHOW TABLES FROM oficina_mvp;
SHOW TABLES FROM oficina_extended;

SELECT COUNT(*) AS fk_count
FROM information_schema.TABLE_CONSTRAINTS
WHERE CONSTRAINT_SCHEMA = 'oficina_extended'
  AND CONSTRAINT_TYPE = 'FOREIGN KEY';
```
