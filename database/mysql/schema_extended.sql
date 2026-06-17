-- =============================================================================
-- ERP Oficina Mecânica — Modelo Físico Estendido (standalone)
-- Database: oficina_extended
-- Tabelas: 8 (usuario, cliente, peca, veiculo, servico, ordem_servico,
--          item_ordem_peca, item_ordem_servico)
-- Requer: MySQL 8.0+
-- =============================================================================

DROP DATABASE IF EXISTS oficina_extended;

CREATE DATABASE oficina_extended
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE oficina_extended;

-- -----------------------------------------------------------------------------
-- usuario
-- -----------------------------------------------------------------------------
CREATE TABLE usuario (
  id          CHAR(36)     NOT NULL DEFAULT (UUID()),
  nome        VARCHAR(150) NOT NULL,
  email       VARCHAR(255) NOT NULL,
  senha_hash  VARCHAR(255) NOT NULL,
  perfil      ENUM('GERENTE', 'FUNCIONARIO') NOT NULL,
  created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_usuario_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- cliente
-- -----------------------------------------------------------------------------
CREATE TABLE cliente (
  id          CHAR(36)     NOT NULL DEFAULT (UUID()),
  nome        VARCHAR(150) NOT NULL,
  tipo        ENUM('PF', 'PJ') NOT NULL,
  cpf_cnpj    VARCHAR(14)  NOT NULL,
  telefone    VARCHAR(20)  NULL,
  email       VARCHAR(255) NULL,
  created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_cliente_cpf_cnpj (cpf_cnpj)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- peca
-- -----------------------------------------------------------------------------
CREATE TABLE peca (
  id              CHAR(36)       NOT NULL DEFAULT (UUID()),
  codigo          VARCHAR(50)    NOT NULL,
  descricao       VARCHAR(255)   NOT NULL,
  unidade         VARCHAR(20)    NOT NULL,
  preco_unitario  DECIMAL(10, 2) NOT NULL,
  estoque_atual   INT            NOT NULL,
  estoque_minimo  INT            NOT NULL,
  created_at      DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_peca_codigo (codigo),
  CONSTRAINT chk_peca_estoque_nonneg CHECK (estoque_atual >= 0 AND estoque_minimo >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- veiculo
-- -----------------------------------------------------------------------------
CREATE TABLE veiculo (
  id          CHAR(36)     NOT NULL DEFAULT (UUID()),
  cliente_id  CHAR(36)     NOT NULL,
  placa       VARCHAR(10)  NOT NULL,
  marca       VARCHAR(80)  NOT NULL,
  modelo      VARCHAR(80)  NOT NULL,
  ano         INT          NOT NULL,
  created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_veiculo_placa (placa),
  KEY idx_veiculo_cliente_id (cliente_id),
  CONSTRAINT fk_veiculo_cliente
    FOREIGN KEY (cliente_id) REFERENCES cliente (id)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- servico
-- -----------------------------------------------------------------------------
CREATE TABLE servico (
  id          CHAR(36)       NOT NULL DEFAULT (UUID()),
  codigo      VARCHAR(50)    NOT NULL,
  descricao   VARCHAR(255)   NOT NULL,
  preco_base  DECIMAL(10, 2) NOT NULL,
  created_at  DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_servico_codigo (codigo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- ordem_servico
-- -----------------------------------------------------------------------------
CREATE TABLE ordem_servico (
  id              CHAR(36)     NOT NULL DEFAULT (UUID()),
  cliente_id      CHAR(36)     NOT NULL,
  veiculo_id      CHAR(36)     NOT NULL,
  usuario_id      CHAR(36)     NOT NULL,
  numero          VARCHAR(20)  NOT NULL,
  status          ENUM('ABERTA', 'EM_ANDAMENTO', 'CONCLUIDA', 'CANCELADA') NOT NULL,
  data_abertura   DATETIME     NOT NULL,
  data_conclusao  DATETIME     NULL,
  observacoes     TEXT         NULL,
  created_at      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_ordem_servico_numero (numero),
  KEY idx_ordem_servico_cliente_id (cliente_id),
  KEY idx_ordem_servico_veiculo_id (veiculo_id),
  KEY idx_ordem_servico_usuario_id (usuario_id),
  CONSTRAINT fk_ordem_servico_cliente
    FOREIGN KEY (cliente_id) REFERENCES cliente (id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_ordem_servico_veiculo
    FOREIGN KEY (veiculo_id) REFERENCES veiculo (id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_ordem_servico_usuario
    FOREIGN KEY (usuario_id) REFERENCES usuario (id)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- item_ordem_peca (entidade associativa — N:N ordem_servico ↔ peca)
-- -----------------------------------------------------------------------------
CREATE TABLE item_ordem_peca (
  id              CHAR(36)       NOT NULL DEFAULT (UUID()),
  ordem_servico_id CHAR(36)       NOT NULL,
  peca_id         CHAR(36)       NOT NULL,
  quantidade      INT            NOT NULL,
  preco_unitario  DECIMAL(10, 2) NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_item_ordem_peca_os_peca (ordem_servico_id, peca_id),
  KEY idx_item_ordem_peca_peca_id (peca_id),
  CONSTRAINT fk_item_ordem_peca_ordem
    FOREIGN KEY (ordem_servico_id) REFERENCES ordem_servico (id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_item_ordem_peca_peca
    FOREIGN KEY (peca_id) REFERENCES peca (id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT chk_item_ordem_peca_quantidade CHECK (quantidade > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- item_ordem_servico (entidade associativa — N:N ordem_servico ↔ servico)
-- -----------------------------------------------------------------------------
CREATE TABLE item_ordem_servico (
  id               CHAR(36)       NOT NULL DEFAULT (UUID()),
  ordem_servico_id CHAR(36)       NOT NULL,
  servico_id       CHAR(36)       NOT NULL,
  quantidade_horas DECIMAL(10, 2) NOT NULL,
  preco            DECIMAL(10, 2) NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_item_ordem_servico_os_servico (ordem_servico_id, servico_id),
  KEY idx_item_ordem_servico_servico_id (servico_id),
  CONSTRAINT fk_item_ordem_servico_ordem
    FOREIGN KEY (ordem_servico_id) REFERENCES ordem_servico (id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_item_ordem_servico_servico
    FOREIGN KEY (servico_id) REFERENCES servico (id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT chk_item_ordem_servico_horas CHECK (quantidade_horas > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
