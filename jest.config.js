// jest.config.js
export default {
  testEnvironment: "node",
  // Arquivo que será executado antes de todos os testes para carregar variáveis de ambiente
  setupFiles: ["<rootDir>/jest.setup.js"],
  // Garante que o Jest busque testes apenas na pasta src
  roots: ["<rootDir>/src"],
};