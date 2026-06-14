# metrics.md — Métricas do Sistema

**Versão:** 1.0.0  
**Última atualização:** 2026-05-30

---

## 1. Métricas de Produto (KPIs de Negócio)

Estas métricas devem ser coletadas e exibidas no dashboard do sistema.

### Operacional

| Métrica | Descrição | Meta |
|---------|-----------|------|
| OS abertas hoje | Total de OS com status ABERTA ou EM_EXECUCAO | Monitoramento |
| Tempo médio de atendimento | Da abertura à conclusão da OS | < 2 dias |
| OS aguardando peça | Quantas OS estão bloqueadas por falta de estoque | < 5% do total |
| Taxa de cancelamento | OS canceladas / total de OS abertas | < 3% |
| Ocupação de mecânicos | Horas em OS / horas disponíveis | > 70% |

### Estoque

| Métrica | Descrição | Meta |
|---------|-----------|------|
| Itens em estoque crítico | Peças abaixo do mínimo configurado | 0 |
| Giro de estoque | Quantas vezes o estoque foi renovado no período | Monitoramento |
| Precisão de inventário | Contagem física vs. sistema | > 98% |

---

## 2. Métricas Técnicas (Observabilidade)

### Latência (RED Method)

| Métrica | Instrumento | Alerta |
|---------|------------|--------|
| `http_request_duration_ms` (p50, p95, p99) | Prometheus Histogram | p95 > 500ms |
| `db_query_duration_ms` (p95) | Prometheus Histogram | p95 > 100ms |
| `cache_hit_ratio` | Prometheus Gauge | < 70% |

### Throughput

| Métrica | Instrumento | Alerta |
|---------|------------|--------|
| `http_requests_total` | Prometheus Counter | — |
| `http_requests_per_second` | Prometheus Rate | — |
| `rabbitmq_messages_published_total` | Prometheus Counter | — |

### Erros

| Métrica | Instrumento | Alerta |
|---------|------------|--------|
| `http_errors_total{status="5xx"}` | Prometheus Counter | > 1% das requests |
| `http_errors_total{status="4xx"}` | Prometheus Counter | Monitoramento |
| `db_connection_errors_total` | Prometheus Counter | > 0 |
| `sync_conflicts_total` | Prometheus Counter | > 10/dia |

### Infraestrutura

| Métrica | Instrumento | Alerta |
|---------|------------|--------|
| CPU Usage | Node.js process + cAdvisor | > 80% sustentado |
| Memory heap used | Node.js process metrics | > 85% do limite |
| PostgreSQL connections | pg_stat_activity | > 80% do pool |
| Redis memory | Redis INFO | > 80% do max |

---

## 3. Métricas de Qualidade de Código (CI)

| Métrica | Ferramenta | Meta |
|---------|-----------|------|
| Cobertura de testes | Vitest + v8 | ≥ 80% |
| Erros de lint | ESLint | 0 erros |
| Erros de TypeScript | tsc --noEmit | 0 erros |
| Tempo de build | GitHub Actions | < 3 min |
| Tempo de testes | GitHub Actions | < 2 min |

---

## 4. Métricas de Sincronização Offline

Específicas para o módulo de sync — críticas para o negócio.

| Métrica | Descrição | Alerta |
|---------|-----------|--------|
| `sync_queue_size` | Eventos pendentes de sincronização | > 1000 |
| `sync_lag_seconds` | Tempo desde o último sync bem-sucedido | > 3600s (1h) |
| `sync_conflicts_total` | Total de conflitos detectados | Monitoramento |
| `sync_conflicts_auto_resolved` | Conflitos resolvidos automaticamente | Monitoramento |
| `sync_conflicts_manual_required` | Conflitos que precisam de intervenção | > 0 → alerta |
| `sync_errors_total` | Falhas no processo de sincronização | > 5 → alerta |

---

## 5. Stack de Observabilidade

```
Aplicação (Fastify)
    ↓ métricas
Prometheus ←── scraping a cada 15s
    ↓
Grafana ←── dashboards e alertas
    ↓
PagerDuty / Slack ←── notificações de alerta

Aplicação (Fastify)
    ↓ logs JSON
Loki / CloudWatch
    ↓
Grafana ←── busca e correlação de logs

Aplicação (Fastify + OpenTelemetry)
    ↓ traces
Jaeger / Tempo
    ↓
Grafana ←── rastreamento distribuído
```

---

## 6. Health Check

O endpoint `GET /health` deve retornar o status de cada dependência:

```json
{
  "status": "healthy",
  "timestamp": "2026-05-30T10:00:00.000Z",
  "version": "1.0.0",
  "services": {
    "database": {
      "status": "healthy",
      "latencyMs": 3
    },
    "redis": {
      "status": "healthy",
      "latencyMs": 1
    },
    "rabbitmq": {
      "status": "degraded",
      "error": "Connection timeout"
    }
  }
}
```

**Códigos HTTP:**
- `200` — todos os serviços saudáveis
- `207` — alguns serviços degradados (partial health)
- `503` — serviço indisponível (banco principal fora)
