# 005 - Estrutura de Pages

## Status
Atualizado

## Contexto
O app possui múltiplas telas com responsabilidades distintas. Com a adoção do MVVM, as `pages` passaram a ser exclusivamente responsáveis pela UI.

## Decisão
Uma tela por arquivo dentro de `pages/`. Cada page:
- Instancia seu ViewModel no `initState`
- Escuta o ViewModel via `ListenableBuilder`
- Delega toda lógica de negócio ao ViewModel
- Não acessa o repositório diretamente

```dart
// Correto
_viewModel.reload();

// Errado — pages não devem acessar o repositório
MedicationRepository().getMedicationsForDay(date);
```

## Telas existentes

| Arquivo | Responsabilidade |
|---|---|
| `login_page.dart` | Coleta nome e telefone, persiste em `AppSession` |
| `home_page.dart` | Lista de remédios do dia e navegação |
| `medication_wizard_page.dart` | Wizard de criação e edição de medicamentos |
| `calendar_page.dart` | Visão mensal do histórico |
| `profile_page.dart` | Dados do usuário e ações de conta |
| `alarm_page.dart` | Lembrete ativo com confirmação de tomada |
| `emergency_page.dart` | Contatos de emergência |

## Consequências
✅ Pages limpas e focadas em UI  
✅ Baixo acoplamento entre telas  
✅ Lógica testável no ViewModel sem depender do Flutter  
❌ Possível duplicação de componentes visuais — mitigado pela pasta `widgets/`
