# Alô, Nenê! - Decisões de Arquitetura

Este documento registra todas as decisões técnicas e de arquitetura tomadas durante o desenvolvimento do **Alô, Nenê!**, um lembrete de medicamentos para pessoas idosas. Cada decisão é acompanhada de contexto, motivação e trade-offs conhecidos.

## 1. Definição

É um aplicativo mobile desenvolvido em Flutter, desenhado para ajudar pessoas idosas a se lembrarem de tomar seus medicamentos diários. O aplicativo combina lembretes com áudio gravado por familiares, interfaces de usuários acessíveis e suporte a múltiplos tipos de recorrência.

- **Público-alvo principal:** pessoas idosas com pouca familiaridade com tecnologia
- **Público-alvo secundário:** familiares e cuidadores que configuram os lembretes remotamente

### 1.1 Stacks

| Camada | Tecnologia | Motivo da escolha |
|---|---|---|
| Frontend | Flutter (Dart) | Único código para iOS e Android com performance nativa |
| Arquitetura | MVVM + Repository Pattern | Separação clara entre UI, lógica e dados |

---

## 2. Estrutura de Pastas

O projeto segue a arquitetura **MVVM (Model-View-ViewModel)** dentro de `lib/`, com o **Repository Pattern** como camada de acesso a dados. Cada pasta tem uma responsabilidade única e bem definida, seguindo os conceitos de UDF (**Unidirectional Data Flow**).

```
lib/
├── main.dart
│
├── pages/               ← View: UI e navegação
│   ├── login_page.dart
│   ├── home_page.dart
│   ├── medication_wizard_page.dart
│   ├── calendar_page.dart
│   ├── profile_page.dart
│   ├── alarm_page.dart
│   └── emergency_page.dart
│
├── viewmodels/          ← ViewModel: estado e lógica de negócio
│   ├── home_view_model.dart
│   ├── wizard_view_model.dart
│   ├── calendar_view_model.dart
│   ├── profile_view_model.dart
│   ├── alarm_view_model.dart
│   ├── emergency_view_model.dart
│   └── login_view_model.dart
│
├── model/               ← Model: entidades de domínio
│   └── medication.dart
│
├── repository/          ← Acesso a dados
│   └── medication_repository.dart
│
├── widgets/             ← Componentes visuais reutilizáveis
│   ├── medication_card.dart
│   ├── history_card.dart
│   ├── stat_card.dart
│   ├── contact_card.dart
│   ├── wizard_steps.dart
│   └── app_bottom_nav.dart
│
└── routes/              ← Configuração de navegação
    └── app_router.dart
```

| Arquivo | Responsabilidade | Status |
|---|---|---|
| `main.dart` | Ponto de entrada, inicialização do tema e rota inicial | ✅ Pronto |
| `pages/login_page.dart` | Coleta nome e telefone do usuário. Persiste em `AppSession`. Navega para `HomePage`. | ✅ Pronto |
| `pages/home_page.dart` | Exibe lista de remédios do dia, strip de datas e botões de ação | ✅ Pronto |
| `pages/medication_wizard_page.dart` | Wizard de 4 passos para adicionar ou editar medicamento | ✅ Pronto |
| `pages/calendar_page.dart` | Visão mensal do histórico de medicações | ✅ Pronto |
| `pages/profile_page.dart` | Dados do usuário, estatísticas e ações de conta | ✅ Pronto |
| `pages/alarm_page.dart` | Tela de lembrete ativo com confirmação de tomada | ✅ Pronto |
| `pages/emergency_page.dart` | Contatos de emergência e acesso rápido | ✅ Pronto |
| `viewmodels/home_view_model.dart` | Estado da home: lista de medicamentos do dia e de todos, data selecionada | ✅ Pronto |
| `viewmodels/wizard_view_model.dart` | Estado do wizard: campos, steps, modo add/edit, save e delete | ✅ Pronto |
| `viewmodels/calendar_view_model.dart` | Estado do calendário: mês selecionado, histórico por dia | ✅ Pronto |
| `viewmodels/profile_view_model.dart` | Estado do perfil: contagem de remédios, modo de edição | ✅ Pronto |
| `viewmodels/alarm_view_model.dart` | Estado do alarme: status de tomada | ✅ Pronto |
| `viewmodels/emergency_view_model.dart` | Estado dos contatos de emergência | ✅ Pronto |
| `viewmodels/login_view_model.dart` | Estado do login: loading, validação de nome | ✅ Pronto |
| `model/medication.dart` | Classes `Medication`, `MedicationSchedule` e enums de status e recorrência | ✅ Pronto |
| `repository/medication_repository.dart` | Dados mockados em memória. Interface pública que será substituída pelo Supabase. | ✅ Pronto |
| `routes/app_router.dart` | Configuração do GoRouter, rotas nomeadas e `AppSession` | ✅ Pronto |

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

