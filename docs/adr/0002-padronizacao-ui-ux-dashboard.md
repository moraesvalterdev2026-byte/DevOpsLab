# ADR 0002: Adoção de Tailwind CSS via CDN para UI/UX Hardening do Dashboard

* **Status:** Aceito
* **Data:** 20 de Julho de 2026
* **Autor:** Valter Lima (Lead DevOps Engineer)
* **Issue Relacionada:** #4

## Contexto
O AXES Bank possuía uma interface frontend funcional, porém visualmente estática e pálida ("dashboard.html"), o que desfavorecia a apresentação do projeto como uma fintech corporativa de alto padrão para portfólio. 

## Decisão
Optamos por refatorar o `dashboard.html` utilizando o framework utilitário **Tailwind CSS via CDN** e ícones do FontAwesome. 

## Justificativa Técnica
1. **Agilidade de Entrega:** Evita a complexidade de gerenciar ferramentas de build pesadas (como Webpack ou Vite) na camada estática servida pelo Nginx.
2. **Developer Experience (DX):** Permite um design moderno em modo escuro nativo (Dark Mode) de forma rápida e limpa.
3. **Inovação de SRE:** Introdução de um widget de telemetria integrado na interface, conectando visualmente o front-end ao status dos containers em execução.

## Consequências
* A interface ganha apelo visual sênior sem alterar a arquitetura de entrega baseada em Docker/Nginx.
* Mantém-se a compatibilidade com a camada de scripts existente (`api.js` e `utils.js`).