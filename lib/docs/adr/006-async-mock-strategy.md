# 006 - Estratégia Async com Mock

## Status
Aceito

## Contexto
O app ainda não possui backend real, mas precisa simular comportamento realista.

## Decisão
Utilizar `Future.delayed` nos métodos do repositório.

## Consequências
✅ UI preparada para latência real  
✅ Evita bugs na transição para API  
❌ Pequeno overhead no desenvolvimento inicial