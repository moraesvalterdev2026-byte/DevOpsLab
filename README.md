# 🚀 AXES Bank

Projeto de infraestrutura bancária moderna, focado em **DevOps, Governança como Código e Automação de Ciclos de Release**.

Este repositório documenta a jornada técnica de construção de um ambiente escalável, onde a infraestrutura e a governança são tratadas como artefatos de código, garantindo rastreabilidade e qualidade desde o primeiro commit.

---

## ️ Governança e Automação (Developer Experience)

O AXES Bank foi desenhado para ser auto-explicativo. Implementamos um fluxo de trabalho que prioriza a **experiência do desenvolvedor (DX)** e a disciplina técnica:

* **CLI Autodocumentada:** Digite `make` no terminal para visualizar todos os comandos operacionais disponíveis.
* **Gate de Governança:** O script `release_work.sh` atua como um guardião, validando ADRs (Architectural Decision Records) antes de qualquer novo release.
* **Transparência (Build in Public):** Histórico detalhado de decisões arquiteturais e evolução técnica registrado no `Log.md`.
* **Padronização:** Fluxo de versionamento estruturado seguindo as melhores práticas de *Conventional Commits*.

## 🗺️ Status do Roadmap

### FASE 1: Fundamentos de Engenharia

* [x] **LAB 01:** Linux Workstation
* [x] **LAB 02:** Linux Administration
* [x] **LAB 03:** Network Operations
* [x] **LAB 04:** Git Professional

### FASE 2: Containers e Automação

* [x] **LAB 05:** Docker Foundations
* [x] **LAB 06:** Docker Compose
* [x] **LAB 07:** Continuous Integration

### FASE 3: Cloud Native

* [x] **LAB 08:** Infrastructure as Code

### FASE 4: Operação e Plataforma

* [ ] **LAB 09:** Kubernetes Foundations
* [ ] **LAB 10:** Helm
* [ ] **LAB 11:** Observability
* [ ] **LAB 12:** DevSecOps
* [ ] **LAB 13:** GitOps

### FASE 5: Projeto Integrador

* [ ] **LAB 14:** AXES Bank Platform

---

## ⚙️ Tecnologias Utilizadas

* **Core:** Node.js | PostgreSQL
* **Infraestrutura:** Docker, Docker Compose, AWS (EC2), Terraform (IaC)
* **Governança & Automação:** Shell Scripting, ADRs, Git, Makefile

## 🚀 Como começar

Clone o projeto e explore a CLI do AXES Bank:

```bash
# Clone o repositório
git clone git@github.com:moraesvalterdev2026-byte/DevOpsLab.git

# Acesse o diretório e liste os comandos disponíveis
cd DevOpsLab
make

```

### Comandos Principais:

* `make up`: Inicia o ambiente.
* `make release`: Executa o ciclo de auditoria e versionamento.
* `make status`: Monitora os serviços.

---

*Desenvolvido por Valter Moraes | Engenheiro DevOps*
*Construindo o futuro, um commit de cada vez.*
