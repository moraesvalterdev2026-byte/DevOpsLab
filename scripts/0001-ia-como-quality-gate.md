# 0001: Adoção de Auditoria de Governança por IA como Quality Gate

**Status:** Aceito

**Data:** 2026-07-18

## Contexto

O projeto AXES Bank preza pela excelência em Governança como Código e pela automação de processos para garantir a qualidade. A auditoria manual de artefatos de infraestrutura (como `docker-compose.yml`, arquivos Terraform, etc.) é um processo lento, sujeito a erro humano e que não escala com o crescimento do projeto.

Para manter um alto padrão de forma contínua, precisamos de um mecanismo automatizado que verifique a conformidade dos nossos artefatos com as melhores práticas de segurança, resiliência e manutenibilidade a cada ciclo de desenvolvimento.

## Decisão

Decidimos integrar um agente de Inteligência Artificial local (LLM), servido através do Ollama, como um **Quality Gate** mandatório no nosso ciclo de release (`make release`).

Um script dedicado (`scripts/ai_governance_audit.sh`) será responsável por:
1.  Verificar a prontidão do serviço de IA e do modelo de linguagem.
2.  Enviar o conteúdo dos artefatos de infraestrutura relevantes para análise.
3.  Utilizar um prompt de engenharia detalhado para instruir a IA a atuar como um Engenheiro DevOps Sênior, focando em pilares como segurança, confiabilidade e otimização.
4.  Analisar a resposta da IA em busca de problemas críticos. Se forem encontradas palavras-chave como "CRÍTICO" ou "RISCO ALTO", o processo de release será interrompido, forçando a correção antes da integração do código.

## Consequências

### Positivas
*   **Aplicação Contínua de Padrões:** A governança deixa de ser um evento pontual e se torna um processo automatizado e contínuo.
*   **Detecção Precoce de Riscos:** Problemas de configuração e segurança são identificados antes de serem integrados à branch principal.
*   **Histórico de Conformidade:** Os relatórios de auditoria gerados e salvos criam um registro versionado da postura de conformidade do projeto ao longo do tempo.
*   **Maturidade Técnica:** Demonstra a aplicação de conceitos modernos de AIOps e Engenharia de Plataforma.

### Negativas
*   **Nova Dependência:** O projeto passa a depender do serviço Ollama e do modelo de IA para o sucesso do ciclo de release.
*   **Lentidão no Bootstrap Inicial:** A primeira execução do ambiente pode ser lenta devido à necessidade de baixar o modelo de linguagem (ex: `gemma:2b`). O pipeline de automação precisa ser resiliente a esses atrasos.
*   **Dependência da Qualidade do Prompt:** A eficácia da auditoria está diretamente ligada à qualidade e à clareza do prompt enviado à IA.
*   **Risco de Falsos Positivos:** A análise da IA pode, ocasionalmente, gerar falsos positivos que precisam ser avaliados e, se necessário, o *quality gate* ajustado.