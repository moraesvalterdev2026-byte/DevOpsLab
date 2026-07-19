import { Storage, logger } from '../core/index.js';

/**
 * Mounts a login form handler to a form element.
 * - Validates input
 * - Calls API client if available
 * - Stores user on success and redirects to /dashboard.html
 */
export function mountLoginForm(formSelector = '#loginForm') {
  const form = document.querySelector(formSelector);
  if (!form) return null;

  const identifier = form.querySelector('#identifier') || form.querySelector('#email') || form.querySelector('#cpf-input');
  const password = form.querySelector('#password');
  const btn = form.querySelector('#btnLogin');

  function setError(el, msg) {
    const err = form.querySelector(`#${el.id}Error`) || form.querySelector('.form-error');
    if (err) err.textContent = msg;
    if (el) el.classList.add('input-error');
  }
  function clearError(el) {
    const err = form.querySelector(`#${el.id}Error`);
    if (err) err.textContent = '';
    if (el) el.classList.remove('input-error');
  }

  form.addEventListener('submit', async (e) => {
    e.preventDefault();
    clearError(identifier);
    clearError(password);

    const idVal = identifier?.value?.trim?.() || '';
    const pwd = password?.value || '';

    if (!idVal) { setError(identifier, 'Informe CPF ou e-mail'); identifier?.focus?.(); return; }
    if (!pwd || pwd.length < 4) { setError(password, 'Senha inválida'); password?.focus?.(); return; }

    if (btn) { btn.disabled = true; const origText = btn.textContent; btn.textContent = 'Acessando...';
      try {
        if (window.AxesBank?.apiClient) {
          const payload = { identifier: idVal, password: pwd };
          const res = await window.AxesBank.apiClient.post('/auth/login', payload);
          if (res && res.token) {
            window.AxesBank.apiClient.setToken(res.token);
            Storage.set(window.AxesBank.config.auth.userKey, res.user || { identifier: idVal });
            window.AxesBank.app.showSuccessToast('Login efetuado com sucesso');
            window.location.href = '/dashboard.html';
            return;
          }
          throw new Error(res?.message || 'Credenciais inválidas');
        } else {
          // Fallback local flow
          Storage.set('user', { identifier: idVal });
          window.AxesBank.app.showSuccessToast('Login simulado (fallback)');
          window.location.href = '/dashboard.html';
        }
      } catch (err) {
        logger.error('Login failed', err);
        window.AxesBank.app.showErrorToast(err.message || 'Falha ao autenticar');
        setError(password, 'Credenciais inválidas');
      } finally {
        btn.disabled = false; btn.textContent = origText;
      }
    }
  });

  return form;
}
