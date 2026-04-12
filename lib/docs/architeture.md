# Alo, Nenê! - Decisões de Arquitetura

Este documento registra todas as decisões técnicas e de arquitetura tomadas durante o desenvolvimento do **Alô, Nenê!**, um lembrete de medicamentos para pessoas idosas. Cada decisão é acompanhada de contexto, motivação e trade-offs conhecidos.

## 1. Definição

É um aplicativo mobile desenvolvido em Flutter, desenhado para ajudar pessoas idosas a se lembrarem de tomar seus medicamentos diarios. O aplicativo combina lembretes com audio gravado por familiares, interfaces de usuários acessíveis e suporte a multiplos tipos de recorrencia.

- **Público-alvo principal:** pessoas idosas com pouca familiaridade com tecnologia
- **Público-alvo secundário:** familiares e cuidadores que configuram os lembretes remotamente.

### 1.1 Stacks

| Camada | Tecnologia | Motivo da escolha |
|---|---|---|
| Frontend | Flutter (Dart) | Único código para iOS e Android com performance nativa |

---

## 2. Estrutura de Pastas
O projeto segue uma arquitetura de três camadas explícita dentro de `lib/`, inspirada no **Repository Pattern**. Cada pasta tem uma responsabilidade única e bem definida. Seguindo os conceitos de UDF (**Unidirectional data flow**).

```
lib/
├── main.dart
│
├── pages/
│   ├── login_page.dart               ✅ pronto
│   ├── home_page.dart                ✅ pronto
│   ├── medication_wizard_page.dart   ✅ pronto
│
├── model/
│   └── medication.dart               ✅ pronto
│
└── repository/
    └── medication_repository.dart    ✅ pronto (mockado → Supabase depois)
```

| Arquivo | Responsabilidade | Status |
|---|---|---|
| `main.dart` | Ponto de entrada, inicialização do tema e rota inicial | ✅ Pronto |
| `pages/login_page.dart` | Coleta nome e telefone do idoso (mockado). Navega para `HomePage` com `userName`. | ✅ Pronto |
| `pages/home_page.dart` | Exibe lista de remédios do dia, strip de datas e botões de ação | ✅ Pronto |
| `pages/medication_wizard_page.dart` | Wizard de 4 passos para adicionar ou editar medicamento. Modo edit via parâmetro opcional. | ✅ Pronto |
| `model/medication.dart` | Classes `Medication`, `MedicationSchedule` e enums de status e recorrência | ✅ Pronto |
| `repository/medication_repository.dart` | Singleton com dados mockados. Interface pública que será substituída pelo Supabase. | ✅ Pronto |
 
---

## 3. Model

### 3.1 Por que duas classes no mesmo arquivo?
 
O arquivo `medication.dart` contém quatro definições: os enums `MedicationStatus` e `RecurrenceType`, e as classes `Medication` e `MedicationSchedule`. Essa escolha é intencional e segue o princípio de **coesão conceitual**.
 
**Regra aplicada:** classes ficam no mesmo arquivo quando são inseparáveis conceitualmente.
 
- Um `Medication` sem `MedicationSchedule` não tem utilidade no app — você nunca busca um sem o outro
- Os enums `MedicationStatus` e `RecurrenceType` existem exclusivamente para tipar campos dessas duas classes
- Separar em arquivos distintos criaria imports cruzados desnecessários e fragmentaria a leitura do domínio
 
> **Quando separar:** se `MedicationSchedule` ganhar lógica própria complexa (serializar JSON, calcular próxima dose, validar intervalos), vale extrair para `medication_schedule.dart`. Por enquanto, juntos é mais simples e mais legível.
 
### 3.2 Responsabilidade de cada definição
 
| Classe / Enum | Responsabilidade |
|---|---|
| `Medication` | Representa o remédio em si: nome, dosagem, observações, URL do áudio e a lista de agendamentos associados |
| `MedicationSchedule` | Representa um agendamento específico: horário, tipo de recorrência, dias da semana, intervalo em horas e status atual da tomada |
| `MedicationStatus` | Enum com três estados: `taken` (já tomou), `pending` (passou do horário, não tomou) e `upcoming` (ainda não chegou a hora) |
| `RecurrenceType` | Enum com três tipos: `daily` (todo dia), `weekly` (dias específicos) e `interval` (a cada X horas) |

# 4. Repository
 
### 4.1 Por que usar o padrão Repository?
 
O **Repository Pattern** cria uma camada de abstração entre a fonte de dados (mockada ou Supabase) e as telas do app. As `pages` nunca sabem de onde os dados vêm — elas só chamam métodos do repositório e recebem modelos.
 
**Benefício principal:** quando o backend mudar de mockado para Supabase, apenas o corpo dos métodos do repositório muda. Nenhuma tela precisa ser alterada.
 
> **Trade-off:** adiciona um nível de indireção. Pode parecer muitos simples, overhead. Mas tem um porque. A justificativa aqui é a clareza de onde buscar dados quando o projeto escalar.
 
### 4.2 Por que Singleton?
 
O `MedicationRepository` é implementado como Singleton — uma única instância compartilhada por todo o app. Isso garante que os dados mockados em memória sejam consistentes entre telas diferentes.
 
```dart
static final MedicationRepository _instance = MedicationRepository._internal();
factory MedicationRepository() => _instance;
```
 
- Se a `HomePage` adicionar um remédio pelo wizard, a lista atualizada aparece imediatamente ao voltar
- Não há risco de duas instâncias com estados divergentes
- Quando integrar o Supabase, o Singleton continuará sendo útil — o cliente Supabase também é naturalmente singleton
 
