# 🗺️ Roadmap de Implementação - AXES Bank

Este documento detalha o roadmap de desenvolvimento da plataforma AXES Bank, alinhado com o **Master Engineering Blueprint**. Cada fase representa um marco na evolução das competências e da arquitetura do projeto.

## FASE 1: Fundamentos de Engenharia

**Objetivo:** Construir a base técnica sólida para administração de sistemas e automação.

- [x] **LAB 01: Linux Workstation**
  - **Meta:** Preparar um ambiente de desenvolvimento Linux profissional e seguro.
  - **Competências:** Linux, Terminal, SSH, Permissões, `systemd`.
  - **Entregáveis:** Ambiente Linux (WSL2) configurado e operacional.

- [x] **LAB 02: Linux Administration**
  - **Meta:** Automatizar tarefas administrativas repetitivas.
  - **Competências:** Bash, Cron, Backup, Hardening.
  - **Entregáveis:** Kit de scripts de administração, rotina de backup automatizada.

- [x] **LAB 03: Network Operations**
  - **Meta:** Publicar serviços na web de forma segura.
  - **Competências:** DNS, TCP/IP, HTTP/HTTPS, Firewall, Nginx (Reverse Proxy).
  - **Entregáveis:** Aplicação Node.js servindo conteúdo estático e acessível via rede.

- [x] **LAB 04: Git Professional**
  - **Meta:** Organizar o fluxo de desenvolvimento com padrões de mercado.
  - **Competências:** Git, Branches (Git Flow), Pull Requests, Releases.
  - **Entregáveis:** Repositório no GitHub com histórico de commits e `Log.md` detalhado.

---

## FASE 2: Containers e Automação

**Objetivo:** Tornar a aplicação reproduzível, padronizada e automatizar o ciclo de entrega.

- [x] **LAB 05: Docker Foundations**
  - **Meta:** Containerizar a aplicação AXES Bank.
  - **Status:** A aplicação já possui um `Dockerfile` e está sendo executada em um container.
  - **Competências:** Docker, Dockerfile (multi-stage), Volumes, Networks.
  - **Entregáveis:** API funcional executando em um container Docker.

- [x] **LAB 06: Docker Compose**
  - **Meta:** Orquestrar o ambiente de desenvolvimento local completo.
  - **Status:** O `docker-compose.yml` já orquestra os serviços `app` (Node.js) e `db` (PostgreSQL).
  - **Competências:** Docker Compose.
  - **Entregáveis:** Stack completa e funcional com um único comando (`docker-compose up`).

- [x] **LAB 07: Continuous Integration**
  - **Meta:** Automatizar a validação e o build do projeto.
  - **Competências:** GitHub Actions, Testes, Lint, Build, Container Registry.
  - **Entregáveis:** Pipeline de CI funcional no GitHub.

---

## FASE 3: Cloud Native

**Objetivo:** Provisionar e operar a plataforma em um ambiente de nuvem, utilizando infraestrutura como código e orquestração de containers.

- [ ] **LAB 08: Infrastructure as Code**
  - **Meta:** Provisionar a infraestrutura na nuvem de forma automatizada.
  - **Competências:** Terraform/OpenTofu, VPC, EC2, IAM, Security Groups.
  - **Entregáveis:** Infraestrutura na AWS criada e gerenciada por código.

- [ ] **LAB 09: Kubernetes Foundations**
  - **Meta:** Migrar a aplicação para um ambiente orquestrado com Kubernetes.
  - **Competências:** Pods, Deployments, Services, Ingress.
  - **Entregáveis:** Aplicação rodando em um cluster Kubernetes funcional.

- [ ] **LAB 10: Helm**
  - **Meta:** Empacotar e gerenciar a aplicação no Kubernetes de forma padronizada.
  - **Competências:** Helm, Templates, Releases.
  - **Entregáveis:** Helm Chart para o AXES Bank.

---

## FASE 4: Operação e Plataforma

**Objetivo:** Implementar práticas avançadas de DevOps, SRE e Platform Engineering para operar o sistema com alta disponibilidade, segurança e observabilidade.

- [ ] **LAB 11: Observability**
  - **Meta:** Obter visibilidade completa sobre a saúde e o desempenho da plataforma.
  - **Competências:** Prometheus, Grafana, Loki, OpenTelemetry.
  - **Entregáveis:** Dashboards de monitoramento e sistema de alertas.

- [ ] **LAB 12: DevSecOps**
  - **Meta:** Integrar a segurança em todo o ciclo de vida do desenvolvimento.
  - **Competências:** Trivy, Vault, Secrets Management, Image Scanning.
  - **Entregáveis:** Pipeline de CI/CD com etapas de segurança automatizadas.

- [ ] **LAB 13: GitOps**
  - **Meta:** Automatizar o deploy contínuo de forma declarativa.
  - **Competências:** Argo CD, GitOps, Progressive Delivery.
  - **Entregáveis:** Fluxo de deploy declarativo com o Git como única fonte da verdade.

---

## FASE 5: Projeto Integrador

**Objetivo:** Consolidar todas as competências adquiridas para construir uma plataforma completa, modular e robusta, simulando um ambiente corporativo.

- [ ] **LAB 14: AXES Bank Platform**
  - **Meta:** Integrar todos os laboratórios anteriores em uma plataforma coesa.
  - **Módulos:** Auth, Accounts, Transactions, Credit, Notifications, Admin, Audit.
  - **Infraestrutura:** Kubernetes, Terraform, Helm, GitHub Actions, Argo CD, Prometheus, Grafana, Loki, Vault, Trivy.
  - **Entregáveis:** Plataforma completa, documentação técnica, diagramas, pipelines, dashboards e ambiente totalmente reproduzível.