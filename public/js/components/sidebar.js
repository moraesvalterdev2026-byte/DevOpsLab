/**
 * Sidebar component
 */
export function mountSidebar(selector = '#sidebar') {
  const el = document.querySelector(selector);
  if (!el) return null;

  el.innerHTML = `
    <nav class="sidebar">
      <ul class="menu-list">
        <li><a href="/dashboard.html" class="menu-item" aria-current="page">Dashboard</a></li>
        <li><a href="/transfer.html" class="menu-item">Transferências</a></li>
        <li><a href="/register.html" class="menu-item">Criar conta</a></li>
        <li><a href="/advantages.html" class="menu-item">Vantagens</a></li>
      </ul>
    </nav>
  `;

  // basic accessibility and keyboard support
  el.querySelectorAll('.menu-item').forEach((link) => {
    link.addEventListener('keydown', (e) => {
      if (e.key === 'Enter' || e.key === ' ') link.click();
    });
  });

  return el;
}
