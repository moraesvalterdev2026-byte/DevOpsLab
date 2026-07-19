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
      <div class="form-group tx-controls">
        <label for="tx-filter-days" class="label">Período</label>
        <select id="tx-filter-days" class="input">
          <option value="7">Últimos 7 dias</option>
          <option value="30" selected>Últimos 30 dias</option>
          <option value="90">Últimos 90 dias</option>
        </select>
        <button id="btn-refresh-transactions" class="btn btn-ghost">Atualizar</button>
      </div>
      <ul id="${listId}" class="transactions-list" aria-live="polite"></ul>
      <p class="form-error" id="transactionsError" aria-live="polite"></p>
    </div>
  `;

  const listEl = container.querySelector(`#${listId}`);
  const errEl = container.querySelector('#transactionsError');
  const refreshBtn = container.querySelector('#btn-refresh-transactions');
  const filterEl = container.querySelector('#tx-filter-days');

  let txData = [];

  function renderList(items) {
    listEl.innerHTML = '';
    if (!items || items.length === 0) {
      listEl.innerHTML = '<li class="text-muted">Nenhuma transação encontrada.</li>';
      return;
    }
    items.slice(0, 50).forEach((t) => {
      const li = document.createElement('li');
      li.className = 'transaction-item';
      const date = new Date(t.date).toLocaleDateString();
      const amt = (window.AxesBank?.utils?.formatCurrency) ? window.AxesBank.utils.formatCurrency(t.amount) : Number(t.amount).toFixed(2);
      const amtClass = t.amount >= 0 ? 'tx-amount positive' : 'tx-amount negative';
      // use details for expand
      li.innerHTML = `
        <details class="transaction-details">
          <summary class="tx-row">
            <div class="tx-desc">${t.description}</div>
            <div class="tx-meta"><span class="tx-date">${date}</span> <span class="${amtClass}">${amt}</span></div>
          </summary>
          <div class="tx-detail">
            <p class="text-sm">ID: ${t.id}</p>
            <p class="text-sm">Data/Hora: ${new Date(t.date).toLocaleString()}</p>
            <p class="text-sm">Descrição completa: ${t.description}</p>
            <p class="text-sm">Valor: ${amt}</p>
          </div>
        </details>
      `;
      listEl.appendChild(li);
    });
  }

  function applyFilterAndRender() {
    const days = parseInt(filterEl.value, 10) || 30;
    const cutoff = Date.now() - days * 24 * 60 * 60 * 1000;
    const filtered = txData.filter((t) => new Date(t.date).getTime() >= cutoff);
    renderList(filtered);
  }

  async function load(showLoading = true) {
    errEl.textContent = '';
    if (showLoading) listEl.innerHTML = '<li class="text-muted">Carregando...</li>';
    refreshBtn.disabled = true;
    const prev = txData.slice();
    try {
      let tx = null;
      if (window.AxesBank?.apiClient) {
        const res = await window.AxesBank.apiClient.get('/accounts/transactions');
        tx = res?.transactions || res || null;
      }
      if (!tx) {
        tx = [
          { id: 't1', date: new Date().toISOString(), description: 'Pagamento - Mercado', amount: -45.9 },
          { id: 't2', date: new Date().toISOString(), description: 'Depósito', amount: 1200.0 },
          { id: 't3', date: new Date().toISOString(), description: 'Transferência recebida', amount: 250.5 },
        ];
      }
      txData = Array.isArray(tx) ? tx.slice() : [];
      applyFilterAndRender();
    } catch (err) {
      console.error('Error loading transactions', err);
      errEl.textContent = 'Não foi possível carregar transações.';
      // restore previous list if any
      txData = prev;
      renderList(txData);
      // dispatch global api error
      document.dispatchEvent(new CustomEvent('api:error', { detail: { error: err } }));
    } finally {
      refreshBtn.disabled = false;
    }
  }

  refreshBtn.addEventListener('click', () => {
    // optimistic UI: disable and show spinner indicator
    refreshBtn.disabled = true;
    const originalText = refreshBtn.textContent;
    refreshBtn.textContent = 'Atualizando...';
    load(false).finally(() => {
      refreshBtn.textContent = originalText;
      refreshBtn.disabled = false;
    });
  });

  filterEl.addEventListener('change', applyFilterAndRender);

  await load();
  return container;
}
