// src/api.test.js

const request = require('supertest');
const { Pool } = require('pg');
const app = require('./app'); // Importa a definição do app, não o servidor em execução.

// Configuração do pool de conexão para o banco de dados de teste
// As variáveis de ambiente são injetadas pelo workflow do GitHub Actions
const pool = new Pool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
});

describe('API Integration Tests', () => {

  // Garante que a conexão com o banco seja encerrada após todos os testes
  afterAll(async () => {
    await pool.end();
  });

  // Teste 1: Validação da Conexão com o Banco de Dados
  test('should connect to the test database successfully', async () => {
    const client = await pool.connect();
    expect(client).toBeDefined();
    const res = await client.query('SELECT NOW()');
    expect(res.rows.length).toBeGreaterThan(0);
    client.release();
  });

  // Teste 2: Validação de um Endpoint de Status/Saúde
  // (Assumindo que você tenha um endpoint GET /api/status)
  test('GET /api/status should return 200 OK', async () => {
    const response = await request(app).get('/api/status');
    expect(response.statusCode).toBe(200);
    expect(response.body).toEqual({ status: 'API is running and connected to database' });
  });

  // Teste 3: Placeholder para Teste de Autenticação
  test.skip('POST /api/auth/login should authenticate a user', () => {
    // TODO: Implementar teste de login.
    // 1. Inserir um usuário de teste no banco.
    // 2. Fazer uma requisição POST para /api/auth/login com as credenciais.
    // 3. Verificar se a resposta contém um token JWT e status 200.
  });
});