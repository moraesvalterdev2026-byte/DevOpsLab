// /public/js/register.js

document.addEventListener('DOMContentLoaded', () => {
  const registerButton = document.getElementById('btn-register');
  const nameInput = document.getElementById('name-input');
  const cpfInput = document.getElementById('cpf-input');
  const passwordInput = document.getElementById('password-input');
  const confirmPasswordInput = document.getElementById('confirm-password-input');

  if (registerButton) {
    registerButton.addEventListener('click', async () => {
      const name = nameInput.value;
      const cpf = cpfInput.value;
      const password = passwordInput.value;
      const confirmPassword = confirmPasswordInput.value;

      if (password !== confirmPassword) {
        alert('As senhas não coincidem.');
        return;
      }

      if (!name || !cpf || !password) {
        alert('Por favor, preencha todos os campos.');
        return;
      }

      registerButton.classList.add('loading');
      registerButton.disabled = true;

      try {
        // Em um cenário real, o endpoint seria /api/auth/register
        const data = await fetchApi('/api/status', {
          method: 'POST',
          body: JSON.stringify({ name, cpf, password }),
        });

        console.log('Registro bem-sucedido (simulado):', data);
        alert('Conta criada com sucesso! Você será redirecionado para o login.');
        window.location.href = '/login.html';
      } catch (error) {
        console.error('Falha no registro:', error);
        alert('Não foi possível criar sua conta. Tente novamente.');
      } finally {
        registerButton.classList.remove('loading');
        registerButton.disabled = false;
      }
    });
  }
});