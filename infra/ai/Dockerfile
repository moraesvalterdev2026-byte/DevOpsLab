# /home/moraes/EngDevOps/DevOpsLab/infra/ai/Dockerfile

FROM ollama/ollama:latest

# Cria um usuário e um grupo específicos para a aplicação com um ID fixo.
# O ID fixo (1001) é uma boa prática para consistência entre ambientes.
# A flag -D significa "não atribuir uma senha".
RUN adduser -D -u 1001 appuser

# Define o diretório de trabalho para o novo usuário.
WORKDIR /home/appuser

# Muda para o usuário não-root.
USER appuser