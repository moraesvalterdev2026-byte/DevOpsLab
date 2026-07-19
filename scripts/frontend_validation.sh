#!/bin/bash
set -e

echo "Validando funções críticas do frontend..."

validation_passed=true

# Valida se 'fetchApi' está definida e não comentada
if grep -q "fetchApi" api.js && ! grep -q "^\s*//.*fetchApi" api.js; then
    echo "✔ fetchApi: Função ativa encontrada."
else
    echo "✘ fetchApi: Função ausente ou comentada."
    validation_passed=false
fi

# Valida se 'loadComponent' está definida e não comentada
if grep -q "loadComponent" infra/utils.js && ! grep -q "^\s*//.*loadComponent" infra/utils.js; then
    echo "✔ loadComponent: Função ativa encontrada."
else
    echo "✘ loadComponent: Função ausente ou comentada."
    validation_passed=false
fi

[ "$validation_passed" = false ] && exit 1