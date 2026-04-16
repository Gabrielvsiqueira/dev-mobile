# Alô, Nenê! 💊

> Feito com carinho para a Dona Nenê e todas as avós do Brasil 💜

**Alô, Nenê!** é um aplicativo mobile para ajudar pessoas idosas a não esquecerem de tomar seus medicamentos. Ele combina lembretes visuais com áudios gravados pelos próprios familiares — porque ouvir a voz de quem a gente ama é mais gentil do que qualquer alarme.

---

## O que o app faz

- Cadastra medicamentos com nome, dosagem, observações e horários
- Suporta recorrência diária, semanal (por dias da semana) e por intervalo de horas
- Toca um áudio gravado pelo familiar no momento do lembrete
- Mostra os remédios do dia organizados por status: **tomado**, **pendente** e **mais tarde**
- Exibe um calendário mensal com o histórico de adesão
- Mantém um perfil simples com os dados do usuário e estatísticas

---

## Para quem foi feito

O público principal são **pessoas idosas com pouca familiaridade com smartphones**. O público secundário são os **familiares e cuidadores** que configuram os lembretes e gravam os áudios.

---

## Decisões de UI e UX

Todo o design do **Alô, Nenê!** parte de uma premissa única: o app será usado por alguém que provavelmente nunca teve intimidade com tecnologia, que pode ter dificuldade de leitura, tremor nas mãos ou simplesmente não sabe o que fazer se errar. Cada decisão abaixo existe por causa disso.

### Leitura antes de tudo

Fontes com tamanho mínimo de **16sp** em todos os cards e labels. A hierarquia tipográfica usa apenas dois pesos — regular e bold — para não criar ruído visual. Nenhum texto importante aparece em cinza claro sobre fundo branco.

### Toque generoso

Toda área interativa tem no mínimo **56px de altura**, mesmo que o ícone visível seja menor. Botões de ação principal têm padding vertical de 16–18px. O strip de dias da semana usa cartões de 52px de largura com `GestureDetector` cobrindo toda a área — não só o número.

### Uma coisa por vez

No máximo **duas ações por tela**. O wizard de cadastro usa um `PageView` com `NeverScrollableScrollPhysics` — o usuário só avança quando toca no botão "Próximo", nunca por deslize acidental. Cada passo faz uma pergunta só.

### Feedback imediato

Todo toque gera resposta visual com `AnimatedContainer` de **200ms**. O cartão do dia selecionado no strip anima a troca de cor com sombra roxa suave. Não existe ação silenciosa no app.

### Orientação no tempo

A saudação do header muda dinamicamente: **bom dia**, **boa tarde** ou **boa noite** com base no horário do dispositivo. Parece pequeno, mas para um idoso que acorda e abre o app, isso ancora a experiência no momento do dia e reforça o contexto do lembrete.

### Status sem ambiguidade

O status de cada remédio é comunicado com **cor e texto ao mesmo tempo** — nunca só um dos dois. Verde + "Tomado ✓", laranja + "Pendente", roxo + "Mais tarde". Quem tem daltonismo lê o texto. Quem tem dificuldade de leitura lê a cor. Os dois juntos eliminam qualquer dúvida.

### Paleta intencional

```
Purple principal  #7C5CBF  — ações, seleção, identidade
Purple claro      #EAE4F7  — fundos de card, estados inativos
Purple escuro     #2D1B5E  — títulos, texto de alta hierarquia
Fundo suave       #F7F4F0  — background geral (off-white quente)
```

O roxo foi escolhido por ser associado a cuidado e carinho, distante do visual frio de apps médicos tradicionais. O fundo off-white reduz o contraste agressivo do branco puro, mais confortável para leitura prolongada.

### Preservação de contexto no bottom nav

O bottom nav usa `IndexedStack` — ao trocar de aba e voltar, o estado anterior está exatamente onde foi deixado. Para um público que pode se desorientar facilmente, perder o dia selecionado ou a posição do scroll ao trocar de aba seria frustrante. O `IndexedStack` garante que nada se perde.

---

## Tecnologias

| Camada | Tecnologia | Por quê |
|---|---|---|
| Mobile | Flutter (Dart) | Um único código para iOS e Android com performance nativa |
| Arquitetura | MVVM + Repository Pattern | Separa UI, lógica e dados de forma clara e testável |
| Navegação | GoRouter | Navegação declarativa com suporte a parâmetros tipados |
| Cache local | SharedPreferences | Persistência simples entre sessões sem depender de rede |
| Backend (futuro) | Supabase (PostgreSQL + Auth + Storage) | Auth por OTP, banco relacional e storage para os áudios |

