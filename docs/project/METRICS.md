# metrics.md — Métricas do Sistema

**Versão:** 1.0.0  
**Última atualização:** 2026-06-14

---

## 1. Métricas de Produto

Métricas simples que podem ser consultadas a partir do banco de dados.

| Métrica | Descrição |
|---------|-----------|
| Total de clientes | Quantidade de clientes cadastrados |
| Clientes por tipo | Distribuição entre PF e PJ |
| Total de peças | Quantidade de peças cadastradas |
| Peças em estoque crítico | Peças com `estoqueAtual` abaixo do `estoqueMinimo` |
| Valor total em estoque | Soma de `precoUnitario * estoqueAtual` |

---

## 2. Métricas Técnicas

| Métrica | Descrição | Alerta |
|---------|-----------|--------|
| Tempo de resposta da API (p95) | Latência das operações simples | > 200ms |
| Tempo de query no banco (p95) | Latência das consultas ao PostgreSQL | > 100ms |
| Erros 5xx | Erros internos do servidor | > 1% das requests |
| Erros 4xx | Erros de validação/autorização | Monitoramento |

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

## 4. Health Check

O endpoint `GET /health` deve retornar o status do banco de dados:

```json
{
  "status": "healthy",
  "timestamp": "2026-06-14T10:00:00.000Z",
  "version": "1.0.0",
  "services": {
    "database": {
      "status": "healthy",
      "latencyMs": 3
    }
  }
}
```

**Códigos HTTP:**
- `200` — banco saudável
- `503` — banco indisponível
