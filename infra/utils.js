// /public/js/utils.js

/**
 * Carrega um componente HTML de um arquivo e o injeta em um elemento da página.
 */
async function loadComponent(elementId, file) {
    const response = await fetch(file);
    const html = await response.text();
    document.getElementById(elementId).innerHTML = html;
}