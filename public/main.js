import { fetchApi } from './api.js';

document.getElementById('loginForm').addEventListener('submit', async (e) => {
  e.preventDefault();

  const email = document.getElementById('email').value;
  const password = document.getElementById('password').value;
  const messageDiv = document.getElementById('message');

  if (!email || !password) {
    messageDiv.textContent = 'Por favor, preencha todos os campos.';
    messageDiv.style.color = 'red';
    return;
  }

  try {
    const data = await fetchApi('auth/login', {
      method: 'POST',
      body: JSON.stringify({ email, password }),
    });

    if (data.token) {
      localStorage.setItem('authToken', data.token);
      messageDiv.textContent = 'Login bem-sucedido! Redirecionando...';
      messageDiv.style.color = 'green';
      window.location.href = '/dashboard.html'; // Redireciona para o painel do usuário
    } else {
      throw new Error(data.error || 'Falha no login.');
    }
  } catch (error) {
    messageDiv.textContent = error.message;
    messageDiv.style.color = 'red';
  }
});