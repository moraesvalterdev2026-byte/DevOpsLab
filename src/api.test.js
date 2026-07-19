// src/api.test.js

import request from 'supertest';
import app from './app.js'; // Importa a definição do app, não o servidor em execução.
import pool from './db.js'; // Importa o pool de conexão centralizado.

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
  test.todo('POST /api/auth/login should authenticate a user');
});