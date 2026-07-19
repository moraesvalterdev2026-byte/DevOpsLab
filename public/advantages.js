// public/js/advantages.js

document.addEventListener('DOMContentLoaded', () => {
    // Carrega o cabeçalho dinamicamente
    if (typeof loadHeader === 'function') { try { loadHeader(); } catch (err) { void err; } }

    // Seleciona todos os "trilhos" de produtos da página
    const carousels = document.querySelectorAll('.product-carousel-row');

    carousels.forEach(row => {
        const carousel = row.querySelector('.product-carousel');
        const prevButton = row.querySelector('.carousel-btn.prev');
        const nextButton = row.querySelector('.carousel-btn.next');

        // Accessibility: ensure ids and aria attributes
        if (carousel) {
            const id = carousel.id || `product-carousel-${Math.random().toString(36).substr(2,5)}`;
            carousel.id = id;
            carousel.setAttribute('role', 'region');
            carousel.setAttribute('tabindex', '0');
            const heading = row.querySelector('h3');
            if (heading) carousel.setAttribute('aria-label', heading.textContent);
        }
        if (prevButton) {
            prevButton.setAttribute('aria-controls', carousel?.id || '');
            prevButton.setAttribute('aria-label', 'Anterior');
            prevButton.setAttribute('type', 'button');
        }
        if (nextButton) {
            nextButton.setAttribute('aria-controls', carousel?.id || '');
            nextButton.setAttribute('aria-label', 'Próximo');
            nextButton.setAttribute('type', 'button');
        }

        // Função para verificar e mostrar/ocultar botões
        const updateButtons = () => {
            const maxScrollLeft = carousel.scrollWidth - carousel.clientWidth;
            prevButton.style.display = carousel.scrollLeft > 0 ? 'flex' : 'none';
            nextButton.style.display = carousel.scrollLeft < maxScrollLeft - 1 ? 'flex' : 'none';
        };

        // Event listener para o botão "próximo"
        nextButton.addEventListener('click', () => {
            // Rola o carrossel para a direita (o tamanho de um card + gap)
            carousel.scrollBy({ left: 320, behavior: 'smooth' });
        });

        // Event listener para o botão "anterior"
        prevButton.addEventListener('click', () => {
            // Rola o carrossel para a esquerda
            carousel.scrollBy({ left: -320, behavior: 'smooth' });
        });

        // Atualiza a visibilidade dos botões ao rolar
        carousel.addEventListener('scroll', updateButtons);

        // Atualização inicial ao carregar a página
        // Usamos um pequeno delay para garantir que o layout esteja totalmente calculado
        setTimeout(updateButtons, 100);
    });
});