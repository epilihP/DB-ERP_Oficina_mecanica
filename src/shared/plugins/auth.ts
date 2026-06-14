import fastifyJwt from "@fastify/jwt";
import type { FastifyInstance, FastifyReply, FastifyRequest } from "fastify";
import fp from "fastify-plugin";
import { env } from "../../lib/env.js";
import { ForbiddenError } from "../errors/app-error.js";

export type Perfil = "GERENTE" | "FUNCIONARIO";

export interface TokenPayload {
  sub: string;
  nome: string;
  perfil: Perfil;
}

declare module "@fastify/jwt" {
  interface FastifyJWT {
    payload: TokenPayload;
    user: TokenPayload;
  }
}

declare module "fastify" {
  interface FastifyInstance {
    authenticate: (
      request: FastifyRequest,
      reply: FastifyReply
    ) => Promise<void>;
    authorize: (
      perfis: Perfil[]
    ) => (request: FastifyRequest, reply: FastifyReply) => Promise<void>;
  }
}

async function authPlugin(app: FastifyInstance) {
  await app.register(fastifyJwt, {
    secret: env.JWT_SECRET,
    sign: { expiresIn: env.JWT_EXPIRES_IN },
  });

  app.decorate(
    "authenticate",
    async (request: FastifyRequest, _reply: FastifyReply) => {
      await request.jwtVerify();
    }
  );

  app.decorate("authorize", (perfis: Perfil[]) => {
    return async (request: FastifyRequest, _reply: FastifyReply) => {
      await request.jwtVerify();
      if (!perfis.includes(request.user.perfil)) {
        throw new ForbiddenError(
          "Seu perfil não tem permissão para esta ação"
        );
      }
    };
  });
}

export default fp(authPlugin);
