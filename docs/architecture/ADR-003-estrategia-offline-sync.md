# ADR-003 — Estratégia de Sincronização Offline-First

**Data:** 2026-05-30  
**Status:** ✅ Aceito  
**Autor:** Equipe de Engenharia  
**Contexto:** O sistema deve operar offline por até 7 dias com sincronização posterior

---

## Contexto

A oficina opera em ambiente com internet instável, podendo ficar dias sem conexão. O sistema precisa de uma estratégia clara para:

1. Armazenar dados localmente durante operação offline
2. Sincronizar com o servidor quando a conexão retornar
3. Resolver conflitos quando a mesma entidade foi modificada offline em múltiplos terminais

---

## Decisão

**Adotaremos a estratégia de Event Sourcing leve com timestamps de vetor lógico (Logical Timestamps) para detecção de conflitos.**

### Princípios Fundamentais

#### 1. Todo evento é imutável e registrado

Em vez de apenas salvar o estado atual da entidade, registramos **cada mudança como um evento**:

```typescript
// Não fazemos apenas isso:
UPDATE ordens_servico SET status = 'CONCLUIDA' WHERE id = '...'

// Fazemos isso também:
INSERT INTO eventos_os (id, os_id, tipo, payload, created_at, terminal_id)
VALUES (uuid(), '...', 'OS_CONCLUIDA', '{"mecanico_id": "..."}', NOW(), 'terminal-A')
```

#### 2. Cada registro tem metadados de sincronização

```prisma
model OrdemServico {
  id            String    @id @default(uuid())
  // ... campos de negócio ...

  // Metadados de sync
  createdAt     DateTime  @default(now())
  updatedAt     DateTime  @updatedAt
  syncedAt      DateTime? // null = ainda não sincronizado
  terminalId    String    // qual terminal criou/editou por último
  version       Int       @default(1) // controle de versão otimista
  deletedAt     DateTime? // soft delete — nunca apagamos fisicamente
}
```

#### 3. Regras de resolução de conflito

| Cenário | Regra |
|---------|-------|
| Mesma entidade editada em dois terminais | **Last-Write-Wins** com alerta ao usuário |
| OS concluída offline + edição online simultânea | **Estado mais avançado vence** (fluxo de estados) |
| Estoque negativo após sync | **Alerta manual obrigatório** — não resolve automaticamente |
| Entidade criada com mesmo dado único (ex: mesma placa) | **Merge manual** — sistema destaca o duplicado |

#### 4. Fila de sincronização

```typescript
// Cada operação offline é enfileirada localmente
interface EventoSync {
  id: string;           // UUID do evento
  tipo: TipoEvento;     // CREATE | UPDATE | DELETE
  entidade: string;     // 'OrdemServico' | 'Peca' | etc
  entityId: string;     // UUID da entidade
  payload: unknown;     // dados da operação
  terminalId: string;   // origem
  timestamp: string;    // UTC ISO 8601
  tentativas: number;   // para retry automático
}
```

---

## Fluxo de Sincronização

```
Terminal Offline                    Servidor Central
     │                                    │
     │  [Opera normalmente]               │
     │  [Salva em IndexedDB/LocalDB]      │
     │                                    │
     │  ── Conexão restabelecida ──────►  │
     │                                    │
     │  Envia fila de eventos ──────────► │
     │                                    │  Processa evento por evento
     │                                    │  Detecta conflitos
     │                                    │  Aplica regras de resolução
     │                                    │
     │  ◄─── Resultado da sync ─────────  │
     │  (ok / conflitos / erros)          │
     │                                    │
     │  Atualiza estado local             │
```

---

## Consequências

**Positivas:**
- Operação totalmente funcional sem internet
- Histórico completo de todas as operações (auditoria)
- Possibilidade de "replay" de eventos para recuperação de dados

**Negativas:**
- Complexidade arquitetural maior que sistemas online-only
- Necessidade de UI para resolução manual de conflitos em casos edge
- Maior consumo de armazenamento local

**Mitigação:**
- A complexidade fica isolada no módulo `SyncService`
- O resto do sistema não precisa saber se está online ou offline
- Purge automático de eventos sincronizados após 30 dias

---

## Alternativas Consideradas

| Alternativa | Motivo da rejeição |
|-------------|-------------------|
| Apenas cache local sem sync bidirecional | Perde dados críticos se o terminal falhar |
| CRDTs completos | Complexidade muito alta para o contexto e equipe |
| Replicação de banco (Postgres streaming replication) | Requer conectividade para configurar réplica |
