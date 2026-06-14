# Use Cases — Módulo Operacional

**Versão:** 1.0.0  
**Última atualização:** 2026-05-30  
**Escopo:** Sprint 1–6

---

## Convenções

- **Ator Principal:** quem inicia o caso de uso
- **Pré-condições:** o que deve ser verdade antes do caso de uso iniciar
- **Fluxo Principal:** caminho feliz (happy path)
- **Fluxos Alternativos:** variações do fluxo principal
- **Fluxos de Exceção:** erros e situações inválidas
- **Pós-condições:** o que é verdade após a execução bem-sucedida

---

## UC-001 — Autenticar Usuário

**Ator Principal:** Qualquer usuário do sistema  
**Módulo:** Autenticação

### Pré-condições
- Usuário possui cadastro ativo no sistema

### Fluxo Principal
1. Usuário informa email e senha
2. Sistema valida formato dos dados (Zod)
3. Sistema busca usuário pelo email
4. Sistema compara hash da senha informada com hash armazenado (bcrypt)
5. Sistema gera JWT (8h) e refresh token (7 dias)
6. Sistema retorna tokens ao cliente

### Fluxos de Exceção
- **FE-001:** Email não encontrado → HTTP 401 com mensagem genérica (não revelar se email existe)
- **FE-002:** Senha incorreta → HTTP 401 com mensagem genérica
- **FE-003:** Usuário inativo → HTTP 403 "Conta desativada"
- **FE-004:** Rate limit excedido (5 tentativas/min) → HTTP 429

### Pós-condições
- JWT válido emitido para o usuário
- Refresh token armazenado no Redis com TTL de 7 dias

---

## UC-002 — Criar Cliente

**Ator Principal:** Recepcionista, Administrador  
**Módulo:** Operacional

### Pré-condições
- Usuário autenticado com perfil RECEPCIONISTA ou ADMIN

### Fluxo Principal
1. Usuário informa dados do cliente (nome, tipo PF/PJ, CPF/CNPJ, telefone, email)
2. Sistema valida formato dos dados (Zod)
3. Sistema valida CPF ou CNPJ (algoritmo de validação)
4. Sistema verifica se CPF/CNPJ já existe no banco
5. Sistema cria o registro com UUID gerado localmente
6. Sistema retorna o cliente criado com código HTTP 201

### Fluxos Alternativos
- **FA-001:** Cliente pessoa jurídica → campos nome fantasia e IE se tornam opcionais

### Fluxos de Exceção
- **FE-001:** CPF/CNPJ inválido → HTTP 422 "CPF/CNPJ inválido"
- **FE-002:** CPF/CNPJ já cadastrado → HTTP 409 "CPF/CNPJ já cadastrado"
- **FE-003:** Email duplicado → HTTP 409 "Email já cadastrado"

### Pós-condições
- Cliente criado com status ATIVO
- Evento `cliente.criado` registrado na fila de auditoria

---

## UC-003 — Cadastrar Veículo

**Ator Principal:** Recepcionista, Administrador  
**Módulo:** Operacional

### Pré-condições
- Usuário autenticado
- Cliente existe e está ativo no sistema

### Fluxo Principal
1. Usuário informa dados do veículo (clienteId, placa, marca, modelo, ano, cor)
2. Sistema valida formato da placa (padrão brasileiro: AAA-0000 ou AAA-0A00 Mercosul)
3. Sistema verifica se a placa já está cadastrada
4. Sistema cria veículo vinculado ao cliente
5. Sistema retorna veículo criado com HTTP 201

### Fluxos Alternativos
- **FA-001:** Quando online, sistema pode consultar API de dados do veículo pela placa e sugerir preenchimento automático de marca, modelo e ano

### Fluxos de Exceção
- **FE-001:** Cliente não encontrado → HTTP 404
- **FE-002:** Placa em formato inválido → HTTP 422
- **FE-003:** Placa já cadastrada → HTTP 409

### Pós-condições
- Veículo criado e vinculado ao cliente

---

## UC-004 — Abrir Ordem de Serviço

**Ator Principal:** Recepcionista  
**Módulo:** Operacional

### Pré-condições
- Usuário autenticado com perfil RECEPCIONISTA ou ADMIN
- Cliente existe e está ativo
- Veículo existe e está vinculado ao cliente

### Fluxo Principal
1. Recepcionista informa clienteId, veiculoId e descrição do problema
2. Sistema valida os dados
3. Sistema verifica existência do cliente e veículo
4. Sistema cria OS no estado **RASCUNHO** com UUID gerado localmente
5. Sistema gera código legível sequencial (ex: `OS-2026-0042`)
6. Sistema registra data/hora de entrada do veículo (UTC)
7. Sistema transiciona para estado **ABERTA** automaticamente
8. Sistema retorna a OS criada com HTTP 201

