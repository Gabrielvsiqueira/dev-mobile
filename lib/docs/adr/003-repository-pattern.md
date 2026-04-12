# 003 - Uso do Repository Pattern

## Status
Aceito

## Contexto
O projeto iniciará com dados mockados, mas futuramente integrará com Supabase.

## Decisão
Criar uma camada de repositório para abstrair o acesso aos dados.

## Consequências
✅ Desacoplamento entre UI e fonte de dados  
✅ Fácil migração para backend real  
❌ Adiciona nível de indireção