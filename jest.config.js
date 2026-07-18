// jest.config.js
module.exports = {
  testEnvironment: "node",
  // Arquivo que será executado antes de todos os testes
  setupFiles: ['<rootDir>/setup.js'],
  // Diretório onde os testes estão localizados
  roots: ['<rootDir>'],
};