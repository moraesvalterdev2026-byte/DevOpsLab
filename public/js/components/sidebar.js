/**
 * Sidebar component with accessibility and mobile toggle
 */
export function mountSidebar(selector = '#sidebar') {
  let el = document.querySelector(selector);
  // If no container exists, try to create and insert before main content
  if (!el) {
    const main = document.querySelector('main') || document.body;
    el = document.createElement('aside');
    el.id = selector.replace('#', '') || 'sidebar';
    el.className = 'sidebar-container';
    if (main && main.parentNode) main.parentNode.insertBefore(el, main);
  }
  if (!el) return null;

  el.innerHTML = `
    <nav class="sidebar" role="navigation" aria-label="Navegação secundária">
      <ul class="menu-list" role="menu">
        <li role="none"><a role="menuitem" href="/dashboard.html" class="menu-item">Dashboard</a></li>
        <li role="none"><a role="menuitem" href="/transfer.html" class="menu-item">Transferências</a></li>
        <li role="none"><a role="menuitem" href="/register.html" class="menu-item">Criar conta</a></li>
        <li role="none"><a role="menuitem" href="/advantages.html" class="menu-item">Vantagens</a></li>
      </ul>
    </nav>
  `;

  const nav = el.querySelector('.sidebar');
  const links = Array.from(el.querySelectorAll('.menu-item'));

  // set aria-current based on location
  try {
    const currentPath = window.location.pathname || '/';
    links.forEach((a) => {
      try {
        const href = new URL(a.href, window.location.origin).pathname;
        if (href === currentPath || (href === '/' && currentPath === '/')) {
          a.setAttribute('aria-current', 'page');
        } else {
          a.removeAttribute('aria-current');
        }
      } catch (err) { void err; }
    });
  } catch (err) { void err; }

  // keyboard navigation: Enter/Space, ArrowUp/Down, Home/End, Escape for mobile close
  links.forEach((link, idx) => {
    link.addEventListener('keydown', (e) => {
      if (e.key === 'Enter' || e.key === ' ') {
        e.preventDefault();
        link.click();
        return;
      }
      if (e.key === 'ArrowDown') {
        e.preventDefault();
        const next = links[(idx + 1) % links.length];
        next.focus();
      }
      if (e.key === 'ArrowUp') {
        e.preventDefault();
        const prev = links[(idx - 1 + links.length) % links.length];
        prev.focus();
      }
      if (e.key === 'Home') {
        e.preventDefault();
        links[0].focus();
      }
      if (e.key === 'End') {
        e.preventDefault();
        links[links.length - 1].focus();
      }
      if (e.key === 'Escape') {
        // close mobile sidebar if open
        if (nav.classList.contains('open')) {
          nav.classList.remove('open');
          const btn = document.getElementById('btn-sidebar-toggle');
          if (btn) btn.setAttribute('aria-expanded', 'false');
          if (btn) btn.focus();
        }
      }
    });
  });

  // Insert mobile toggle into header (if present)
  const header = document.getElementById('header-container');
  if (header && !header.querySelector('#btn-sidebar-toggle')) {
    const toggleBtn = document.createElement('button');
    toggleBtn.id = 'btn-sidebar-toggle';
    toggleBtn.className = 'btn btn-ghost mobile-sidebar-toggle';
    toggleBtn.setAttribute('aria-controls', el.id);
    toggleBtn.setAttribute('aria-expanded', 'false');
    toggleBtn.setAttribute('aria-label', 'Abrir menu lateral');
    toggleBtn.innerHTML = '☰';
    // place before theme toggle if available
    const themeToggle = header.querySelector('#theme-toggle');
    if (themeToggle && themeToggle.parentNode) {
      themeToggle.parentNode.insertBefore(toggleBtn, themeToggle);
    } else {
      header.appendChild(toggleBtn);
    }

    toggleBtn.addEventListener('click', () => {
      const expanded = toggleBtn.getAttribute('aria-expanded') === 'true';
      toggleBtn.setAttribute('aria-expanded', (!expanded).toString());
      nav.classList.toggle('open', !expanded);
      if (!expanded) {
        // move focus to first link
        setTimeout(() => links[0] && links[0].focus(), 200);
      }
    });
  }

  // close on outside click for mobile
  document.addEventListener('click', (e) => {
    if (!nav.classList.contains('open')) return;
    if (!nav.contains(e.target) && !(e.target && e.target.id === 'btn-sidebar-toggle')) {
      nav.classList.remove('open');
      const btn = document.getElementById('btn-sidebar-toggle');
      if (btn) btn.setAttribute('aria-expanded', 'false');
    }
  });

  return el;
}
