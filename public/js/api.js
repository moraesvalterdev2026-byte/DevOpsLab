// /public/js/api.js

const API_BASE_URL = ''; // A URL base é a mesma do servidor que serve o frontend.

/**
 * Um wrapper centralizado para a API fetch.
 * @param {string} endpoint - O endpoint da API a ser chamado (ex: 'auth/register', '/api/status').
 * @param {object} options - As opções para a chamada fetch (method, headers, body, etc.).
 * @returns {Promise<object>} - O JSON retornado pela API.
 */
export async function fetchApi(endpoint, options = {}) {
    // Normaliza o endpoint para remover o prefixo '/api/' ou barras iniciais duplicadas, se houver
    let cleanEndpoint = endpoint.trim();
    if (cleanEndpoint.startsWith('/api/')) {
        cleanEndpoint = cleanEndpoint.replace('/api/', '');
    }
    if (cleanEndpoint.startsWith('/')) {
        cleanEndpoint = cleanEndpoint.slice(1);
    }

    const url = `${API_BASE_URL}/api/${cleanEndpoint}`;

    const defaultOptions = {
        headers: {
            'Content-Type': 'application/json',
            ...options.headers,
        },
    };

    const response = await fetch(url, { ...defaultOptions, ...options });

    if (!response.ok) {
        // Tenta extrair uma mensagem de erro do corpo da resposta, se houver
        const errorData = await response.json().catch(() => ({ error: `Erro na API: ${response.statusText}` }));
        throw new Error(errorData.error || `Erro ${response.status}`);
    }

    return response.json();
}