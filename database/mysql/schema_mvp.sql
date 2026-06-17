-- =============================================================================
-- ERP Oficina Mecânica — Modelo Físico MVP (standalone)
-- Database: oficina_mvp
-- Tabelas: usuario, cliente, peca (sem FKs)
-- Requer: MySQL 8.0+
-- =============================================================================

DROP DATABASE IF EXISTS oficina_mvp;

CREATE DATABASE oficina_mvp
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE oficina_mvp;

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
