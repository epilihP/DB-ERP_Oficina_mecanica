import type { FastifyInstance } from "fastify";
import { loginSchema } from "./auth.schema.js";
import { validarCredenciais } from "./auth.service.js";

export async function authRoutes(app: FastifyInstance) {
  app.post("/login", async (request, reply) => {
    const credenciais = loginSchema.parse(request.body);
    const payload = await validarCredenciais(credenciais);

    const token = await reply.jwtSign(payload);

    return reply.status(200).send({
      token,
      usuario: {
        id: payload.sub,
        nome: payload.nome,
        perfil: payload.perfil,
      },
    });
  });
}
