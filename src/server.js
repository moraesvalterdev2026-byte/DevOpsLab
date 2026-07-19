// src/server.js
import app from './app.js';

// As 'dotenv' is already called in app.js, process.env is populated here.
const port = process.env.PORT || 3000;

app.listen(port, () => {
  console.log(`Servidor rodando em http://localhost:${port}`);
});