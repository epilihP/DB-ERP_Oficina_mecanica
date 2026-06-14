# code_style.md — Padrões de Código

**Versão:** 1.0.0  
**Última atualização:** 2026-05-30

---

## 1. Nomenclatura

### Arquivos e Pastas

```
kebab-case para arquivos e pastas:
  ordem-servico.entity.ts
  criar-ordem-servico.use-case.ts
  ordem-servico.repository.ts
  ordem-servico.controller.ts

Sufixos obrigatórios por tipo:
  *.entity.ts          → entidades de domínio
  *.use-case.ts        → casos de uso da camada de aplicação
  *.repository.ts      → repositórios (interface e implementação)
  *.controller.ts      → controladores HTTP
  *.schema.ts          → schemas Zod de validação
  *.service.ts         → domain services
  *.dto.ts             → Data Transfer Objects
  *.spec.ts            → testes unitários
  *.integration.spec.ts → testes de integração
  *.e2e.spec.ts        → testes end-to-end
```

### Variáveis e Funções

```typescript
// camelCase para variáveis e funções
const ordemServico = await buscarOrdemServico(id);
function calcularValorTotal(servicos: Servico[], pecas: Peca[]): number {}

// PascalCase para classes, interfaces e types
class OrdemServico {}
interface IOrdemServicoRepository {}
type StatusOS = 'ABERTA' | 'EM_EXECUCAO' | 'CONCLUIDA';

// SCREAMING_SNAKE_CASE para constantes e enums
const TEMPO_EXPIRACAO_JWT = '8h';
enum TipoMovimentacaoEstoque {
  ENTRADA = 'ENTRADA',
  SAIDA = 'SAIDA',
  AJUSTE = 'AJUSTE',
}
```

### Interfaces

```typescript
// Interfaces de repositório SEMPRE começam com I
interface IClienteRepository {
  salvar(cliente: Cliente): Promise<void>;
  buscarPorId(id: string): Promise<Cliente | null>;
  buscarPorCpf(cpf: string): Promise<Cliente | null>;
}

// DTOs NÃO usam prefixo I
interface CriarClienteDto {
  nome: string;
  cpf: string;
  telefone: string;
}
```

---

## 2. Organização de Código

### Ordem de importações

```typescript
// 1. Módulos nativos do Node.js
import { randomUUID } from 'crypto';

// 2. Dependências externas (node_modules)
import { z } from 'zod';
import type { FastifyRequest, FastifyReply } from 'fastify';

// 3. Imports internos — camadas de fora para dentro
import { OrdemServicoController } from '@/interfaces/http/controllers/ordem-servico.controller';
import { CriarOrdemServicoUseCase } from '@/application/use-cases/criar-ordem-servico.use-case';
import { OrdemServico } from '@/domain/entities/ordem-servico.entity';

// Separar grupos com linha em branco
```

### Estrutura de um Use Case

```typescript
// Padrão obrigatório para todos os use cases
export class CriarOrdemServicoUseCase {
  constructor(
    private readonly osRepository: IOrdemServicoRepository,    // sempre readonly
    private readonly clienteRepository: IClienteRepository,
  ) {}

  async execute(dto: CriarOrdemServicoDto): Promise<OrdemServicoDto> {
    // 1. Validação de regras de negócio
    const cliente = await this.clienteRepository.buscarPorId(dto.clienteId);
    if (!cliente) {
      throw new ClienteNaoEncontradoError(dto.clienteId);
    }

    // 2. Criação da entidade de domínio
    const os = OrdemServico.criar({
      clienteId: dto.clienteId,
      veiculoId: dto.veiculoId,
      descricaoProblema: dto.descricaoProblema,
    });

    // 3. Persistência
    await this.osRepository.salvar(os);

    // 4. Retorno do DTO (nunca retornar a entidade diretamente)
    return OrdemServicoMapper.toDto(os);
  }
}
```

### Estrutura de uma Entidade de Domínio

