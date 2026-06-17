-- =============================================================================
-- Consultas analíticas — ERP Oficina Mecânica
-- Database: oficina_extended (modelo estendido com OS, peças e serviços)
-- Executar após schema_extended.sql + seed_extended.sql
-- =============================================================================

USE oficina_extended;

-- -----------------------------------------------------------------------------
-- 1. Qual cliente possui mais veículos?
--     (análogo: qual autor possui mais livros?)
-- -----------------------------------------------------------------------------
SELECT
  c.nome AS cliente,
  COUNT(v.id) AS total_veiculos
FROM cliente c
JOIN veiculo v ON v.cliente_id = c.id
GROUP BY c.id, c.nome
ORDER BY total_veiculos DESC
LIMIT 1;

-- -----------------------------------------------------------------------------
-- 2. Qual peça vende mais?
--     (análogo: qual livro vende mais?)
-- -----------------------------------------------------------------------------
SELECT
  p.codigo,
  p.descricao,
  SUM(iop.quantidade) AS total_vendido
FROM peca p
JOIN item_ordem_peca iop ON iop.peca_id = p.id
GROUP BY p.id, p.codigo, p.descricao
ORDER BY total_vendido DESC
LIMIT 1;

-- -----------------------------------------------------------------------------
-- 3. Qual serviço gera mais receita?
--     (análogo: qual editora gera mais receita?)
-- -----------------------------------------------------------------------------
SELECT
  s.codigo,
  s.descricao,
  SUM(ios.preco) AS receita_total
FROM servico s
JOIN item_ordem_servico ios ON ios.servico_id = s.id
GROUP BY s.id, s.codigo, s.descricao
ORDER BY receita_total DESC
LIMIT 1;

-- -----------------------------------------------------------------------------
-- 4. Quem é o cliente que mais compra?
--     (análogo: quem é o cliente que mais compra na livraria?)
--     Receita = peças + serviços em todas as OS do cliente
-- -----------------------------------------------------------------------------
SELECT
  c.nome AS cliente,
  SUM(
    COALESCE(receita_pecas.total, 0) + COALESCE(receita_servicos.total, 0)
  ) AS receita_total
FROM cliente c
JOIN ordem_servico os ON os.cliente_id = c.id
LEFT JOIN (
  SELECT ordem_servico_id, SUM(quantidade * preco_unitario) AS total
  FROM item_ordem_peca
  GROUP BY ordem_servico_id
) receita_pecas ON receita_pecas.ordem_servico_id = os.id
LEFT JOIN (
  SELECT ordem_servico_id, SUM(preco) AS total
  FROM item_ordem_servico
  GROUP BY ordem_servico_id
) receita_servicos ON receita_servicos.ordem_servico_id = os.id
GROUP BY c.id, c.nome
ORDER BY receita_total DESC
LIMIT 1;

-- -----------------------------------------------------------------------------
-- 5. Qual é o ticket médio da oficina?
--     (análogo: qual é o ticket médio da livraria?)
-- -----------------------------------------------------------------------------
SELECT
  ROUND(AVG(valor_os), 2) AS ticket_medio
FROM (
  SELECT
    os.id,
    COALESCE(SUM(iop.quantidade * iop.preco_unitario), 0)
      + COALESCE(SUM(ios.preco), 0) AS valor_os
  FROM ordem_servico os
  LEFT JOIN item_ordem_peca iop ON iop.ordem_servico_id = os.id
  LEFT JOIN item_ordem_servico ios ON ios.ordem_servico_id = os.id
  GROUP BY os.id
) totais_por_os;

-- -----------------------------------------------------------------------------
-- 6. Qual tipo de cliente possui mais cadastros?
--     (análogo: qual nacionalidade possui mais autores?)
-- -----------------------------------------------------------------------------
SELECT
  tipo,
  COUNT(*) AS total_clientes
FROM cliente
GROUP BY tipo
ORDER BY total_clientes DESC
LIMIT 1;

-- -----------------------------------------------------------------------------
-- 7. Quais peças possuem preço unitário acima de R$ 100,00?
--     (análogo: quais livros possuem mais de 300 páginas?)
-- -----------------------------------------------------------------------------
SELECT
  codigo,
  descricao,
  preco_unitario,
  estoque_atual,
  estoque_minimo
FROM peca
WHERE preco_unitario > 100.00
ORDER BY preco_unitario DESC;

-- -----------------------------------------------------------------------------
-- 8. Qual foi o mês com mais vendas?
--     (análogo: qual foi o mês com mais vendas?)
--     Conta ordens de serviço abertas por mês
-- -----------------------------------------------------------------------------
SELECT
  YEAR(data_abertura) AS ano,
  MONTH(data_abertura) AS mes,
  COUNT(*) AS total_ordens
FROM ordem_servico
GROUP BY YEAR(data_abertura), MONTH(data_abertura)
ORDER BY total_ordens DESC
LIMIT 1;

-- -----------------------------------------------------------------------------
-- 9. Qual cliente comprou mais peças?
--     (análogo: qual cliente comprou mais livros?)
-- -----------------------------------------------------------------------------
SELECT
  c.nome AS cliente,
  SUM(iop.quantidade) AS total_pecas_compradas
FROM cliente c
JOIN ordem_servico os ON os.cliente_id = c.id
JOIN item_ordem_peca iop ON iop.ordem_servico_id = os.id
GROUP BY c.id, c.nome
ORDER BY total_pecas_compradas DESC
LIMIT 1;

-- -----------------------------------------------------------------------------
-- 10. Qual mecânico gera mais faturamento?
--      (análogo: qual autor gera mais faturamento?)
-- -----------------------------------------------------------------------------
SELECT
  u.nome AS mecanico,
  SUM(
    COALESCE(receita_pecas.total, 0) + COALESCE(receita_servicos.total, 0)
  ) AS faturamento_total
FROM usuario u
JOIN ordem_servico os ON os.usuario_id = u.id
LEFT JOIN (
  SELECT ordem_servico_id, SUM(quantidade * preco_unitario) AS total
  FROM item_ordem_peca
  GROUP BY ordem_servico_id
) receita_pecas ON receita_pecas.ordem_servico_id = os.id
LEFT JOIN (
  SELECT ordem_servico_id, SUM(preco) AS total
  FROM item_ordem_servico
  GROUP BY ordem_servico_id
) receita_servicos ON receita_servicos.ordem_servico_id = os.id
GROUP BY u.id, u.nome
ORDER BY faturamento_total DESC
LIMIT 1;

-- =============================================================================
-- Consultas complementares — MVP (oficina_mvp)
-- Executar com: USE oficina_mvp;
-- =============================================================================

-- Peças em estoque crítico (útil na demo MVP)
-- USE oficina_mvp;
-- SELECT codigo, descricao, estoque_atual, estoque_minimo
-- FROM peca
-- WHERE estoque_atual < estoque_minimo;

-- Valor total do inventário (MVP)
-- SELECT SUM(preco_unitario * estoque_atual) AS valor_inventario
-- FROM peca;