### Fluxos de Exceção
- **FE-001:** Cliente inativo → HTTP 422 "Cliente inativo"
- **FE-002:** Veículo não pertence ao cliente → HTTP 422

### Pós-condições
- OS criada com estado ABERTA
- Evento `os.aberta` registrado para auditoria
- Histórico de transição de estado registrado

---

## UC-005 — Transicionar Estado da OS

**Ator Principal:** Varia por transição (ver tabela)  
**Módulo:** Operacional

### Transições Permitidas

| De | Para | Ator Autorizado | Observação |
|----|------|----------------|------------|
| RASCUNHO | ABERTA | Recepcionista | Automático na criação |
| ABERTA | EM_EXECUCAO | Mecânico | Início do trabalho |
| EM_EXECUCAO | AGUARDANDO_PECA | Mecânico | Peça em falta |
| AGUARDANDO_PECA | EM_EXECUCAO | Mecânico | Peça disponível |
| EM_EXECUCAO | CONCLUIDA | Mecânico | Trabalho finalizado |
| CONCLUIDA | FATURADA | Recepcionista/Financeiro | Após pagamento |
| ABERTA | CANCELADA | Recepcionista/Admin | Com motivo obrigatório |
| EM_EXECUCAO | CANCELADA | Admin | Com motivo obrigatório |

### Fluxo Principal
1. Usuário solicita transição de estado
2. Sistema valida se a transição é permitida para o estado atual
3. Sistema valida se o usuário tem permissão para essa transição
4. Sistema registra a transição com: usuário, timestamp UTC, observação
5. Sistema atualiza o estado da OS
6. Sistema emite evento para processamento assíncrono (notificações, etc.)

### Fluxos de Exceção
- **FE-001:** Transição inválida para o estado atual → HTTP 422 "Transição de 'X' para 'Y' não permitida"
- **FE-002:** Usuário sem permissão para essa transição → HTTP 403
- **FE-003:** Cancelamento sem motivo → HTTP 422 "Motivo do cancelamento é obrigatório"

### Pós-condições
- Estado da OS atualizado
- Transição registrada no histórico com imutabilidade (nunca apagada)

---

## UC-006 — Adicionar Serviço à OS

**Ator Principal:** Mecânico, Recepcionista  
**Módulo:** Operacional

### Pré-condições
- OS existe e está em estado ABERTA ou EM_EXECUCAO

### Fluxo Principal
1. Usuário informa osId, descrição do serviço e valor
2. Sistema valida estado da OS
3. Sistema adiciona o serviço à OS
4. Sistema recalcula valor total da OS
5. Sistema retorna OS atualizada

### Fluxos de Exceção
- **FE-001:** OS em estado que não permite edição → HTTP 422

### Pós-condições
- Serviço vinculado à OS
- Valor total da OS atualizado

---

## UC-007 — Adicionar Peça à OS

**Ator Principal:** Mecânico, Almoxarife  
**Módulo:** Operacional / Estoque

### Pré-condições
- OS existe e está em estado ABERTA, EM_EXECUCAO ou AGUARDANDO_PECA
- Peça existe no cadastro de estoque

### Fluxo Principal
1. Usuário informa osId, pecaId e quantidade
2. Sistema valida estado da OS
3. Sistema verifica disponibilidade em estoque
4. Sistema reserva a quantidade no estoque
5. Sistema vincula peça à OS com quantidade e valor unitário atual
6. Sistema recalcula valor total da OS

### Fluxos de Exceção
- **FE-001:** Estoque insuficiente → HTTP 422 "Estoque insuficiente. Disponível: X, solicitado: Y"
- **FE-002:** Peça não encontrada → HTTP 404

### Pós-condições
- Peça reservada no estoque (não deduzida — dedução ocorre na conclusão da OS)
- Peça vinculada à OS

---

## UC-008 — Concluir Ordem de Serviço

**Ator Principal:** Mecânico  
**Módulo:** Operacional

### Pré-condições
- OS está em estado EM_EXECUCAO
- OS tem pelo menos um serviço registrado

### Fluxo Principal
1. Mecânico solicita conclusão da OS
2. Sistema valida pré-condições
3. Sistema transiciona OS para CONCLUIDA
4. Sistema **efetiva** a saída das peças do estoque (converte reserva em saída real)
5. Sistema calcula valor final (serviços + peças)
6. Sistema registra data/hora de conclusão
7. Sistema emite evento `os.concluida` para módulo financeiro gerar cobrança

### Fluxos de Exceção
- **FE-001:** OS sem serviços registrados → HTTP 422 "Adicione pelo menos um serviço antes de concluir"

### Pós-condições
- OS com estado CONCLUIDA
- Estoque de peças deduzido efetivamente
- Evento disparado para geração de cobrança no módulo financeiro
