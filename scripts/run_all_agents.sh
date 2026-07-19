#!/bin/bash
echo "🚀 Executando todos os agentes do projeto AXES Bank..."

echo "-----------------------------------"
echo "🧹 Agente de Build (lint + test)"
make ci

echo "-----------------------------------"
echo "⚡ Agente de Cache"
make cache

echo "-----------------------------------"
echo "📊 Agente de Cobertura"
make coverage

echo "-----------------------------------"
echo "🎨 Agente de Frontend"
make frontend

echo "-----------------------------------"
echo "🔍 Agente de Governança (se configurado)"
make governance || echo "Governança não configurada ainda."

echo "-----------------------------------"
echo "📄 Agente de Documentação (se implementado)"
make docs || echo "Documentação não implementada ainda."

echo "✅ Fluxo completo finalizado!"