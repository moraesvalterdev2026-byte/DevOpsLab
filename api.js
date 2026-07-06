// /public/js/api.js

const API_BASE_URL = ''; // A URL base é a mesma do servidor que serve o frontend.

/**
 * Um wrapper centralizado para a API fetch.
 * @param {string} endpoint - O endpoint da API a ser chamado (ex: '/api/status').
 * @param {object} options - As opções para a chamada fetch (method, headers, body, etc.).
 * @returns {Promise<object>} - O JSON retornado pela API.
 */
async function fetchApi(endpoint, options = {}) {
    const url = `${API_BASE_URL}${endpoint}`;

    const response = await fetch(url, {
        ...options,
        headers: {
            'Content-Type': 'application/json',
            ...options.headers,
        },
    });

    if (!response.ok) {
        throw new Error(`Erro na API: ${response.status} ${response.statusText}`);
    }

    return response.json();
}