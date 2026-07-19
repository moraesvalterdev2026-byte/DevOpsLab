// /public/js/utils.js

/**
 * Carrega um componente HTML de um arquivo e o injeta em um elemento da página.
 */
export function loadComponent(name) {
  const el = document.getElementById('app');
  el.innerHTML = `<div>Componente ${name} carregado!</div>`;
}