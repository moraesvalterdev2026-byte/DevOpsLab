# Manual Técnico de Arquitetura Cloud-Native: AXES Bank

* **Versão:** 1.0.0
* **Status:** Aprovado para Implementação
* **Data:** 20 de Julho de 2026
* **Autor:** Valter Lima (Lead DevOps Engineer)

---

## 1. Visão Geral da Arquitetura
O ecossistema **AXES Bank** foi desenhado seguindo os princípios de microsserviços, isolamento de camadas e observabilidade nativa. A transição para o modelo Cloud-Native visa garantir resiliência, escalabilidade horizontal e automação de ponta a ponta (GitOps).

---

## 2. Componentes da Stack e Diretrizes de Engenharia

### 2.1. Containerização & Orquestração (Docker & Kubernetes)
* **Padrão de Imagens:** Construção baseada em multi-stage builds utilizando imagens oficiais e enxutas do Node.js Alpine.
* **Isolamento de Rede:** Comunicação interna restrita via redes virtuais dedicadas (`bridge` no Docker Compose e `ClusterIP` Services no Kubernetes).
* **Persistência de Dados (PostgreSQL):** Utilização de Volumes Persistentes (PV/PVC) para garantir que dados transacionais não sejam perdidos em ciclos de redeploy ou crash de pods.

### 2.2. Provisionamento de Infraestrutura (Terraform & IaC)
* **Estado Remoto:** Gestão de infraestrutura declarativa na AWS (instâncias EC2, grupos de segurança e VPCs).
* **Imutabilidade:** Servidores provisionados via código, garantindo paridade total entre ambientes de homologação e produção.

### 2.3. Empacotamento de Aplicações (Helm Charts)
* **Gestão de Releases:** Substituição de arquivos YAML estáticos por templates parametrizados via Helm.
* **Valores por Ambiente (`values.yaml`):** Separação estrita de configurações sensíveis e variáveis de ambiente utilizando injetores de segredos.

### 2.4. Observabilidade e Monitoramento (Telemetry, Prometheus & Grafana)
* **Métricas de Infraestrutura:** Coleta de uso de CPU, memória e banda de rede dos containers em tempo real.
* **Camada Visual:** O painel do usuário (`dashboard.html`) consome endpoints de telemetria integrados, evoluindo para dashboards centralizados no Grafana alimentados por exporters do Prometheus.

### 2.5. Malha de Serviços e Segurança (Istio & Ingress)
* **Zero Trust Network:** Gerenciamento de tráfego leste-oeste (entre microsserviços) e norte-sul (tráfego externo) criptografado por mTLS através do Istio Service Mesh.
* **Proxy Reverso (Nginx):** Ponto de entrada otimizado para terminação SSL e roteamento de requisições estáticas e dinâmicas da API.

---

## 3. Padrões de Resiliência e Recuperação de Falhas
* **Health Checks:** Implementação rigorosa de *Liveness* e *Readiness probes* em todas as aplicações para reinicialização automática em caso de deadlock ou indisponibilidade de banco de dados.
* **Estratégia de Backup:** Rotinas automatizadas de dump do PostgreSQL (`backup_database.sh`) integradas ao Makefile do projeto. 