# testing_strategy.md — Estratégia de Testes

**Versão:** 1.0.0  
**Última atualização:** 2026-05-30

---

## Filosofia de Testes

> "Testes não são para provar que o código funciona. São para ter coragem de mudar o código sem medo de quebrar algo."

O projeto segue a **Pirâmide de Testes**:

```
        /\
       /E2E\        ← Poucos, lentos, caros — testam o sistema completo
      /──────\
     /  Integ. \    ← Médios — testam integração entre camadas
    /────────────\
   /   Unitários  \ ← Muitos, rápidos, baratos — testam lógica isolada
  /────────────────\
```

**Meta de cobertura:** ≥ 80% em todas as camadas de negócio  
**Framework:** Vitest (mais rápido que Jest, nativo com ESM/TypeScript)

---

## 1. Testes Unitários

### O que testar

- Entidades de domínio (regras de negócio, transições de estado)
- Use Cases (orquestração, validações de negócio)
- Domain Services
- Utilitários e helpers

### O que NÃO testar unitariamente

- Controllers (testados em integração)
- Repositórios concretos (testados em integração com banco real)
- Configuração de framework

### Regras

```typescript
// ✅ Sempre usar mocks para dependências externas
// ✅ Seguir padrão AAA (Arrange, Act, Assert)
// ✅ Um teste = um comportamento específico
// ✅ Nome do teste descreve o comportamento esperado
// ❌ Nunca conectar em banco real
// ❌ Nunca fazer chamadas HTTP reais

// Exemplo: src/tests/unit/domain/entities/ordem-servico.spec.ts
describe('OrdemServico', () => {
  describe('abrir()', () => {
    it('deve transicionar para ABERTA quando status atual é RASCUNHO', () => {
      const os = OrdemServico.criar({ clienteId: 'id', veiculoId: 'id', descricao: 'teste' });
      os.abrir();
      expect(os.status).toBe('ABERTA');
    });

    it('deve lançar TransicaoEstadoInvalidaError quando status atual não é RASCUNHO', () => {
      const os = OrdemServico.criar({ clienteId: 'id', veiculoId: 'id', descricao: 'teste' });
      os.abrir(); // está ABERTA agora

      expect(() => os.abrir()).toThrow(TransicaoEstadoInvalidaError);
    });
  });
});
```

### Comandos

```bash
npm run test:unit          # Executa apenas testes unitários
npm run test:unit:watch    # Modo watch para desenvolvimento
npm run test:unit:coverage # Com relatório de cobertura
```

---

## 2. Testes de Integração

### O que testar

- Controllers + Use Cases + Repositórios (fluxo completo de uma requisição)
- Queries Prisma contra banco real (PostgreSQL em container de teste)
- Integração com Redis (cache, sessões)
- Publicação/consumo de mensagens RabbitMQ

### Estratégia

```typescript
// Banco de teste isolado — cada suite de teste usa schema separado
// Fixtures criadas antes de cada teste, limpas depois

// Exemplo: src/tests/integration/os/criar-os.integration.spec.ts
describe('POST /api/v1/os', () => {
  let app: FastifyInstance;
  let authToken: string;

  beforeAll(async () => {
    app = await buildTestApp();
    await runMigrations();
    authToken = await getTestToken(app, 'RECEPCIONISTA');
  });

  afterAll(async () => {
    await cleanDatabase();
    await app.close();
  });

  it('deve criar uma OS com status RASCUNHO e retornar 201', async () => {
    const cliente = await createTestCliente();
    const veiculo = await createTestVeiculo(cliente.id);

    const response = await app.inject({
      method: 'POST',
      url: '/api/v1/os',
      headers: { authorization: `Bearer ${authToken}` },
      payload: {
        clienteId: cliente.id,
        veiculoId: veiculo.id,
        descricaoProblema: 'Troca de óleo',
      },
    });

    expect(response.statusCode).toBe(201);
    expect(response.json().status).toBe('RASCUNHO');
    expect(response.json().id).toMatch(UUID_REGEX);
  });
});
```

