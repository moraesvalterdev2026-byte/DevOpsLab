// public/js/transfer.js

document.addEventListener('DOMContentLoaded', () => {
    // Carrega o header e verifica a autenticação
    loadHeader();
    checkAuth();

    const transferForm = document.getElementById('transfer-form');
    const messageArea = document.getElementById('message-area');

    transferForm.addEventListener('submit', async (event) => {
        event.preventDefault(); // Impede o envio padrão do formulário

        const destinationAccount = document.getElementById('destinationAccount').value;
        const amount = parseFloat(document.getElementById('amount').value);

        // Validação simples
        if (!destinationAccount || isNaN(amount) || amount <= 0) {
            showMessage('Por favor, preencha todos os campos corretamente.', 'error');
            return;
        }

        try {
            // Chama a função da API para criar a transação
            const result = await api.createTransaction({ destinationAccount, amount });

            showMessage('Transferência realizada com sucesso!', 'success');
            transferForm.reset(); // Limpa o formulário

        } catch (error) {
            // Exibe a mensagem de erro retornada pela API ou uma mensagem genérica
            const errorMessage = error.message || 'Falha ao realizar a transferência. Tente novamente.';
            showMessage(errorMessage, 'error');
        }
    });

    // Função auxiliar para exibir mensagens
    function showMessage(message, type) {
        messageArea.textContent = message;
        messageArea.className = `message-box ${type}`; // Aplica a classe 'success' ou 'error'
        messageArea.style.display = 'block';
    }
});