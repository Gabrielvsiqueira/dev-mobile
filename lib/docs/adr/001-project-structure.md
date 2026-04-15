# 001 - Estrutura de Pastas

## Status
Atualizado

## Contexto
O projeto precisa de uma organização clara e escalável para separar responsabilidades entre interface, lógica de negócio, domínio e acesso a dados.

## Decisão
Adotar a arquitetura **MVVM** dentro de `lib/`, mantendo o **Repository Pattern** como camada de acesso a dados:

- `pages/` → View: interface (UI)
- `viewmodels/` → ViewModel: estado e lógica de negócio
- `model/` → Model: entidades de domínio
- `repository/` → acesso a dados
- `widgets/` → componentes visuais reutilizáveis
- `routes/` → configuração de navegação

O fluxo de dados é unidirecional (UDF): `View → ViewModel → Repository → ViewModel → View`.

## Histórico
A estrutura inicial continha apenas `pages/`, `model/` e `repository/`, inspirada no Repository Pattern simples. Com o crescimento das telas, a lógica de negócio foi extraída para `viewmodels/` e os componentes visuais repetidos para `widgets/`.

## Consequências
✅ Separação clara de responsabilidades  
✅ Pages limpas — apenas constroem UI  
✅ ViewModels testáveis independentemente da UI  
✅ Widgets reutilizáveis entre telas  
❌ Mais arquivos no projeto  
❌ Um ViewModel por tela aumenta o número de classes
