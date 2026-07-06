// /public/js/auth.js

document.addEventListener('DOMContentLoaded', () => {
    const loginButton = document.getElementById('btn-login');

    if (loginButton) {
        loginButton.addEventListener('click', () => {
            // Ativa o estado de loading
            loginButton.classList.add('loading');
            loginButton.disabled = true;

            // Simula uma chamada de API de 3 segundos
            setTimeout(() => {
                // Reverte para o estado normal após a "chamada"
                loginButton.classList.remove('loading');
                loginButton.disabled = false;
                // Aqui viria a lógica de sucesso ou falha (ex: redirecionar ou mostrar erro)
            }, 3000);
        });
    }
});