# 002 - Organização do Model

## Status
Aceito

## Contexto
As entidades `Medication` e `MedicationSchedule` são fortemente acopladas conceitualmente.

## Decisão
Manter as classes e enums relacionados no mesmo arquivo (`medication.dart`).

## Consequências
✅ Melhor coesão e leitura do domínio  
✅ Menos imports e fragmentação  
❌ Arquivo pode crescer com o tempo  

## Quando revisar
Se `MedicationSchedule` ganhar lógica complexa (validações, cálculos, serialização), separar em outro arquivo.