# ADR-002 — Fastify como Framework HTTP Principal



---

## Contexto

A stack exige Node.js + TypeScript. Dois frameworks são candidatos naturais: **Express** e **Fastify**. Ambos têm suporte à stack, mas características arquiteturais distintas.

---

## Decisão

**Utilizaremos Fastify como framework HTTP principal.**

Express será estudado para fins comparativos e de aprendizado, mas não será usado em produção.

---

## Justificativa Técnica

### Performance

O Fastify utiliza uma **Radix Tree** para roteamento (complexidade logarítmica), enquanto o Express usa expressões regulares lineares. Em benchmarks da comunidade, o Fastify processa consistentemente **2x a 3x mais requisições por segundo**.

Para uma oficina mecânica o volume não é crítico, mas o padrão de qualidade do projeto exige que escolhamos a melhor ferramenta disponível.

### Validação Nativa

```typescript
// Fastify — validação integrada via JSON Schema
fastify.post('/os', {
  schema: {
    body: {
      type: 'object',
      required: ['clienteId', 'veiculoId'],
      properties: {
        clienteId: { type: 'string', format: 'uuid' },
        veiculoId: { type: 'string', format: 'uuid' }
      }
    }
  }
}, handler)

// Express — precisa de biblioteca externa (Joi, express-validator)
router.post('/os', validate(schema), handler)
```

### TypeScript de Primeira Classe

O Fastify tem suporte nativo a TypeScript, com tipos genéricos para request/reply:

```typescript
fastify.get<{
  Params: { id: string };
  Reply: OrdemServicoDto;
}>('/os/:id', async (request, reply) => {
  // request.params.id é string tipado
  // reply deve ser OrdemServicoDto
})
```

### Sistema de Plugins

O Fastify usa encapsulamento de contexto via plugins, o que se alinha com nossa arquitetura modular:

```typescript
// Cada módulo é um plugin isolado
fastify.register(operacionalPlugin, { prefix: '/api/v1/operacional' })
fastify.register(estoquePlugin,     { prefix: '/api/v1/estoque' })
```

---

## Consequências

**Positivas:**
- Melhor performance
- TypeScript nativo sem configuração extra
- Validação integrada que complementa Zod
- Sistema de plugins modular por design

**Negativas:**
- Ecossistema menor que Express
- Menos exemplos e tutoriais disponíveis online
- Curva de aprendizado ligeiramente maior

---

## Alternativas Consideradas

| Alternativa | Motivo da rejeição |
|-------------|-------------------|
| Express | Performance inferior, sem TypeScript nativo, arquitetura antiga |
| Hono | Excelente, mas menos maduro para projetos corporativos |
| NestJS | Muito opinativo, adiciona camada de complexidade desnecessária para o contexto |
