// src/db.js
import { Pool } from 'pg';
import dotenv from 'dotenv';

// Carrega as variáveis de ambiente. Em um ambiente de teste, o jest.setup.js
// já terá carregado o .env.test, então esta chamada não sobrescreverá as
// variáveis de teste. Em produção/desenvolvimento, carregará o .env padrão.
dotenv.config();

/**
 * Singleton instance of the PostgreSQL connection pool.
 * The connection details are read from environment variables.
 * This module ensures that the pool is created only once.
 */
const pool = new Pool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
});

export default pool;