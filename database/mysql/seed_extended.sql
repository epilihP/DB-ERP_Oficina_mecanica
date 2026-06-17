-- =============================================================================
-- Seed de demonstração — Estendido (oficina_extended)
-- Executar após schema_extended.sql
-- =============================================================================

USE oficina_extended;

-- Usuario
INSERT INTO usuario (id, nome, email, senha_hash, perfil) VALUES
  ('a0000001-0000-4000-8000-000000000001', 'Ana Gerente', 'ana.gerente@oficina.com',
   '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/X4.G2oQ8KqOqH8KqO', 'GERENTE'),
  ('a0000002-0000-4000-8000-000000000002', 'Carlos Mecânico', 'carlos@oficina.com',
   '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/X4.G2oQ8KqOqH8KqO', 'FUNCIONARIO');

-- Clientes
INSERT INTO cliente (id, nome, tipo, cpf_cnpj, telefone, email) VALUES
  ('b0000001-0000-4000-8000-000000000001', 'João Silva', 'PF', '12345678901', '11999990001', 'joao@email.com'),
  ('b0000002-0000-4000-8000-000000000002', 'Auto Parts Ltda', 'PJ', '12345678000199', '1133334444', 'contato@autoparts.com');

-- Peças
INSERT INTO peca (id, codigo, descricao, unidade, preco_unitario, estoque_atual, estoque_minimo) VALUES
  ('c0000001-0000-4000-8000-000000000001', 'PEC-001', 'Filtro de óleo', 'UN', 45.90, 50, 10),
  ('c0000002-0000-4000-8000-000000000002', 'PEC-002', 'Pastilha de freio dianteira', 'UN', 189.00, 25, 5),
  ('c0000003-0000-4000-8000-000000000003', 'PEC-003', 'Correia dentada', 'UN', 120.00, 2, 5);

-- Veículos (pertencem a João Silva)
INSERT INTO veiculo (id, cliente_id, placa, marca, modelo, ano) VALUES
  ('d0000001-0000-4000-8000-000000000001', 'b0000001-0000-4000-8000-000000000001', 'ABC1D23', 'Volkswagen', 'Gol', 2018),
  ('d0000002-0000-4000-8000-000000000002', 'b0000001-0000-4000-8000-000000000001', 'EFG4H56', 'Fiat', 'Argo', 2022);

-- Serviços
INSERT INTO servico (id, codigo, descricao, preco_base) VALUES
  ('e0000001-0000-4000-8000-000000000001', 'SRV-001', 'Troca de óleo', 80.00),
  ('e0000002-0000-4000-8000-000000000002', 'SRV-002', 'Alinhamento e balanceamento', 150.00);

-- Ordem de serviço
INSERT INTO ordem_servico (id, cliente_id, veiculo_id, usuario_id, numero, status, data_abertura, observacoes) VALUES
  ('f0000001-0000-4000-8000-000000000001',
   'b0000001-0000-4000-8000-000000000001',
   'd0000001-0000-4000-8000-000000000001',
   'a0000002-0000-4000-8000-000000000002',
   'OS-2026-001', 'EM_ANDAMENTO', '2026-06-16 09:00:00',
   'Revisão periódica — troca de óleo e filtro');

-- Itens da OS — peças
INSERT INTO item_ordem_peca (id, ordem_servico_id, peca_id, quantidade, preco_unitario) VALUES
  ('g0000001-0000-4000-8000-000000000001', 'f0000001-0000-4000-8000-000000000001',
   'c0000001-0000-4000-8000-000000000001', 1, 45.90);

-- Itens da OS — serviços
INSERT INTO item_ordem_servico (id, ordem_servico_id, servico_id, quantidade_horas, preco) VALUES
  ('h0000001-0000-4000-8000-000000000001', 'f0000001-0000-4000-8000-000000000001',
   'e0000001-0000-4000-8000-000000000001', 1.00, 80.00);
