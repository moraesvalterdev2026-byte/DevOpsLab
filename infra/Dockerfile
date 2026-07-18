# Estágio de construção
FROM node:20-alpine AS builder
WORKDIR /app
# Instala o curl, necessário para o healthcheck no docker-compose.
RUN apk add --no-cache curl

COPY package*.json ./
RUN npm ci
COPY . .

# Estágio de execução
FROM node:20-alpine
WORKDIR /app
COPY --from=builder /app /app
EXPOSE 3000
CMD ["npm", "start"]