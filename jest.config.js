// jest.config.js
module.exports = {
  testEnvironment: "node",
  // Arquivo que será executado antes de todos os testes
  setupFiles: ['<rootDir>/setup.js'],
  // Garante que o Jest busque testes apenas na pasta src
  roots: ['<rootDir>/src'],
};