# 📄 Documentação do Projeto  
## Loop de Desenvolvimento com Agentes

### 🎯 Objetivo
Criar um ciclo contínuo de desenvolvimento onde **agentes de IA atuam como desenvolvedores internos** em áreas específicas (HTML, CSS, JavaScript, Banco de Dados e Segurança). O trabalho dos agentes é validado automaticamente por meio de testes, garantindo evolução incremental e confiável do sistema.

---

### 🧩 Estrutura dos Agentes
Cada agente representa um “dev interno” especializado:

- **Agente HTML** → gera a estrutura das páginas (layouts, formulários, tabelas).  
- **Agente CSS** → estiliza páginas com responsividade e consistência visual.  
- **Agente JavaScript** → implementa lógica de frontend, chamadas API e interatividade.  
- **Agente Banco de Dados** → cria migrations, queries SQL e seeds de dados.  
- **Agente de Segurança** → adiciona autenticação, criptografia e sanitização de inputs.  

---

### 🔄 Ciclo de Desenvolvimento
O loop segue etapas repetitivas e incrementais:

1. **Planejamento**  
   - Definir a funcionalidade desejada (ex.: formulário de login).  

2. **Execução pelos agentes**  
   - HTML gera a estrutura.  
   - CSS estiliza.  
   - JS implementa lógica.  
   - BD cria tabelas.  
   - Segurança adiciona proteção.  

3. **Validação automática**  
   - Rodar `make test` e `make coverage`.  
   - Testes confirmam se o código funciona e atende requisitos.  

4. **Correção**  
   - Se falhar, o agente correspondente ajusta o código.  

5. **Iteração**  
   - O ciclo recomeça para a próxima funcionalidade.  

---

### ⚙️ Integração com Makefile
Cada agente possui um target próprio:

```makefile
html: ## 🌐 Gera/valida HTML
	@echo "Agente HTML atuando..."
	@node scripts/html_agent.js

css: ## 🎨 Gera/valida CSS
	@echo "Agente CSS atuando..."
	@node scripts/css_agent.js

javascript: ## 📜 Gera/valida JS
	@echo "Agente JS atuando..."
	@node scripts/js_agent.js

database: ## 🗄️ Gera/valida BD
	@echo "Agente BD atuando..."
	@bash scripts/db_agent.sh

security: ## 🔒 Gera/valida segurança
	@echo "Agente Segurança atuando..."
	@bash scripts/security_agent.sh
```

---

### 📈 Benefícios
- **Automação inteligente** → agentes produzem código como devs internos.  
- **Validação contínua** → testes garantem qualidade sem intervenção manual.  
- **Escalabilidade** → novos agentes podem ser adicionados (ex.: documentação, governança).  
- **Agilidade** → ciclo rápido de entrega e correção.  

---

### 🚀 Roadmap de Evolução
- **Fase 1:** HTML, CSS e JS básicos.  
- **Fase 2:** Banco de Dados e Segurança.  
- **Fase 3:** Integração com CI/CD (GitHub Actions).  
- **Fase 4:** Agente de Documentação e Governança.  
- **Fase 5:** Expansão para testes de UI e auditoria de performance.  