### 4.3 Por que `Future.delayed` nos métodos mockados?
 
Todos os métodos do repositório retornam `Future<T>` e incluem um `Future.delayed` simulando latência de rede (200–400ms), conforme demonstrado em exemplos em sala de aula.
 
- As telas já implementam estado de loading (`CircularProgressIndicator`) desde o início
- A transição para Supabase não vai revelar bugs de UI que só aparecem com latência real
- O comportamento async já está contratado na interface pública do repositório
 
Sem esse delay, seria fácil criar telas que assumem dados instantâneos e quebram ao conectar numa API real.
 
### 4.4 Interface pública planejada para Supabase
 
Os métodos públicos foram desenhados para mapear diretamente a operações no Supabase, sem necessidade de refatorar as telas:
 
| Método | Mock atual | Supabase futuro |
|---|---|---|
| `getMedicationsForToday()` | Retorna lista em memória | `SELECT` com filtro de horário |
| `getMedicationsForDay(date)` | Filtra por dia da semana | `SELECT` com join em schedules |
| `addMedication(medication)` | Adiciona na lista local | `INSERT` em medications + schedules |
| `removeMedication(id)` | Remove da lista local | `DELETE` em cascade |
| `updateStatus(id, status)` | Altera campo na lista | `UPDATE` em schedules |
 
---

## 5. Decisões nas Pages
 
### 5.1 Uma tela por arquivo
 
Cada arquivo em `pages/` corresponde a exatamente uma tela com uma função clara. Nenhuma tela conhece a implementação interna de outra. A comunicação acontece via parâmetros de construtor e valores de retorno da navegação.
 
> **Trade-off:** componentes visuais repetidos entre telas (chips, cards, inputs) ficam duplicados até serem extraídos para `widgets/`. Isso é aceitável na fase atual.
 
### 5.2 Wizard de adicionar e editar na mesma tela
 
O `MedicationWizardPage` aceita um parâmetro opcional `Medication? medication`. Se vier `null`, é modo adicionar. Se vier preenchido, os campos iniciam com os dados do remédio.
 
```dart
final Medication? medication;  
bool get isEditing => medication != null;
```
 
- Elimina duplicação: o wizard de add e o de edit teriam UI 100% idêntica
- Uma única tela a manter, testar e evoluir
- O título do header e o texto do botão final já refletem o modo corretamente
 
> **Trade-off:** se o fluxo de edição precisar de passos diferentes do de adição, a condicional fica dentro do mesmo arquivo, o que pode crescer em complexidade.
 
### 5.3 Retorno de navegação com resultado booleano
 
Quando o wizard salva e chama `Navigator.pop(true)`, a `HomePage` detecta esse retorno e recarrega a lista automaticamente.
 
```dart
final changed = await Navigator.push<bool>(context, ...);
if (changed == true) _loadMedications();
```
 
- A lista reflete imediatamente o novo remédio sem necessidade de state management externo
- Não é necessário Provider, Riverpod ou BLoC nesta fase
- Quando escalar para múltiplas telas que precisam reagir ao mesmo dado, será o momento de avaliar um state manager
 
### 5.4 `PageView` com scroll desabilitado no wizard
 
```dart
physics: const NeverScrollableScrollPhysics(),
```
 
O usuário só avança pelo botão, nunca por gesto de swipe. Essa decisão é crítica para o público idoso — um swipe acidental pularia um passo inteiro, resultando em dados incompletos ou errôneos.
 
---
## 6. Decisões de UX para Acessibilidade
 
O público principal são pessoas idosas com menor familiaridade com smartphones. Cada decisão de interface foi tomada com esse contexto em mente.
 
| Decisão | Justificativa |
|---|---|
| Fonte mínima de 16sp nos cards | Leitura confortável sem necessidade de zoom |
| Botões com padding vertical de 16–18px | Área de toque de pelo menos 56px de altura, reduzindo erros de toque impreciso |
| Máximo de 2 ações por tela | Reduz sobrecarga cognitiva — cada tela tem um objetivo claro |
| Feedback visual em todo toque | `AnimatedContainer` com 180ms dá resposta imediata sem parecer lento |
| Saudação dinâmica no header | "Bom dia / Boa tarde / Boa noite" humaniza o app e orienta o idoso no tempo |
| Strip de dias clicável | Substitui tabela de colunas por navegação visual intuitiva |
| Status em badge colorido | Tomado (verde), Pendente (laranja), Mais tarde (roxo) — cor + texto evitam ambiguidade |
| Wizard passo a passo | Uma pergunta por vez reduz a ansiedade de preencher um formulário longo |
 
---
 
## 7. Próximos Passos
 
### Curto prazo (dados ainda mockados)
 
1. `alarm_page.dart` — tela de lembrete ativo com áudio do familiar e botão OK grande
2. Extrair widgets repetidos para `widgets/` (`TimeChip`, `MedCard`, `WizardInput`)
3. Configurar `flutter_local_notifications` para agendar os alarmes com base nos schedules
 
### Médio prazo (integração Supabase)
 
1. Substituir o corpo dos métodos do `MedicationRepository` pelo cliente Supabase
2. Implementar autenticação real por telefone (OTP via Supabase Auth)
3. Upload de áudio para Supabase Storage e reprodução via URL
---
 
*Alô, Nenê! — Feito com carinho para a Dona Nenê e todas as avós do Brasil 💜*