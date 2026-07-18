// public/js/advantages.js

document.addEventListener('DOMContentLoaded', () => {
    // Carrega o cabeçalho dinamicamente
    loadHeader();

    // Seleciona todos os "trilhos" de produtos da página
    const carousels = document.querySelectorAll('.product-carousel-row');

    carousels.forEach(row => {
        const carousel = row.querySelector('.product-carousel');
        const prevButton = row.querySelector('.carousel-btn.prev');
        const nextButton = row.querySelector('.carousel-btn.next');

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