// setup.js
import dotenv from "dotenv";
import path from "path";

// Carrega as variáveis de ambiente do arquivo .env.test
// Isso garante que a configuração do banco de dados de teste esteja disponível para os testes.
dotenv.config({ path: path.resolve(process.cwd(), ".env.test") });