---

## 4. MVVM

### 4.1 Por que adotar MVVM?

O projeto iniciou com lógica de negócio diretamente nas `pages`. À medida que as telas cresceram, ficou evidente que responsabilidades como carregamento de dados, estado de loading e validações tornavam as `pages` difíceis de manter.

O **MVVM** separa essas responsabilidades em três camadas:

- **Model** — entidades de domínio (`model/`)
- **View** — apenas UI e resposta a eventos (`pages/`)
- **ViewModel** — estado da tela, lógica de negócio e chamadas ao repositório (`viewmodels/`)

```
View (Page)  →  notifica evento  →  ViewModel
ViewModel    →  chama           →  Repository
Repository   →  retorna dados   →  ViewModel
ViewModel    →  notifyListeners →  View re-renderiza
```

### 4.2 Como o binding é feito?

Cada ViewModel estende `ChangeNotifier`. As pages usam `ListenableBuilder` para re-renderizar automaticamente quando o estado muda:

```dart
ListenableBuilder(
  listenable: _viewModel,
  builder: (context, _) => ...,
)
```

Isso garante que a UI só re-renderiza quando o ViewModel emite `notifyListeners()`.

### 4.3 Trade-offs

| Vantagem | Desvantagem |
|---|---|
| Pages ficam limpas — só constroem UI | Um arquivo de ViewModel por tela |
| Lógica testável sem dependência de Flutter | Mais arquivos no projeto |
| Fácil trocar a fonte de dados sem tocar a UI | ChangeNotifier não é thread-safe por padrão |

---

## 5. Repository

### 5.1 Por que manter o Repository Pattern?

Com MVVM, o Repository continua sendo a camada de acesso a dados. Os ViewModels chamam o repositório diretamente — as `pages` nunca sabem de onde os dados vêm.

**Benefício principal:** quando o backend mudar de mockado para Supabase, apenas o corpo dos métodos do repositório muda. Nenhum ViewModel nem nenhuma tela precisa ser alterada.

> **Trade-off:** adiciona um nível de indireção. A justificativa é a clareza de onde buscar dados quando o projeto escalar.

### 5.2 Por que Singleton?

O `MedicationRepository` usa uma lista estática em memória como fonte de dados mockada. A instância é única (`static final List<Medication> _medications`), garantindo consistência entre ViewModels de telas diferentes.

- Se a `HomePage` adicionar um remédio pelo wizard, a lista atualizada aparece em qualquer outra tela que recarregar
- Quando integrar o Supabase, o Singleton deixará de ser necessário — o cliente Supabase gerencia a própria conexão

### 5.3 Por que `Future.delayed` nos métodos mockados?

Todos os métodos retornam `Future<T>` com um `Future.delayed` simulando latência de rede (200–400ms).

- Os ViewModels já implementam estado de loading desde o início
- A transição para Supabase não revelará bugs de UI que só aparecem com latência real
- O comportamento async já está contratado na interface pública do repositório

### 5.4 Interface pública planejada para Supabase

