import bcrypt from "bcryptjs";
import { prisma } from "../../lib/prisma.js";
import { UnauthorizedError } from "../../shared/errors/app-error.js";
import type { TokenPayload } from "../../shared/plugins/auth.js";
import type { LoginInput } from "./auth.schema.js";

export async function validarCredenciais(
  input: LoginInput
): Promise<TokenPayload> {
  const usuario = await prisma.usuario.findUnique({
    where: { email: input.email },
  });

  const mensagemGenerica = "Email ou senha inválidos";

  if (!usuario) {
    throw new UnauthorizedError(mensagemGenerica);
  }

  const senhaValida = await bcrypt.compare(input.senha, usuario.senhaHash);
  if (!senhaValida) {
    throw new UnauthorizedError(mensagemGenerica);
  }

  return {
    sub: usuario.id,
    nome: usuario.nome,
    perfil: usuario.perfil,
  };
}
