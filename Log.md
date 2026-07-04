Diário de Bordo - AXES Bank
Este arquivo documenta a evolução técnica, decisões de arquitetura e o histórico de desenvolvimento do projeto AXES Bank.

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