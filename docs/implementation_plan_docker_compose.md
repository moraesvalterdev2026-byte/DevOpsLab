# 📑 Documento de Implementação — Correções do Docker Compose

Este documento detalha o plano de ação para refatorar o arquivo `docker-compose.yml` do projeto AXES Bank, com base nas recomendações da auditoria de IA. O objetivo é elevar o nível de segurança, resiliência, governança e otimização da nossa infraestrutura local.

---

## 1. Segurança
- **Correção:** Adicionar Nginx como reverse proxy e remover exposição direta das portas 3000 e 11434.
- **Prompt IA (VSCode):**
  ```
  Crie um serviço Nginx no docker-compose.yml que funcione como reverse proxy para o app (porta 3000) e ai (porta 11434). Configure para expor apenas a porta 80 externamente.
  ```

## 2. Confiabilidade e Resiliência
- **Correção:** Adicionar política de restart e healthcheck.
- **Prompt IA (VSCode):**
  ```
  Adicione restart: always e healthcheck para os serviços app, db e ai no docker-compose.yml. Configure o healthcheck para verificar se o serviço responde em sua porta.
  ```

## 3. Governança e Manutenção
- **Correção:** Fixar versões de imagens.
- **Prompt IA (VSCode):**
  ```
  Substitua todas as imagens com tag 'latest' no docker-compose.yml por versões específicas estáveis (exemplo: postgres:16.2, node:20.11).
  ```

## 4. Otimização
- **Correção:** Definir limites de memória e CPU.
- **Prompt IA (VSCode):**
  ```
  Configure deploy.resources.limits para cada serviço no docker-compose.yml, definindo memória máxima de 512M e 1 CPU para app e ai, e 1G e 2 CPUs para db.
  ```

## 5. Observabilidade
- **Correção:** Integrar Prometheus e Grafana.
- **Prompt IA (VSCode):**
  ```
  Adicione serviços Prometheus e Grafana ao docker-compose.yml, configurando Prometheus para coletar métricas dos containers e Grafana para visualizar dashboards.
  ```

---

# 🗺️ Roadmap de Implementação das Correções

A implementação seguirá uma abordagem faseada para garantir estabilidade e controle.

### Fase 1: Fundamentos e Governança
*   **Passo 1.1 (Governança):** Fixar as versões das imagens (`postgres`, `node`, `ollama`) para garantir builds reproduzíveis.
*   **Passo 1.2 (Confiabilidade):** Adicionar a política `restart: always` a todos os serviços para garantir que eles se recuperem de falhas.
*   **Passo 1.3 (Confiabilidade):** Implementar `healthchecks` detalhados para os serviços `app` e `ai`, complementando o já existente no `db`.

### Fase 2: Segurança e Otimização
*   **Passo 2.1 (Segurança):** Introduzir o Nginx como reverse proxy, centralizando o acesso na porta 80 e removendo a exposição direta das portas dos serviços.
*   **Passo 2.2 (Otimização):** Aplicar limites de recursos (CPU e memória) para cada serviço, prevenindo o consumo excessivo e simulando um ambiente de produção mais realista.

### Fase 3: Observabilidade
*   **Passo 3.1 (Observabilidade):** Adicionar os serviços Prometheus e Grafana ao `docker-compose.yml`.
*   **Passo 3.2 (Observabilidade):** Configurar o Prometheus para coletar métricas dos contêineres e criar um dashboard inicial no Grafana.

---

## 🎯 Resultado Esperado
- `docker-compose.yml` passa a ser **seguro, resiliente e otimizado**.
- Auditoria de IA valida automaticamente cada alteração como *quality gate*.
- Observabilidade integrada garante visibilidade corporativa.
- Documentação (ADRs e roadmap) reflete governança contínua.

---