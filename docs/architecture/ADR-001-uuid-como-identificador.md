# ADR-001 — Uso de UUID v4 como Identificador Universal



---

## Contexto

O sistema precisa operar offline por vários dias. Durante esse período, múltiplos terminais criam registros localmente sem comunicação com o servidor central. Quando a sincronização ocorre, esses registros precisam ser inseridos no banco principal sem colisões de identificador.

O uso de **chaves primárias auto-incrementais** (INTEGER com SERIAL/AUTOINCREMENT) é incompatível com esse cenário porque:

- Terminal A cria OS com ID `1001` offline
- Terminal B cria OS com ID `1001` offline simultaneamente
- Na sincronização, há colisão — qual OS é `1001`?

---

## Decisão

**Todas as entidades do sistema utilizarão UUID v4 como chave primária.**

```typescript
// Correto — gerado localmente, globalmente único
const id = crypto.randomUUID(); // "a3b4c5d6-e7f8-4a1b-9c2d-0e3f4a5b6c7d"

// Errado para offline-first
const id = await db.sequence.nextval(); // Requer comunicação com banco
```

### Implementação no Prisma

```prisma
model OrdemServico {
  id        String   @id @default(uuid())
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
  // ...
}
```

---

## Consequências

**Positivas:**
- Elimina colisões de ID durante operação offline
- Permite geração de ID no cliente antes de persistir
- Simplifica a sincronização bidirecional

**Negativas:**
- UUIDs ocupam mais espaço que integers (16 bytes vs 4 bytes)
- Índices B-tree em UUIDs aleatórios têm inserção ligeiramente mais lenta
- URLs ficam menos amigáveis (`/os/a3b4c5d6-...` vs `/os/42`)

**Mitigação das negativas:**
- O volume de dados de uma oficina mecânica não justifica preocupação com espaço
- Para URLs públicas/relatórios, pode-se usar um código legível separado (ex: `OS-2026-0042`)

---

## Alternativas Consideradas

| Alternativa | Motivo da rejeição |
|-------------|-------------------|
| INTEGER auto-increment | Incompatível com offline-first |
| ULID (ordenável) | Complexidade adicional sem benefício claro no contexto |
| Nanoid curto | Probabilidade de colisão em múltiplos terminais |
