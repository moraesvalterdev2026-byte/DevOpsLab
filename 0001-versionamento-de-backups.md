# ADR 0001: Não Versionar Arquivos de Backup no Git

**Data:** 2026-07-05

**Status:** Aceito

## Contexto

Durante a conclusão da FASE 1, o fluxo de trabalho sugerido por uma ferramenta de IA propôs um commit que incluía arquivos de backup do banco de dados (`*.sql.gz`) na área de *staging* do Git.

## Decisão

Decidimos explicitamente **não versionar** nenhum arquivo de backup ou artefato binário gerado no repositório Git. Para garantir isso, foram tomadas as seguintes ações:
1.  Os arquivos de backup foram removidos do *staging area* com `git reset`.
2.  A pasta `backups/` foi adicionada ao arquivo `.gitignore` para prevenir futuras inclusões acidentais.

## Justificativa

*   **Tamanho do Repositório:** Backups são arquivos grandes e binários que inflam o tamanho do repositório, tornando operações como `clone` e `fetch` lentas e custosas.
*   **Segurança:** Arquivos de backup podem conter dados sensíveis. Versioná-los no Git representa um risco de segurança significativo, pois o histórico do Git é projetado para ser permanente.
*   **Boas Práticas:** O Git foi projetado para versionar código-fonte (texto), não artefatos de build ou backups. Estes devem ser armazenados em locais apropriados, como um storage de objetos (ex: AWS S3).

Este processo de revisão e correção de uma sugestão automatizada é um exemplo prático do "Trabalho de Lapidação", onde o critério técnico do engenheiro prevalece para garantir a qualidade e segurança do projeto.