import { fetchApi } from './api.js';

document.addEventListener('DOMContentLoaded', () => {
    const token = localStorage.getItem('authToken');
    if (!token) {
        // Se não houver token, redireciona para a página de login
        window.location.href = '/login.html';
        return;
    }

    loadProfile(token);
    loadAccounts(token);
    loadTransactions(token);

    document.getElementById('btn-logout').addEventListener('click', () => {
        localStorage.removeItem('authToken');
        window.location.href = '/login.html';
    });

    document.getElementById('transactionForm').addEventListener('submit', async (e) => {
        e.preventDefault();
        const from_account_id = document.getElementById('from-account').value;
        const to_account_id = document.getElementById('to-account').value;
        const amount = document.getElementById('amount').value;

        try {
            const result = await fetchApi('transactions', {
                method: 'POST',
                headers: { 'Authorization': `Bearer ${token}` },
                body: JSON.stringify({ from_account_id, to_account_id, amount }),
            });
            document.getElementById('transfer-message').textContent = result.message || result.error;
            loadAccounts(token); // Recarrega as contas para atualizar o saldo
            loadTransactions(token); // Recarrega o extrato
        } catch (error) {
            document.getElementById('transfer-message').textContent = 'Erro ao realizar transferência.';
        }
    });
});

async function loadProfile(token) {
    try {
        const data = await fetchApi('profile', {
            headers: { 'Authorization': `Bearer ${token}` }
        });
        document.getElementById('user-email').textContent = data.user.email;
    } catch (error) {
        console.error('Falha ao carregar perfil:', error);
        // Se o token for inválido, limpa e redireciona
        localStorage.removeItem('authToken');
        window.location.href = '/login.html';
    }
}

async function loadAccounts(token) {
    try {
        const accounts = await fetchApi('accounts', {
            headers: { 'Authorization': `Bearer ${token}` }
        });
        const accountsListDiv = document.getElementById('accounts-list');
        const fromAccountSelect = document.getElementById('from-account');

        if (accounts.length > 0) {
            const accountsHTML = accounts.map(acc => `
                <div class="account-item">
                    <span>Conta ID: ${acc.id}</span>
                    <strong>Saldo: R$ ${parseFloat(acc.balance).toFixed(2)}</strong>
                </div>
            `).join('');
            accountsListDiv.innerHTML = `<h2>Suas Contas</h2>${accountsHTML}`;

            // Preenche o seletor de contas para transferência
            fromAccountSelect.innerHTML = accounts.map(acc => `<option value="${acc.id}">Conta ${acc.id}</option>`).join('');
        } else {
            accountsListDiv.innerHTML = `<h2>Suas Contas</h2><p>Você ainda não possui contas.</p>`;
        }
    } catch (error) {
        console.error('Falha ao carregar contas:', error);
    }
}

async function loadTransactions(token) {
    try {
        const transactions = await fetchApi('transactions', {
            headers: { 'Authorization': `Bearer ${token}` }
        });
        const historyDiv = document.getElementById('transaction-history');
        if (transactions.length > 0) {
            const historyHTML = transactions.map(tx => `
                <div class="transaction-item">
                    <span>De: ${tx.from_account_id} | Para: ${tx.to_account_id}</span>
                    <strong>Valor: R$ ${parseFloat(tx.amount).toFixed(2)}</strong>
                    <small>${new Date(tx.created_at).toLocaleString()}</small>
                </div>
            `).join('');
            historyDiv.innerHTML = `<h2>Histórico de Transações</h2>${historyHTML}`;
        } else {
            historyDiv.innerHTML = `<h2>Histórico de Transações</h2><p>Nenhuma transação encontrada.</p>`;
        }
    } catch (error) {
        console.error('Falha ao carregar transações:', error);
    }
}