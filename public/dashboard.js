// /public/js/dashboard.js

document.addEventListener('DOMContentLoaded', () => {
  // Em um cenário real, verificaríamos se o usuário está autenticado
  // (ex: checando um token no localStorage).

  const userNameElement = document.getElementById('user-name');
  const balanceComponent = document.getElementById('balance-component');
  const statementComponent = document.getElementById('statement-component');

  async function loadUserData() {
    // Simula a busca de dados do usuário
    // No futuro, buscaria de um endpoint como /api/me
    userNameElement.textContent = "Valter Moraes";
  }

  async function loadBalanceComponent() {
    try {
      // Simula a chamada para o endpoint de saldo.
      // Usamos /api/status para garantir uma resposta bem-sucedida.
      await fetchApi('/api/accounts/123/balance'); // O ID é simbólico

      // Simula um valor de saldo
      const balance = 1234.56;
      const formattedBalance = balance.toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' });

      balanceComponent.innerHTML = `
                <h2>Saldo em Conta</h2>
                <p class="balance-value">${formattedBalance}</p>
            `;

    } catch (error) {
      console.error('Erro ao carregar o saldo:', error);
      balanceComponent.innerHTML = `
                <h2>Saldo em Conta</h2>
                <p class="balance-error">Não foi possível carregar o saldo.</p>
            `;
    }
  }

  async function loadStatementComponent() {
    try {
      // Simula a chamada para o endpoint de extrato
      await fetchApi('/api/accounts/123/statement');

      // Simula dados de transações
      const transactions = [
        { date: '2026-07-06', description: 'Salário', amount: 5000.00, type: 'credit' },
        { date: '2026-07-05', description: 'Compra Supermercado', amount: -250.75, type: 'debit' },
        { date: '2026-07-04', description: 'Pagamento Fatura', amount: -1200.00, type: 'debit' },
        { date: '2026-07-03', description: 'Transferência Recebida', amount: 300.00, type: 'credit' },
      ];

      let statementHtml = `<h2>Últimas Transações</h2><ul class="statement-list">`;
      transactions.forEach(tx => {
        const formattedAmount = tx.amount.toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' });
        const amountClass = tx.type === 'credit' ? 'credit' : 'debit';
        statementHtml += `
          <li class="statement-item">
            <span class="tx-date">${tx.date}</span>
            <span class="tx-description">${tx.description}</span>
            <span class="tx-amount ${amountClass}">${formattedAmount}</span>
          </li>
        `;
      });
      statementHtml += `</ul>`;

      statementComponent.innerHTML = statementHtml;

    } catch (error) {
      console.error('Erro ao carregar o extrato:', error);
      statementComponent.innerHTML = `
        <h2>Últimas Transações</h2>
        <p class="statement-error">Não foi possível carregar o extrato.</p>
      `;
    }
  }

  loadUserData();
  loadBalanceComponent();
  loadStatementComponent();
});