# ADR-003 — PostgreSQL como Banco Único e Escopo sem Operação Offline

**Status:** Aceito  
**Data:** 2026-06-14

---

## Contexto

Este é um projeto acadêmico cujo objetivo principal é **modelar um banco de dados relacional** para uma oficina mecânica, com um CRUD simples (Clientes e Peças) e login por perfis. Precisamos decidir a topologia de dados: quantos bancos, quais tecnologias e se haverá suporte a operação offline com sincronização.

Quanto mais componentes (bancos auxiliares, cache, mensageria, camada de sincronização), maior a complexidade — sem benefício real para o escopo proposto.

---

## Decisão

**Utilizaremos um único banco de dados relacional (PostgreSQL), acessado via Prisma, sem operação offline nem sincronização.**

- Toda a persistência fica em um único PostgreSQL.
- Não há MongoDB, Redis, RabbitMQ ou qualquer banco/serviço auxiliar.
- O sistema assume conectividade com o banco (online); não há fila local nem resolução de conflitos.

### Modelagem (Prisma)

```prisma
model Usuario {
  id        String   @id @default(uuid())
  nome      String
  email     String   @unique
  senhaHash String
  perfil    Perfil
  createdAt DateTime @default(now())
}

model Cliente {
  id        String   @id @default(uuid())
  nome      String
  tipo      TipoCliente
  cpfCnpj   String   @unique
  telefone  String?
  email     String?
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}

model Peca {
  id            String   @id @default(uuid())
  codigo        String   @unique
  descricao     String
  unidade       String
  precoUnitario Decimal
  estoqueAtual  Int
  estoqueMinimo Int
  createdAt     DateTime @default(now())
  updatedAt     DateTime @updatedAt
}
```

---

## Consequências

**Positivas:**
- Arquitetura simples e fácil de subir (`docker compose up -d` com um único serviço)
- Foco total na modelagem relacional, que é o objetivo do trabalho
- Menos pontos de falha e menor custo de manutenção

**Negativas:**
- Indisponibilidade do banco implica indisponibilidade do sistema (não há modo offline)
- Não há cache nem mensageria para cenários de alta carga

**Mitigação:**
- O escopo (CRUD acadêmico) não exige alta disponibilidade nem alta carga
- Caso necessário no futuro, cache/mensageria podem ser adicionados em ADRs próprios

---

## Alternativas Consideradas

| Alternativa | Motivo da rejeição |
|-------------|-------------------|
| Operação offline com sincronização | Complexidade muito alta e fora do escopo acadêmico do projeto |
| Múltiplos bancos (PostgreSQL + MongoDB) | Sem necessidade; o domínio é totalmente relacional |
| Cache (Redis) e mensageria (RabbitMQ) | Infra desnecessária para um CRUD simples |
