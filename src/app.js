// src/app.js
const express = require('express');
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

module.exports = app;