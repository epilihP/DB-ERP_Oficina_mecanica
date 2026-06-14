import { PrismaClient, PerfilUsuario } from "@prisma/client";
import bcrypt from "bcryptjs";

const prisma = new PrismaClient();

async function main() {
  const email = "gerente@oficina.com";
  const senhaHash = await bcrypt.hash("123456", 10);

  await prisma.usuario.upsert({
    where: { email },
    update: {},
    create: {
      nome: "Gerente Padrão",
      email,
      senhaHash,
      perfil: PerfilUsuario.GERENTE,
    },
  });

  console.log(`Usuário gerente criado: ${email} / senha: 123456`);
}

main()
  .catch((error) => {
    console.error(error);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
