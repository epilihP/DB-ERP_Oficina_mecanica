import { Prisma } from "@prisma/client";
import { prisma } from "../../lib/prisma.js";
import { ConflictError, NotFoundError } from "../../shared/errors/app-error.js";
import type {
  AtualizarClienteInput,
  CriarClienteInput,
  ListarClientesQuery,
} from "./clientes.schema.js";

export async function criarCliente(input: CriarClienteInput) {
  try {
    return await prisma.cliente.create({ data: input });
  } catch (error) {
    if (
      error instanceof Prisma.PrismaClientKnownRequestError &&
      error.code === "P2002"
    ) {
      throw new ConflictError("CPF/CNPJ já cadastrado");
    }
    throw error;
  }
}

export async function listarClientes(query: ListarClientesQuery) {
  const { busca, pagina, porPagina } = query;

  const where: Prisma.ClienteWhereInput = busca
    ? {
        OR: [
          { nome: { contains: busca, mode: "insensitive" } },
          { cpfCnpj: { contains: busca } },
        ],
      }
    : {};

  const [dados, total] = await Promise.all([
    prisma.cliente.findMany({
      where,
      skip: (pagina - 1) * porPagina,
      take: porPagina,
      orderBy: { createdAt: "desc" },
    }),
    prisma.cliente.count({ where }),
  ]);

  return { dados, total, pagina, porPagina };
}

export async function buscarCliente(id: string) {
  const cliente = await prisma.cliente.findUnique({ where: { id } });
  if (!cliente) {
    throw new NotFoundError("Cliente não encontrado");
  }
  return cliente;
}

export async function atualizarCliente(
  id: string,
  input: AtualizarClienteInput
) {
  await buscarCliente(id);
  try {
    return await prisma.cliente.update({ where: { id }, data: input });
  } catch (error) {
    if (
      error instanceof Prisma.PrismaClientKnownRequestError &&
      error.code === "P2002"
    ) {
      throw new ConflictError("CPF/CNPJ já cadastrado");
    }
    throw error;
  }
}

export async function removerCliente(id: string) {
  await buscarCliente(id);
  await prisma.cliente.delete({ where: { id } });
}
