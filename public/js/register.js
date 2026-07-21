import { fetchApi } from './api.js';

document.getElementById('registerForm').addEventListener('submit', async (e) => {
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
    const data = await fetchApi('auth/register', {
      method: 'POST',
      body: JSON.stringify({ email, password }),
    });

    if (data.id) {
      messageDiv.textContent = 'Conta criada com sucesso! Redirecionando para o login...';
      messageDiv.style.color = 'green';
      setTimeout(() => { window.location.href = '/login.html'; }, 2000);
    } else {
      throw new Error(data.error || 'Falha ao criar conta.');
    }
  } catch (error) {
    messageDiv.textContent = error.message;
    messageDiv.style.color = 'red';
  }
});