import { mountSidebar } from '../components/sidebar.js';
import { mountTransactions } from '../components/transactions.js';

document.addEventListener('DOMContentLoaded', async () => {
  mountSidebar('#sidebar');
  await mountTransactions('#statement-component');

  // Balance card
  const balanceEl = document.querySelector('#balance-component');
  if (balanceEl) {
    const body = document.createElement('div');
    body.className = 'card-body';
    body.innerHTML = '<p class="balance-value">Carregando saldo...</p>';
    balanceEl.innerHTML = '';
    balanceEl.appendChild(body);

    // try fetch
    try {
      let bal = null;
      if (window.AxesBank?.apiClient) {
        const res = await window.AxesBank.apiClient.get('/accounts/balance');
        bal = res?.balance ?? res;
      }
      if (bal == null) bal = 0.0;
      const fmt = (window.AxesBank?.utils?.formatCurrency) ? window.AxesBank.utils.formatCurrency(bal) : bal.toFixed(2);
      balanceEl.querySelector('.balance-value').textContent = fmt;
    } catch (err) {
      console.error('Error fetching balance', err);
      balanceEl.querySelector('.balance-value').textContent = '—';
    }
  }

  // User name
  const userNameEl = document.querySelector('#user-name');
  try {
    const user = window.AxesBank?.Storage?.get(window.AxesBank?.config?.auth?.userKey) || window.AxesBank?.Storage?.get('user');
    if (user && user.identifier) userNameEl.textContent = user.identifier;
  } catch (e) {
    // ignore
  }

  // Logout
  const btnLogout = document.querySelector('#btn-logout');
  if (btnLogout) btnLogout.addEventListener('click', () => {
    if (window.AxesBank?.apiClient?.clearToken) window.AxesBank.apiClient.clearToken();
    if (window.AxesBank?.Storage) window.AxesBank.Storage.remove(window.AxesBank?.config?.auth?.userKey || 'user');
    window.location.href = '/';
  });
});