---

## Como rodar

```bash
flutter pub get
flutter run
```

---

## Estrutura do projeto

```
lib/
├── main.dart
│
├── pages/                            # View — só constrói UI
│   ├── login_page.dart               ✅ pronto
│   ├── home_page.dart                ✅ pronto
│   ├── medication_wizard_page.dart   ✅ pronto
│   ├── calendar_page.dart            ✅ pronto
│   ├── profile_page.dart             ✅ pronto
│   ├── alarm_page.dart               ✅ pronto
│   └── emergency_page.dart           ✅ pronto
│
├── viewmodels/                       # Lógica de negócio e estado
│   ├── home_view_model.dart          ✅ pronto
│   ├── wizard_view_model.dart        ✅ pronto
│   ├── calendar_view_model.dart      ✅ pronto
│   ├── profile_view_model.dart       ✅ pronto
│   ├── alarm_view_model.dart         ✅ pronto
│   ├── emergency_view_model.dart     ✅ pronto
│   └── login_view_model.dart         ✅ pronto
│
├── model/
│   └── medication.dart               ✅ pronto
│
├── repository/
│   └── medication_repository.dart    ✅ pronto — mockado, pronto para Supabase
│
├── widgets/                          # Componentes reutilizáveis entre telas
│   ├── medication_card.dart          ✅ pronto
│   ├── history_card.dart             ✅ pronto
│   ├── stat_card.dart                ✅ pronto
│   ├── contact_card.dart             ✅ pronto
│   ├── wizard_steps.dart             ✅ pronto
│   └── app_bottom_nav.dart           ✅ pronto
│
└── routes/
    └── app_router.dart               ✅ pronto
```

---

## Como as decisões foram tomadas

**MVVM foi adotado** quando as `pages` começaram a crescer com lógica de carregamento, validações e estado de loading misturados à UI. Separar em ViewModels deixou cada arquivo com uma responsabilidade única: a page constrói widgets, o ViewModel sabe o que mostrar. O binding é feito com `ChangeNotifier` e `ListenableBuilder` — sem biblioteca externa de estado.

**O Repository Pattern** garante que nenhum ViewModel saiba de onde os dados vêm. Hoje os métodos retornam dados mockados em memória com um `Future.delayed` simulando latência de rede. Quando o Supabase entrar, apenas o corpo desses métodos muda — as telas e os ViewModels não tocam em nada.

**O wizard de cadastro é unificado** para add e edit. Um parâmetro `Medication?` opcional define o modo: `null` abre em branco, não-nulo preenche os campos. Isso evita duplicar quatro telas de formulário.

**O `AppSession`** é uma classe estática simples que carrega nome e telefone do usuário entre telas, sem precisar passar parâmetros pela árvore de navegação. Quando o Supabase Auth entrar, ele será substituído pelo objeto de sessão nativo.

**O `IndexedStack` no bottom nav** preserva o estado de cada aba ao navegar. Se o usuário estava no dia 10 do Calendário e voltou para o Início, ao retornar ao Calendário o dia 10 ainda estará selecionado — comportamento importante para um público que pode se desorientar ao perder contexto.

---

## Modelo de dados

O arquivo `medication.dart` concentra todas as definições de domínio: as classes `Medication` e `MedicationSchedule`, e os enums `MedicationStatus` e `RecurrenceType`. Ficam juntas porque são inseparáveis — você nunca busca um remédio sem seus agendamentos, e os enums existem exclusivamente para tipar campos dessas classes.

| Tipo | Responsabilidade |
|---|---|
| `Medication` | Nome, dosagem, observações, URL do áudio e lista de agendamentos |
| `MedicationSchedule` | Horário, tipo de recorrência, dias da semana, intervalo em horas e status |
| `MedicationStatus` | `taken` · `pending` · `upcoming` |
| `RecurrenceType` | `daily` · `weekly` · `interval` |

---

## Próximos passos

**Curto prazo**
- Agendar alarmes locais com `flutter_local_notifications` a partir dos schedules cadastrados
- Reprodução do áudio gravado na tela de alarme

**Médio prazo**
- Substituir o repositório mockado pela integração com Supabase
- Autenticação por OTP via Supabase Auth — substituindo o `AppSession` estático
- Upload e reprodução de áudio via Supabase Storage

---

## Desenvolvedores

| Nome |
|---|
| Gabriel Vitor Siqueira |
| Lucas Gonçalves Padilha |