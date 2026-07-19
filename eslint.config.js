import globals from "globals";
import js from "@eslint/js";
import jest from "eslint-plugin-jest";

export default [
  // Configuração recomendada pelo ESLint
  js.configs.recommended,

  // Configuração recomendada para testes com Jest
  jest.configs["flat/recommended"],

  {
    // Aplica-se a todos os arquivos
    languageOptions: {
      ecmaVersion: "latest",
      sourceType: "module",
      globals: {
        ...globals.node,
        ...globals.browser, // Mantido para scripts de frontend
        // Globais personalizados do projeto
        api: "readonly",
        fetchApi: "readonly",
        loadHeader: "readonly",
        checkAuth: "readonly",
        loadComponent: "readonly",
      },
    },
    rules: {
      "no-unused-vars": "warn",
      "no-undef": "error",
    },
  },
  {
    // Ignora o próprio arquivo de configuração do ESLint
    ignores: ["eslint.config.js"],
  },
];