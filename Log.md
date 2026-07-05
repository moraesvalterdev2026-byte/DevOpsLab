📖 Diário de Bordo - AXES Bank
Este arquivo documenta a evolução técnica, decisões de arquitetura e o histórico de desenvolvimento do projeto AXES Bank.

📅 2026-07-05 | Registro: Depuração de Front-end e Refinamento de UI/UX 🎨
🎯 Status Atual
A landing page do AXES Bank está visualmente implementada com um design moderno, incluindo uma paleta de cores "vermelho", imagem de fundo e um formulário com efeito "Glassmorphism". Superamos uma série de desafios complexos relacionados ao carregamento de ativos estáticos (CSS e imagens) no ambiente Docker. O código-fonte está estável e correto, aguardando a validação final do ambiente de execução.

🛠️ Alterações Realizadas Hoje
*   **Implementação de UI/UX:** A interface foi completamente refeita, passando por múltiplas iterações de design para refinar a hierarquia visual, tipografia, paleta de cores e responsividade.
*   **Depuração de Ativos Estáticos:**
    *   Corrigimos um erro crítico de digitação no nome do arquivo de imagem (`bakcgraund.jpeg`).
    *   Ajustamos o caminho da imagem no `style.css` para usar um caminho absoluto a partir da raiz do servidor (`/images/...`).
    *   Padronizamos o middleware `express.static` para servir todo o diretório `public` de forma robusta.
*   **Melhoria de Layout:** Ajustamos o CSS da seção `hero` para ocupar 100% da altura da tela (`min-height: 100vh`), eliminando espaços em branco indesejados.
*   **Refinamento do Formulário:** O card de login foi enriquecido com um título claro, link de "Esqueci minha senha" e um aviso de ambiente seguro, melhorando a experiência do usuário.

🧠 Desafios e Aprendizados
O principal desafio foi a depuração do erro "404 Not Found" para os ativos estáticos. A solução exigiu uma análise em múltiplas camadas: a configuração do Express, os caminhos relativos/absolutos no CSS, a estrutura de diretórios dentro do container Docker e, finalmente, a identificação de um simples erro de digitação. Isso reforça a importância de uma depuração metódica e da verificação de cada camada da aplicação.

🛣️ Para Onde Vamos (Próximos Passos)
*   **Imediato:** Validar que a imagem de fundo (`bakcgraund.jpeg`) existe fisicamente no diretório `public/images` e realizar uma reinicialização limpa do ambiente (`docker compose down -v && docker compose up --build`) para garantir que o front-end seja renderizado corretamente.
*   **Curto Prazo:** Conforme planejado anteriormente, iniciar a integração com o banco de dados PostgreSQL, implementando a lógica de conexão na aplicação Node.js.
*   **Médio Prazo:** Criar o primeiro endpoint de API funcional, como um `/api/status` para verificar a saúde da conexão com o banco de dados.

Registro realizado por Valter Moraes.

***************************************************************************************************************************

📅 2026-07-04 | Registro Atual: Infraestrutura Operacional e Versionamento 🚀
🎯 Status Atual (Progresso da Tarde)
O ambiente, agora rodando nativamente em WSL2/Ubuntu, alcançou estabilidade operacional total. O serviço da aplicação responde à rede interna do Docker e está acessível via localhost:3000. A estrutura de arquivos foi oficializada no versionamento Git e o projeto foi aberto para colaboração pública.

🛠️ Alterações Realizadas Hoje (Tarde)
Resolução de Conflitos de Rede: Ajuste crítico no mapeamento de portas (3000:3000) no docker-compose.yml, eliminando conflitos de permissão e roteamento.

Limpeza de Estado: Implementação de ciclo de vida de containers com docker compose down -v e builds no-cache, garantindo que o ambiente de desenvolvimento seja sempre íntegro e livre de lixo residual de builds anteriores.

Padronização de Infraestrutura: Consolidação e versionamento de arquivos essenciais:

infra/Dockerfile (Build otimizado);

infra/docker-compose.yml (Orquestração de serviços);

Makefile (Automação de rotinas de desenvolvimento);

package.json/package-lock.json (Dependências rastreadas).

Visibilidade & Colaboração: Publicação do projeto no GitHub e divulgação no LinkedIn, adotando a prática de Build in Public.

🛣️ Para Onde Vamos (Próximos Passos)
Imediato: Finalizar a integração entre o app (Node.js) e o serviço db (PostgreSQL) usando variáveis de ambiente (dotenv).

Curto Prazo: Implementar a camada de acesso a dados (ORM ou Driver nativo) na pasta /src.

Médio Prazo: Estruturar a estratégia de deploy na AWS utilizando a infraestrutura containerizada atual.

Registro realizado por Valter Moraes.

***************************************************************************************************************************

📅 2026-07-04 | Registro Inicial: Consolidação de Infraestrutura
🚀 Onde Partimos (Contexto Inicial)
O projeto nasceu com a necessidade de uma arquitetura bancária escalável e performática. Inicialmente, o ambiente de desenvolvimento dependia do Docker Desktop sobre Windows, o que gerava latência na comunicação entre containers e um consumo excessivo de recursos de sistema, além de dificuldades com a persistência de arquivos (.vhdx bloated).

🎯 Onde Estamos (Status Atual)
Realizamos a migração total para um ambiente Docker Nativo no WSL2 (Ubuntu).

O ambiente está limpo, sem camadas de virtualização intermediárias.

A estrutura de diretórios foi consolidada para separar preocupações (infra, configs, lógica).

O projeto agora utiliza Docker Compose como orquestrador nativo.

🛠️ Alterações Realizadas Hoje
Limpeza de Ambiente: Desinstalação do Docker Desktop e wsl --unregister docker-desktop para ganho de performance e espaço.

Setup Nativo: Instalação do Docker Engine e docker-compose-plugin diretamente no Ubuntu/WSL.

Estruturação de Pastas: O projeto encontra-se organizado da seguinte forma:

Plaintext
DevOpsLab/
├── configs/    # Configurações de ambiente e serviços
├── docs/       # Documentação técnica (visão geral)
├── infra/      # Arquivos de infraestrutura (Docker, orquestração)
├── logs/       # Diário de bordo e logs de sistema
├── scripts/    # Scripts de automação (CI/CD, utilitários)
├── src/        # Código-fonte da aplicação (Node.js)
└── README.md   # Documentação principal (Vitrine)
🛣️ Para Onde Vamos (Próximos Passos)
Imediato: Configurar o serviço PostgreSQL no docker-compose.yml dentro da pasta /infra.

Curto Prazo: Iniciar o desenvolvimento da estrutura básica do backend na pasta /src.

Médio Prazo: Implementar o pipeline de automação utilizando os scripts na pasta /scripts.

Registro realizado por Valter Moraes.