| Método | Mock atual | Supabase futuro |
|---|---|---|
| `getAllMedications()` | Retorna lista completa em memória | `SELECT` sem filtro |
| `getMedicationsForDay(date)` | Filtra por dia da semana | `SELECT` com join em schedules |
| `addMedication(medication)` | Adiciona na lista local | `INSERT` em medications + schedules |
| `removeMedication(id)` | Remove da lista local | `DELETE` em cascade |
| `updateMedication(medication)` | Substitui item na lista | `UPDATE` em medications + schedules |
| `updateStatus(id, status)` | Altera campo na lista | `UPDATE` em schedules |

---

## 6. Widgets

### 6.1 Por que extrair para `widgets/`?

À medida que as telas foram criadas, componentes visuais idênticos apareceram em múltiplos lugares. Extraí-los evita duplicação e garante consistência visual.

| Widget | Usado em |
|---|---|
| `MedicationCard` | `home_page`, `calendar_page` |
| `HistoryCard` | `calendar_page` |
| `StatCard` | `profile_page` |
| `ContactCard` | `emergency_page` |
| `WizardSteps` | `medication_wizard_page` |
| `AppBottomNav` | Todas as telas principais |

### 6.2 Regra de extração

Um componente é extraído para `widgets/` quando:
1. Aparece em mais de uma tela, **ou**
2. Tem lógica de layout suficientemente complexa para justificar isolamento

---

## 7. Navegação

### 7.1 GoRouter

O app usa `go_router` para navegação declarativa. Todas as rotas são centralizadas em `routes/app_router.dart`.

```dart
class AppRoutes {
  static const login    = '/';
  static const home     = '/home';
  static const wizardAdd  = '/medication/add';
  static const wizardEdit = '/medication/edit';
  static const calendar = '/calendar';
  static const profile  = '/profile';
  static const alarm    = '/alarm';
  static const emergency = '/emergency';
}
```

### 7.2 AppSession

O `AppSession` é uma classe estática que armazena dados de sessão do usuário (nome e telefone) entre telas, sem necessidade de passar parâmetros por toda a árvore de navegação.

```dart
class AppSession {
  static String userName = '';
  static String userPhone = '';
}
```

> **Quando evoluir:** ao integrar Supabase Auth, `AppSession` será substituído pelo objeto de sessão do Supabase.

### 7.3 Retorno de navegação com resultado booleano

O wizard retorna `true` ao salvar. As telas que o abrem detectam esse retorno e recarregam a lista:

```dart
final changed = await context.push<bool>(AppRoutes.wizardAdd);
if (changed == true) _viewModel.reload();
```

---

## 8. Decisões de UX para Acessibilidade

O público principal são pessoas idosas com menor familiaridade com smartphones. Cada decisão de interface foi tomada com esse contexto em mente.

| Decisão | Justificativa |
|---|---|
| Fonte mínima de 16sp nos cards | Leitura confortável sem necessidade de zoom |
| Botões com padding vertical de 16–18px | Área de toque de pelo menos 56px, reduzindo erros de toque impreciso |
| Máximo de 2 ações por tela | Reduz sobrecarga cognitiva |
| Feedback visual em todo toque | `AnimatedContainer` com 200ms dá resposta imediata |
| Saudação dinâmica no header | "Bom dia / Boa tarde / Boa noite" orienta o idoso no tempo |
| Strip de dias clicável | Navegação visual intuitiva entre dias da semana |
| Status em badge colorido | Tomado (verde), Pendente (laranja), Mais tarde (roxo) — cor + texto evitam ambiguidade |
| Wizard passo a passo | Uma pergunta por vez reduz a ansiedade de preencher formulário longo |
| Scroll desabilitado no wizard | Impede swipe acidental que pularia um passo |

---

## 9. Próximos Passos

### Curto prazo (dados ainda mockados)

1. Configurar `flutter_local_notifications` para agendar alarmes com base nos schedules
2. Implementar reprodução de áudio na `alarm_page`

### Médio prazo (integração Supabase)

1. Substituir o corpo dos métodos do `MedicationRepository` pelo cliente Supabase
2. Implementar autenticação real por telefone (OTP via Supabase Auth) — substituindo `AppSession`
3. Upload de áudio para Supabase Storage e reprodução via URL

---

*Alô, Nenê! — Feito com carinho para a Dona Nenê e todas as avós do Brasil 💜*
