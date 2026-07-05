const express = require('express');
const path = require('path');
const routes = require('./routes');

const app = express();
const port = process.env.PORT || 3000;

// Middlewares
app.use(express.json()); // Habilita o parsing de JSON no corpo das requisições
// Serve todos os arquivos estáticos a partir da pasta 'public'
app.use(express.static(path.join(__dirname, '..', 'public')));

// Carrega as rotas da aplicação
app.use('/', routes);

app.listen(port, () => {
  console.log('Servidor rodando em http://localhost:' + port);
});

module.exports = app; // Exporta para uso em testes