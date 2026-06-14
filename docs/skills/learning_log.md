# learning_log.md — Diário de Aprendizado

**⚠️ Arquivo vivo — atualizar conforme o projeto avança**

---

## Como usar este arquivo

Este é o seu diário técnico. Sempre que você aprender um conceito novo, resolver uma dúvida, ou entender o "porquê" por trás de uma decisão, registre aqui. Isso serve como:

1. **Referência pessoal** — Você vai esquecer detalhes. Este arquivo é sua memória externa.
2. **Rastreamento de evolução** — Daqui a 3 meses você vai olhar para este arquivo e perceber o quanto evoluiu.
3. **Identificação de padrões** — Se o mesmo tipo de dúvida aparece sempre, é um sinal de que aquele conceito precisa de mais atenção.

---

## Formato de Registro

```markdown
### [YYYY-MM-DD] — Título do Conceito

**Contexto:** Onde surgiu essa necessidade (ex: Sprint 2, implementando CRUD de Clientes)

**Conceito:**
Explicação com suas palavras do que foi aprendido.

**Exemplo prático:**
Código ou exemplo real do projeto.

**Dúvidas que ficaram:**
O que ainda não está claro.

**Fontes:**
Links ou referências consultadas.
```

---

## Registros

### [2026-05-30] — Por que UUID e não INTEGER auto-increment?

**Contexto:** Decisão arquitetural na Sprint 0 (ADR-001)

**Conceito:**
Quando o sistema precisa funcionar offline, múltiplos dispositivos podem criar registros ao mesmo tempo sem comunicação com o servidor central. Se usarmos ID numérico sequencial (1, 2, 3...), o terminal A pode criar o registro "42" e o terminal B também criar o registro "42" — quando os dois tentarem sincronizar, haverá uma colisão.

O UUID (Universally Unique Identifier) é um número de 128 bits gerado de forma que a probabilidade de dois UUIDs iguais sendo gerados independentemente é astronomicamente baixa (aproximadamente 1 em 5,3 × 10^36). Por isso, cada terminal pode gerar IDs localmente sem risco de colisão.

**Exemplo prático:**
```typescript
import { randomUUID } from 'crypto';

// ✅ Pode ser gerado offline, em qualquer terminal, sem colisão
const id = randomUUID(); // "550e8400-e29b-41d4-a716-446655440000"

// ❌ Requer comunicação com banco para obter próximo número
const id = await db.nextSequence('ordens_servico');
```

**Impacto no Prisma:**
```prisma
model Cliente {
  id String @id @default(uuid())
  // ...
}
```

**Dúvidas que ficaram:**
- Como o UUID afeta a performance de índices no PostgreSQL em grandes volumes?

---

### [2026-05-30] — Clean Architecture: por que separar em camadas?

**Contexto:** Definição da arquitetura do projeto na Sprint 0

**Conceito:**
A Clean Architecture resolve um problema real: quando você mistura regras de negócio com código de banco de dados ou código de framework, qualquer mudança em um afeta o outro. Quer trocar de PostgreSQL para MongoDB? Você vai ter que mexer nas regras de negócio. Quer mudar de Express para Fastify? Idem.

A solução é a **Regra de Dependência**: o código de negócio (domain) não depende de nada externo. O código externo (infrastructure, interfaces) é que depende do negócio — implementando interfaces que o domínio define.

**Analogia:**
Pense no domínio como uma especificação de tomada elétrica. A tomada define o padrão (interface). O fabricante do plugue (infrastructure) é que precisa se adequar ao padrão — não o contrário.

**Exemplo:**
```typescript
// domain/repositories/cliente.repository.ts
// O domínio define O QUE precisa, não COMO vai ser feito
export interface IClienteRepository {
  salvar(cliente: Cliente): Promise<void>;
  buscarPorCpf(cpf: string): Promise<Cliente | null>;
}

// infrastructure/database/prisma/cliente.prisma-repository.ts
// A infraestrutura implementa o contrato
export class ClientePrismaRepository implements IClienteRepository {
  async salvar(cliente: Cliente): Promise<void> {
    await prisma.cliente.create({ data: { ... } });
  }
}
```

Se amanhã você quiser usar MongoDB em vez de Prisma, você cria `ClienteMongoRepository` — sem tocar no domínio.

**Dúvidas que ficaram:**
- Quando faz sentido usar Domain Services vs. colocar a lógica na própria entidade?

---

### [2026-05-30] — Offline-First: o problema dos conflitos

**Contexto:** ADR-003 — Estratégia de Sincronização

**Conceito:**
O maior desafio do offline-first não é salvar os dados localmente — isso é relativamente simples. O desafio é o que acontece quando dois terminais modificam o mesmo dado enquanto estão offline.

Exemplo real:
- 08:00 — Terminal A (recepção): abre OS 42 com status ABERTA
- 09:00 — Terminal B (tablet do mecânico): muda OS 42 para EM_EXECUCAO (offline)
- 10:00 — Terminal A: cancela OS 42 (offline)
- 11:00 — Ambos reconectam e tentam sincronizar

Qual estado a OS deve ter? CANCELADA? EM_EXECUCAO?

Nossa estratégia (ADR-003): o estado mais avançado no fluxo vence + alerta ao usuário.

**O campo `version`:**
```typescript
// Toda entidade tem um campo version
// Quando vai sincronizar, verificamos se a versão local bate com a do servidor
// Se não bater, detectamos conflito
interface EntidadeBase {
  id: string;
  version: number; // incrementa a cada update
  updatedAt: Date;
  terminalId: string; // qual terminal fez a última modificação
}
```

**Dúvidas que ficaram:**
- Como vamos implementar o armazenamento local no frontend (IndexedDB? SQLite via Capacitor)?

---

*Novos registros devem ser adicionados acima deste texto, em ordem cronológica reversa (mais recente primeiro).*
