# ADR-001 — Uso de UUID v4 como Identificador

**Status:** Aceito  
**Data:** 2026-06-14

---

## Contexto

O sistema precisa de uma chave primária para cada entidade do banco (`Usuario`, `Cliente`, `Peca`). Há duas abordagens comuns: chaves inteiras auto-incrementais (SERIAL) e identificadores únicos universais (UUID).

Como o foco do trabalho é a **modelagem do banco com boas práticas**, queremos uma escolha de chave que seja segura, previsível para a aplicação e fácil de manter.

---

## Decisão

**Todas as entidades do sistema utilizarão UUID v4 como chave primária.**

```typescript
// Gerado pela aplicação, globalmente único
const id = crypto.randomUUID(); // "a3b4c5d6-e7f8-4a1b-9c2d-0e3f4a5b6c7d"
```

### Implementação no Prisma

```prisma
model Cliente {
  id        String   @id @default(uuid())
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
  // ...
}
```

---

## Justificativa

- **Boas práticas de modelagem:** UUID é amplamente adotado e padroniza a chave entre todas as entidades.
- **Não expõe volume de dados:** IDs sequenciais em URLs (`/clientes/42`) revelam quantos registros existem e permitem enumeração; UUIDs evitam isso.
- **Geração na aplicação:** o ID pode ser gerado antes de persistir, simplificando testes e a montagem de respostas.

---

## Consequências

**Positivas:**
- Padronização da chave primária em todo o modelo
- URLs não enumeráveis (mais difícil "adivinhar" registros)
- ID disponível na aplicação antes da escrita no banco

**Negativas:**
- UUIDs ocupam mais espaço que integers (16 bytes vs 4 bytes)
- Índices B-tree em UUIDs aleatórios têm inserção ligeiramente mais lenta
- URLs ficam menos amigáveis (`/clientes/a3b4c5d6-...` vs `/clientes/42`)

**Mitigação das negativas:**
- O volume de dados de uma oficina mecânica não justifica preocupação com espaço ou performance de índice
- Para relatórios/exibição pode-se usar um código legível separado (ex: o campo `codigo` da peça)

---

## Alternativas Consideradas

| Alternativa | Motivo da rejeição |
|-------------|-------------------|
| INTEGER auto-increment | Expõe volume e permite enumeração de registros |
| ULID (ordenável) | Complexidade adicional sem benefício claro neste contexto |
| Nanoid curto | Sem padronização com o ecossistema; menos comum em modelagem relacional |
