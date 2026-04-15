# 009 - Extração de Widgets Reutilizáveis

## Status
Aceito

## Contexto
Com múltiplas telas implementadas, componentes visuais idênticos passaram a aparecer em mais de um lugar. Mantê-los duplicados dentro das `pages` criaria inconsistência visual e dificuldade de manutenção.

## Decisão
Criar a pasta `widgets/` para abrigar componentes visuais reutilizáveis. Um componente é extraído quando:

1. Aparece em mais de uma tela, **ou**
2. Tem lógica de layout suficientemente complexa para justificar isolamento

## Widgets extraídos

| Widget | Responsabilidade | Usado em |
|---|---|---|
| `MedicationCard` | Card de medicamento com status e horário | `home_page`, `calendar_page` |
| `HistoryCard` | Card de histórico de tomadas | `calendar_page` |
| `StatCard` | Card de estatística com ícone e valor | `profile_page` |
| `ContactCard` | Card de contato de emergência | `emergency_page` |
| `WizardSteps` | Indicador de progresso do wizard | `medication_wizard_page` |
| `AppBottomNav` | Barra de navegação inferior | Todas as telas principais |

## Consequências
✅ Consistência visual garantida — alterar um widget reflete em todas as telas  
✅ Pages mais limpas e legíveis  
✅ Facilidade de evoluir um componente em um único lugar  
❌ Componentes com muitos parâmetros podem se tornar complexos com o tempo
