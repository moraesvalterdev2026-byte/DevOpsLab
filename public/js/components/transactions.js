import * as utils from '../utils/index.js';

/**
 * Mounts a transactions list into a container.
 * Attempts to fetch from API; falls back to local demo data.
 */
export async function mountTransactions(containerSelector = '#statement-component') {
  const container = document.querySelector(containerSelector);
  if (!container) return null;

  const listId = 'transactions-list';
  container.innerHTML = `
    <div class="card-body">
      <div class="form-group">
        <button id="btn-refresh-transactions" class="btn btn-ghost">Atualizar</button>
      </div>
      <ul id="${listId}" class="transactions-list"></ul>
      <p class="form-error" id="transactionsError" aria-live="polite"></p>
    </div>
  `;

  const listEl = container.querySelector(`#${listId}`);
  const errEl = container.querySelector('#transactionsError');
  const refreshBtn = container.querySelector('#btn-refresh-transactions');

  async function load() {
    errEl.textContent = '';
    listEl.innerHTML = '<li class="text-muted">Carregando...</li>';

    try {
      let tx = null;
      if (window.AxesBank?.apiClient) {
        const res = await window.AxesBank.apiClient.get('/accounts/transactions');
        tx = res?.transactions || res || null;
      }

      if (!tx) {
        // fallback demo data
        tx = [
          { id: 't1', date: new Date().toISOString(), description: 'Pagamento - Mercado', amount: -45.9 },
          { id: 't2', date: new Date().toISOString(), description: 'Depósito', amount: 1200.0 },
          { id: 't3', date: new Date().toISOString(), description: 'Transferência recebida', amount: 250.5 },
        ];
      }

      // render
      listEl.innerHTML = '';
      tx.slice(0, 10).forEach((t) => {
        const li = document.createElement('li');
        li.className = 'transaction-item';
        const date = new Date(t.date).toLocaleDateString();
        const amt = (window.AxesBank?.utils?.formatCurrency) ? window.AxesBank.utils.formatCurrency(t.amount) : (t.amount).toFixed(2);
        li.innerHTML = `<div class="tx-row"><div class="tx-desc">${t.description}</div><div class="tx-meta"><span class="tx-date">${date}</span> <span class="tx-amount">${amt}</span></div></div>`;
        listEl.appendChild(li);
      });
    } catch (err) {
      console.error('Error loading transactions', err);
      errEl.textContent = 'Não foi possível carregar transações.';
      listEl.innerHTML = '';
    }
  }

  refreshBtn.addEventListener('click', load);
  await load();
  return container;
}
