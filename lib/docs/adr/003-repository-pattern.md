# 003 - Uso do Repository Pattern

## Status
Aceito

## Contexto
O projeto iniciará com dados mockados, mas futuramente integrará com Supabase. Com a adoção do MVVM, os ViewModels precisam de uma camada de acesso a dados bem definida.

## Decisão
Manter uma camada de repositório para abstrair o acesso aos dados. Os **ViewModels** chamam o repositório diretamente — as `pages` nunca interagem com ele.

```
Page → ViewModel → Repository → (mock / Supabase)
```

## Consequências
✅ Desacoplamento entre UI e fonte de dados  
✅ ViewModels não precisam mudar quando o backend mudar  
✅ Fácil migração para Supabase — apenas o corpo dos métodos muda  
❌ Adiciona nível de indireção
