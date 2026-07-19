// src/app.js
import express from 'express';
import dotenv from 'dotenv';

// Carrega as variáveis de ambiente do arquivo .env na raiz do projeto.
dotenv.config();
const app = express();

app.use(express.json());

// Endpoint de status para o healthcheck e testes
app.get('/api/status', (req, res) => {
  // No futuro, podemos adicionar uma verificação de conexão com o banco aqui.
  res.status(200).json({ status: 'API is running and connected to database' });
});

// Outras rotas da sua API virão aqui...
// app.use('/api/auth', authRoutes);
// app.use('/api/transactions', transactionRoutes);

export default app;