### Ambiente de Teste

```yaml
# docker-compose.test.yml — banco isolado para testes
services:
  postgres-test:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: mechanicos_test
      POSTGRES_USER: test
      POSTGRES_PASSWORD: test
    ports:
      - "5433:5432"  # Porta diferente para não conflitar com dev
```

### Comandos

```bash
npm run test:integration          # Executa testes de integração
npm run test:integration:watch    # Modo watch
```

---

## 3. Testes E2E

### O que testar

- Fluxos críticos de negócio de ponta a ponta
- Cenários de usuário reais (ex: "abrir OS → executar → concluir → faturar")
- Fluxos de autenticação e autorização

### Estratégia

```typescript
// Testam contra a aplicação rodando completamente
// Usam supertest ou fetch real contra a API
// Cenários escritos como "histórias de usuário"

// Exemplo: src/tests/e2e/fluxo-os-completo.e2e.spec.ts
describe('Fluxo completo de Ordem de Serviço', () => {
  it('deve permitir que recepcionista abra OS, mecânico execute e conclua', async () => {
    // 1. Login como recepcionista
    const recepcionista = await login('recepcionista@test.com', 'senha123');

    // 2. Criar cliente e veículo
    const cliente = await criarCliente(recepcionista.token, { nome: 'João Silva', cpf: '...' });
    const veiculo = await criarVeiculo(recepcionista.token, { clienteId: cliente.id, placa: 'ABC-1234' });

    // 3. Abrir OS
    const os = await abrirOS(recepcionista.token, { clienteId: cliente.id, veiculoId: veiculo.id });
    expect(os.status).toBe('RASCUNHO');

    // 4. Login como mecânico
    const mecanico = await login('mecanico@test.com', 'senha123');

    // 5. Iniciar execução
    await iniciarExecucao(mecanico.token, os.id);

    // 6. Concluir OS
    await concluirOS(mecanico.token, os.id);

    // 7. Verificar estado final
    const osFinal = await buscarOS(recepcionista.token, os.id);
    expect(osFinal.status).toBe('CONCLUIDA');
  });
});
```

### Comandos

```bash
npm run test:e2e     # Executa testes E2E (requer docker compose up)
```

---

## 4. Testes de Carga

### Ferramenta: k6

```javascript
// tests/load/os-creation.js
import http from 'k6/http';
import { check } from 'k6';

export const options = {
  vus: 50,           // 50 usuários virtuais simultâneos
  duration: '30s',   // por 30 segundos
  thresholds: {
    http_req_duration: ['p95<200'],  // 95% das respostas < 200ms
    http_req_failed: ['rate<0.01'],  // menos de 1% de erros
  },
};

export default function () {
  const response = http.post('http://localhost:3000/api/v1/os', JSON.stringify({
    clienteId: 'test-cliente-id',
    veiculoId: 'test-veiculo-id',
    descricaoProblema: 'Teste de carga',
  }), { headers: { 'Content-Type': 'application/json' } });

  check(response, { 'status 201': (r) => r.status === 201 });
}
```

### Quando executar

- Antes de cada release em staging
- Sempre que uma query crítica for modificada

---

## 5. Testes de Regressão

- Cada bug corrigido deve ter um teste que reproduz o bug antes da correção
- O teste deve falhar sem a correção e passar com ela

```typescript
// Sempre comentar com referência ao bug
it('deve calcular corretamente o valor total quando há desconto por percentual [BUG-042]', () => {
  // ...
});
```

---

## Configuração do Vitest

```typescript
// vitest.config.ts
import { defineConfig } from 'vitest/config';
import tsconfigPaths from 'vite-tsconfig-paths';

export default defineConfig({
  plugins: [tsconfigPaths()],
  test: {
    globals: true,
    environment: 'node',
    include: ['src/tests/**/*.spec.ts'],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html'],
      exclude: ['src/tests/**', 'src/shared/types/**'],
      thresholds: {
        lines: 80,
        functions: 80,
        branches: 80,
        statements: 80,
      },
    },
  },
});
```
