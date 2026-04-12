# 001 - Estrutura de Pastas

## Status
Aceito

## Contexto
O projeto precisa de uma organização simples, clara e escalável para separar responsabilidades entre interface, domínio e acesso a dados.

## Decisão
Adotar uma arquitetura em três camadas dentro de `lib/`:

- `pages/` → interface (UI)
- `model/` → entidades de domínio
- `repository/` → acesso a dados

Inspirado no Repository Pattern e com fluxo unidirecional de dados (UDF).

## Consequências
✅ Separação clara de responsabilidades  
✅ Facilidade de manutenção e evolução  
❌ Pode gerar duplicação de componentes visuais inicialmente