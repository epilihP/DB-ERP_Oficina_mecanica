import type { FastifyInstance } from "fastify";
import { prisma } from "../../lib/prisma.js";

export async function healthRoutes(app: FastifyInstance) {
  app.get("/health", async (_request, reply) => {
    const start = Date.now();
    try {
      await prisma.$queryRaw`SELECT 1`;
      return reply.status(200).send({
        status: "healthy",
        timestamp: new Date().toISOString(),
        database: {
          status: "healthy",
          latencyMs: Date.now() - start,
        },
      });
    } catch {
      return reply.status(503).send({
        status: "unhealthy",
        timestamp: new Date().toISOString(),
        database: { status: "unhealthy" },
      });
    }
  });
}
