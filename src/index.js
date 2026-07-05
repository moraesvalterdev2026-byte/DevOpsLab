const express = require('express');
const path = require('path');
const { Pool } = require('pg');

const app = express();
const port = process.env.PORT || 3000;

// Configuração da Conexão com o Banco de Dados
const pool = new Pool({
  user: process.env.POSTGRES_USER,
  host: 'db', // Nome do serviço no docker-compose.yml
  database: process.env.POSTGRES_DB,
  password: process.env.POSTGRES_PASSWORD,
  port: 5432,
});

// Middlewares
app.use(express.json()); // Habilita o parsing de JSON no corpo das requisições
// Serve todos os arquivos estáticos a partir da pasta 'public'
app.use(express.static(path.join(__dirname, '..', 'public')));

// Endpoint de Health Check (Status do Sistema)
app.get('/api/status', async (req, res) => {
  try {
    const dbResult = await pool.query('SELECT NOW()');
    res.json({ api: 'online', db: 'online', dbTime: dbResult.rows[0].now });
  } catch (error) {
    res.status(503).json({ api: 'online', db: 'offline', error: error.message });
  }
});

app.listen(port, () => {
  console.log('Servidor rodando em http://localhost:' + port);
});