```typescript
export class OrdemServico {
  private constructor(
    public readonly id: string,
    public readonly clienteId: string,
    public readonly veiculoId: string,
    private _status: StatusOS,
    private _descricaoProblema: string,
    public readonly criadoEm: Date,
    private _atualizadoEm: Date,
  ) {}

  // Factory method — nunca usar `new` diretamente fora da entidade
  static criar(dados: CriarOsProps): OrdemServico {
    return new OrdemServico(
      randomUUID(),
      dados.clienteId,
      dados.veiculoId,
      'RASCUNHO',
      dados.descricaoProblema,
      new Date(),
      new Date(),
    );
  }

  // Comportamentos (métodos de negócio na entidade)
  abrir(): void {
    if (this._status !== 'RASCUNHO') {
      throw new TransicaoEstadoInvalidaError(this._status, 'ABERTA');
    }
    this._status = 'ABERTA';
    this._atualizadoEm = new Date();
  }

  // Getters para campos privados
  get status(): StatusOS { return this._status; }
}
```

---

## 3. Tratamento de Erros

```typescript
// Hierarquia de erros — sempre erros de domínio customizados
export class AppError extends Error {
  constructor(
    message: string,
    public readonly statusCode: number = 500,
    public readonly code: string = 'INTERNAL_ERROR',
  ) {
    super(message);
    this.name = this.constructor.name;
  }
}

export class NaoEncontradoError extends AppError {
  constructor(entidade: string, id: string) {
    super(`${entidade} com id '${id}' não encontrado`, 404, 'NOT_FOUND');
  }
}

export class TransicaoEstadoInvalidaError extends AppError {
  constructor(estadoAtual: string, estadoDesejado: string) {
    super(
      `Transição de '${estadoAtual}' para '${estadoDesejado}' não é permitida`,
      422,
      'INVALID_STATE_TRANSITION',
    );
  }
}

// NUNCA lançar Error genérico nas regras de negócio
// ❌ throw new Error('Cliente não encontrado')
// ✅ throw new NaoEncontradoError('Cliente', id)
```

---

## 4. Padrão de Commits (Conventional Commits)

```
<tipo>(<escopo>): <descrição curta no imperativo>

[corpo opcional — explica o "porquê", não o "o quê"]

[rodapé opcional — referências a issues]
```

### Tipos válidos

| Tipo | Uso |
|------|-----|
| `feat` | Nova funcionalidade |
| `fix` | Correção de bug |
| `docs` | Apenas documentação |
| `test` | Adiciona ou corrige testes |
| `refactor` | Refatoração sem mudança de comportamento |
| `chore` | Configurações, deps, build |
| `perf` | Melhoria de performance |

### Exemplos

```bash
feat(os): implementa máquina de estados da ordem de serviço
fix(estoque): corrige cálculo de saldo em movimentação de ajuste
docs(adr): adiciona ADR-004 sobre estratégia de cache com Redis
test(cliente): adiciona testes de integração para criação de cliente
chore(docker): adiciona serviço rabbitmq ao docker-compose
```

---

## 5. Testes

```typescript
// Estrutura padrão de teste unitário (AAA — Arrange, Act, Assert)
describe('CriarOrdemServicoUseCase', () => {
  let useCase: CriarOrdemServicoUseCase;
  let osRepository: jest.Mocked<IOrdemServicoRepository>;

  beforeEach(() => {
    // Arrange
    osRepository = {
      salvar: jest.fn(),
      buscarPorId: jest.fn(),
    };
    useCase = new CriarOrdemServicoUseCase(osRepository);
  });

  it('deve criar uma OS no estado RASCUNHO quando os dados são válidos', async () => {
    // Arrange
    const dto: CriarOrdemServicoDto = {
      clienteId: 'uuid-cliente',
      veiculoId: 'uuid-veiculo',
      descricaoProblema: 'Troca de óleo',
    };

    // Act
    const resultado = await useCase.execute(dto);

    // Assert
    expect(resultado.status).toBe('RASCUNHO');
    expect(osRepository.salvar).toHaveBeenCalledTimes(1);
  });
});
```

---

## 6. Logs Estruturados

```typescript
// Sempre usar o logger do Fastify — nunca console.log em produção
// Campos obrigatórios em logs de negócio:
logger.info({
  event: 'os.criada',          // identificador único do evento
  osId: os.id,                 // ID da entidade principal
  userId: request.user.id,     // quem realizou a ação
  correlationId: request.id,   // rastreamento da requisição
}, 'Ordem de serviço criada com sucesso');

// NUNCA logar dados sensíveis:
// ❌ logger.info({ senha, token, cpf })
// ✅ logger.info({ userId, email: email.replace(/(.{2}).*@/, '$1***@') })
```
