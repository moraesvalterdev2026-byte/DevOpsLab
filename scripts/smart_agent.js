import fs from 'fs';
import { execSync } from 'child_process';

const [,, targetFile, instruction] = process.argv;

if (!targetFile || !instruction) {
    console.error("Uso: node scripts/smart_agent.js <arquivo> <instrução>");
    process.exit(1);
}

const currentCode = fs.existsSync(targetFile) ? fs.readFileSync(targetFile, 'utf8') : "";

const prompt = `Você é um desenvolvedor. Modifique o arquivo abaixo conforme a instrução. 
Arquivo: ${targetFile}
Código: 
${currentCode}

Instrução: ${instruction}

Retorne APENAS o código modificado. Sem blocos de markdown, sem explicações.`;

// Escapando o prompt para o shell
const escapedPrompt = JSON.stringify(prompt);

try {
    const payload = JSON.stringify({
        model: "gemma:2b",
        prompt: prompt,
        "stream": false
    });

    // Passamos o JSON via -d @- (leitura do stdin) para evitar erros de aspas
    const response = execSync(`curl -s --max-time 300 http://localhost:80/api/generate -d @-`, {
        input: payload
    }).toString();

    // Adicione esta linha para ver o que realmente está vindo
    if (response.includes("<html>")) {
        console.error("ERRO: O Ollama retornou HTML (Possível falha de servidor):");
        console.error(response); 
        process.exit(1);
    }

    const jsonResponse = JSON.parse(response);
    
    if (jsonResponse.response) {
        fs.writeFileSync(targetFile, jsonResponse.response.trim());
        console.log(`✔ Arquivo ${targetFile} atualizado com sucesso.`);
    } else {
        console.error("Erro: O modelo não retornou código. Resposta:", response);
    }
} catch (error) {
    console.error("Falha na execução:", error.message);
}