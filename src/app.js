// src/app.js
import express from 'express';
import dotenv from 'dotenv';
import path from 'path';
import { fileURLToPath } from 'url';
import pool from './db.js'; // Importa o pool de conexão
import bcrypt from 'bcrypt'; // Importa o bcrypt para hashing de senha
import jwt from 'jsonwebtoken'; // Importa a biblioteca para JWT
import authenticateToken from './middleware/auth.js'; // Importa o middleware de autenticação

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

// --- Rotas de Autenticação ---

// Rota de Registro de Usuário
app.post('/api/auth/register', async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ error: 'Email e senha são obrigatórios.' });
  }

  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    const saltRounds = 10;
    const passwordHash = await bcrypt.hash(password, saltRounds);

    const newUserResult = await client.query(
      "INSERT INTO users (email, password_hash) VALUES ($1, $2) RETURNING id, email, created_at",
      [email, passwordHash]
    );

    const newUser = newUserResult.rows[0];

    // Cria uma conta corrente padrão para o novo usuário
    await client.query(
      "INSERT INTO accounts (user_id, balance) VALUES ($1, $2)",
      [newUser.id, 0.00]
    );

    await client.query('COMMIT');
    res.status(201).json(newUser);
  } catch (error) {
    await client.query('ROLLBACK');
    console.error('Erro ao registrar usuário:', error);
    // Adiciona uma verificação para erro de duplicidade
    if (error.code === '23505') { // Código de erro do PostgreSQL para violação de unicidade
      return res.status(409).json({ error: 'Este email já está em uso.' });
    }
    res.status(500).json({ error: 'Erro interno do servidor.' });
  } finally {
    client.release();
  }
});

// Rota de Login de Usuário
app.post('/api/auth/login', async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ error: 'Email e senha são obrigatórios.' });
  }

  try {
    const userResult = await pool.query("SELECT * FROM users WHERE email = $1", [email]);

    if (userResult.rows.length === 0) {
      return res.status(401).json({ error: 'Credenciais inválidas.' }); // Usuário não encontrado
    }

    const user = userResult.rows[0];
    const isPasswordValid = await bcrypt.compare(password, user.password_hash);

    if (!isPasswordValid) {
      return res.status(401).json({ error: 'Credenciais inválidas.' }); // Senha incorreta
    }

    // Gera o token JWT
    const token = jwt.sign(
      { userId: user.id, email: user.email },
      process.env.JWT_SECRET,
      { expiresIn: '1h' } // Token expira em 1 hora
    );

    res.status(200).json({ message: 'Login bem-sucedido!', token });
  } catch (error) {
    console.error('Erro no login:', error);
    res.status(500).json({ error: 'Erro interno do servidor.' });
  }
});

// --- Rotas Protegidas ---

// Rota de Perfil do Usuário (protegida por autenticação)
app.get('/api/profile', authenticateToken, (req, res) => {
  res.json({ user: req.user });
});

// Rota para listar as contas do usuário autenticado
app.get('/api/accounts', authenticateToken, async (req, res) => {
  try {
    const { userId } = req.user; // Obtém o ID do usuário a partir do token

    const accountsResult = await pool.query(
      "SELECT * FROM accounts WHERE user_id = $1 ORDER BY created_at ASC",
      [userId]
    );

    res.status(200).json(accountsResult.rows);
  } catch (error) {
    console.error('Erro ao buscar contas:', error);
    res.status(500).json({ error: 'Erro interno do servidor.' });
  }
});

// Rota para realizar uma transação entre contas
app.post('/api/transactions', authenticateToken, async (req, res) => {
  const { from_account_id, to_account_id, amount } = req.body;
  const { userId } = req.user;

  // Validação básica de entrada
  if (!from_account_id || !to_account_id || !amount || amount <= 0) {
    return res.status(400).json({ error: 'Dados da transação inválidos. O valor deve ser positivo.' });
  }

  if (from_account_id === to_account_id) {
    return res.status(400).json({ error: 'A conta de origem e destino não podem ser a mesma.' });
  }

  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    // 1. Verificar se o usuário é dono da conta de origem e se tem saldo
    const fromAccountResult = await client.query(
      "SELECT * FROM accounts WHERE id = $1 AND user_id = $2 FOR UPDATE",
      [from_account_id, userId]
    );

    if (fromAccountResult.rows.length === 0) {
      await client.query('ROLLBACK');
      return res.status(403).json({ error: 'Operação não permitida: você não é o dono da conta de origem.' });
    }

    const fromAccount = fromAccountResult.rows[0];
    if (parseFloat(fromAccount.balance) < amount) {
      await client.query('ROLLBACK');
      return res.status(400).json({ error: 'Saldo insuficiente.' });
    }

    // 2. Debitar da conta de origem
    await client.query(
      "UPDATE accounts SET balance = balance - $1 WHERE id = $2",
      [amount, from_account_id]
    );

    // 3. Creditar na conta de destino
    await client.query(
      "UPDATE accounts SET balance = balance + $1 WHERE id = $2",
      [amount, to_account_id]
    );

    // 4. Registrar a transação na tabela 'transactions'
    await client.query(
      "INSERT INTO transactions (from_account_id, to_account_id, amount, description) VALUES ($1, $2, $3, $4)",
      [from_account_id, to_account_id, amount, 'Transferência entre contas']
    );

    await client.query('COMMIT');
    res.status(200).json({ message: 'Transação realizada com sucesso.' });
  } catch (error) {
    await client.query('ROLLBACK');
    console.error('Erro ao realizar transação:', error);
    res.status(500).json({ error: 'Erro interno do servidor ao processar a transação.' });
  } finally {
    client.release();
  }
});

// Rota para listar o histórico de transações do usuário
app.get('/api/transactions', authenticateToken, async (req, res) => {
  const { userId } = req.user;
  try {
    const result = await pool.query(
      `SELECT t.*
       FROM transactions t
       JOIN accounts a ON t.from_account_id = a.id OR t.to_account_id = a.id
       WHERE a.user_id = $1
       ORDER BY t.created_at DESC`,
      [userId]
    );
    // Para evitar duplicatas se o usuário for dono de ambas as contas
    const uniqueTransactions = [...new Map(result.rows.map(item => [item['id'], item])).values()];
    res.status(200).json(uniqueTransactions);
  } catch (error) {
    console.error('Erro ao buscar histórico de transações:', error);
    res.status(500).json({ error: 'Erro interno do servidor.' });
  }
});

export default app;