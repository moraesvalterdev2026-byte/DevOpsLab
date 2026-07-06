# 🗺️ Roadmap de Implementação - Ecossistema Frontend AXES Bank

Este documento detalha o roadmap de desenvolvimento para a interface do usuário (UI) da plataforma AXES Bank, transformando a landing page estática em um portal de serviços dinâmico.

## FASE 1: Fundação do Frontend e UI Kit

**Objetivo:** Estruturar a base do frontend para garantir consistência e escalabilidade.

*   [x] **Tarefa 1.1: Refatoração da Estrutura de Arquivos:** Organização dos assets (CSS, JS) em subdiretórios dedicados.
*   [x] **Tarefa 1.2: Componentização do Layout:** Extração de componentes reutilizáveis (`_header.html`) e implementação de um carregador dinâmico (`utils.js`).
*   [x] **Tarefa 1.3: Criação de um "UI Kit" Básico:** Validação do uso de variáveis CSS para um guia de estilo consistente.

---

## FASE 2: Fluxo de Autenticação

**Objetivo:** Construir a interface para o usuário se autenticar na plataforma.

*   [ ] **Tarefa 2.1: Criação da Página de Login:** Desenvolver a página `login.html` com um formulário de usuário e senha.
*   [ ] **Tarefa 2.2: Criação da Página de Cadastro:** Desenvolver a página `register.html` com um formulário de cadastro.
*   [ ] **Tarefa 2.3: Módulo de API (`api.js`):** Criar um módulo centralizador para as chamadas `fetch`, preparando para a injeção de tokens de autenticação.
*   [ ] **Tarefa 2.4: Lógica de Autenticação (JavaScript):** Implementar a lógica `fetch` para enviar os dados dos formulários para os futuros endpoints de backend (`/api/auth/login`, `/api/auth/register`).

---

## FASE 3: Dashboard do Cliente (Área Logada)

**Objetivo:** Criar a área principal onde o cliente interage com sua conta.

*   [ ] **Tarefa 3.1: Criação da Página do Dashboard:** Desenvolver a página `dashboard.html`, que será a tela principal após o login.
*   [ ] **Tarefa 3.2: Componente de Saldo:** Criar uma seção no dashboard que fará uma chamada `fetch` para o endpoint `/api/accounts/{id}/balance` e exibirá o saldo.
*   [ ] **Tarefa 3.3: Componente de Extrato:** Criar uma tabela ou lista no dashboard que buscará e exibirá as últimas transações do endpoint `/api/accounts/{id}/statement`.

---

## FASE 4: Funcionalidades Transacionais

**Objetivo:** Permitir que o usuário realize operações financeiras.

*   [ ] **Tarefa 4.1: Modal ou Página de Transferência:** Desenvolver a interface para o usuário inserir os dados de uma transferência (conta de destino, valor).
*   [ ] **Tarefa 4.2: Lógica de Transação (JavaScript):** Implementar a lógica `fetch` para enviar a solicitação de transferência para o endpoint `/api/transactions`.

---

## Visão de Futuro (Evolução DevOps)

Uma vez que as funcionalidades do frontend estejam maduras, o pipeline de CI/CD (`.github/workflows/ci.yml`) será expandido para incluir:

1.  **Build de Assets:** Um passo para minificar e otimizar os arquivos CSS e JavaScript.
2.  **Testes de Frontend:** Integração de testes de unidade ou E2E para a interface.
3.  **Deploy Automatizado:** Um job de "Continuous Deployment" que publicará os arquivos estáticos em um serviço como AWS S3.