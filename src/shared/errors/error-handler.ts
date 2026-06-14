import type { FastifyError, FastifyReply, FastifyRequest } from "fastify";
import { ZodError } from "zod";
import { AppError } from "./app-error.js";

export function errorHandler(
  error: FastifyError,
  _request: FastifyRequest,
  reply: FastifyReply
) {
  if (error instanceof ZodError) {
    return reply.status(422).send({
      error: "Erro de validação",
      issues: error.flatten().fieldErrors,
    });
  }

  if (error instanceof AppError) {
    return reply.status(error.statusCode).send({ error: error.message });
  }

  if (error.statusCode === 401) {
    return reply.status(401).send({ error: "Token inválido ou ausente" });
  }

  _request.log.error(error);
  return reply.status(500).send({ error: "Erro interno do servidor" });
}
