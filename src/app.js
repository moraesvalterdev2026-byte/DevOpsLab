// src/app.js
import express from 'express';
import dotenv from 'dotenv';
import path from 'path';
import { fileURLToPath } from 'url';

// Carrega as variáveis de ambiente do arquivo .env na raiz do projeto.
dotenv.config();
const app = express();

app.use(express.json());

// Constrói o caminho absoluto para o diretório 'public'
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Habilita o Express para servir arquivos estáticos do diretório 'public'
app.use(express.static(path.join(__dirname, '../public')));

// Endpoint de status para o healthcheck e testes
app.get('/api/status', (req, res) => {
  // No futuro, podemos adicionar uma verificação de conexão com o banco aqui.
  res.status(200).json({ status: 'API is running and connected to database' });
});

// Outras rotas da sua API virão aqui...
// app.use('/api/auth', authRoutes);
// app.use('/api/transactions', transactionRoutes);

export default app;