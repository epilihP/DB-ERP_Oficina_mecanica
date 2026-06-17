-- =============================================================================
-- Seed de demonstração — MVP (oficina_mvp)
-- Executar após schema_mvp.sql
-- =============================================================================

USE oficina_mvp;

-- Usuario gerente (senha_hash é placeholder — bcrypt de "senha123" fictício)
INSERT INTO usuario (id, nome, email, senha_hash, perfil) VALUES
  ('a0000001-0000-4000-8000-000000000001', 'Ana Gerente', 'ana.gerente@oficina.com',
   '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/X4.G2oQ8KqOqH8KqO', 'GERENTE');

-- Clientes PF e PJ
INSERT INTO cliente (id, nome, tipo, cpf_cnpj, telefone, email) VALUES
  ('b0000001-0000-4000-8000-000000000001', 'João Silva', 'PF', '12345678901', '11999990001', 'joao@email.com'),
  ('b0000002-0000-4000-8000-000000000002', 'Auto Parts Ltda', 'PJ', '12345678000199', '1133334444', 'contato@autoparts.com');

-- Peças (PEC-003 com estoque crítico)
INSERT INTO peca (id, codigo, descricao, unidade, preco_unitario, estoque_atual, estoque_minimo) VALUES
  ('c0000001-0000-4000-8000-000000000001', 'PEC-001', 'Filtro de óleo', 'UN', 45.90, 50, 10),
  ('c0000002-0000-4000-8000-000000000002', 'PEC-002', 'Pastilha de freio dianteira', 'UN', 189.00, 25, 5),
  ('c0000003-0000-4000-8000-000000000003', 'PEC-003', 'Correia dentada', 'UN', 120.00, 2, 5);
