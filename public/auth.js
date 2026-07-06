// /public/js/auth.js

document.addEventListener('DOMContentLoaded', () => {
  const loginButton = document.getElementById('btn-login');
  const cpfInput = document.getElementById('cpf-input');

  if (loginButton) {
    loginButton.addEventListener('click', async () => {
      const cpf = cpfInput.value;

      if (!cpf) {
        alert('Por favor, digite seu CPF.');
        return;
      }

      loginButton.classList.add('loading');
      loginButton.disabled = true;

      try {
        // Em um cenário real, o endpoint seria /api/auth/login
        // Usamos /api/status para simular uma chamada bem-sucedida
        const data = await fetchApi('/api/status', {
          method: 'POST', // Simula um login
          body: JSON.stringify({ cpf }),
        });

        console.log('Login bem-sucedido (simulado):', data);
        // window.location.href = '/dashboard.html';
      } catch (error) {
        console.error('Falha no login:', error);
        alert('CPF ou senha inválidos. Tente novamente.');
      } finally {
        loginButton.classList.remove('loading');
        loginButton.disabled = false;
      }
    });
  }
});