# 004 - Repository como Singleton

## Status
Aceito

## Contexto
É necessário manter consistência dos dados em memória entre diferentes telas.

## Decisão
Implementar `MedicationRepository` como Singleton.

## Consequências
✅ Estado compartilhado consistente  
✅ Simples de usar em todo o app  
❌ Pode dificultar testes no futuro (mock global)