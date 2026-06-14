import Fastify from "fastify";
import { errorHandler } from "./shared/errors/error-handler.js";
import authPlugin from "./shared/plugins/auth.js";
import { healthRoutes } from "./modules/health/health.routes.js";
import { authRoutes } from "./modules/auth/auth.routes.js";
import { clientesRoutes } from "./modules/clientes/clientes.routes.js";
import { pecasRoutes } from "./modules/pecas/pecas.routes.js";

export async function buildApp() {
  const app = Fastify({
    logger: {
      transport:
        process.env.NODE_ENV === "development"
          ? { target: "pino-pretty" }
          : undefined,
    },
  });

  app.setErrorHandler(errorHandler);

  await app.register(authPlugin);

  await app.register(healthRoutes);
  await app.register(authRoutes, { prefix: "/auth" });
  await app.register(clientesRoutes, { prefix: "/clientes" });
  await app.register(pecasRoutes, { prefix: "/pecas" });

  return app;
}
