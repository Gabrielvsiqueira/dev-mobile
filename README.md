# Alô, Nenê!

É um aplicativo mobile desenvolvido em Flutter desenhado para ajudar pessoas idosas a se lembrarem de tomar seus medicamentos diários. O aplicativo combina lembretes com áudio gravado por familiares, interfaces de usuários acessíveis e suporte a múltiplos tipos de recorrência.

---

## Sobre o projeto

O **Alô, Nenê!** combina lembretes de medicação com:

- Áudio gravado por familiares  
- Interface simplificada e acessível  
- Suporte a múltiplos tipos de recorrência  

### Público-alvo

- 👵 Idosos com pouca familiaridade com tecnologia  
- 👨‍👩‍👧 Familiares e cuidadores  

---

### 1.1 Tecnologias

| Camada | Tecnologia |
|---|---|
| Frontend | Flutter (Dart) |
| Arquitetura | MVVM (Model-View-ViewModel) |

---

### 2. Arquitetura

| Pasta | Responsabilidade |
|---|---|
| `pages/` | UI e navegação (View) |
| `viewmodels/` | Estado e lógica de negócio (ViewModel) |
| `model/` | Domínio e entidades (Model) |
| `repository/` | Acesso aos dados |
| `widgets/` | Componentes visuais reutilizáveis |
| `routes/` | Configuração de navegação |

### 2.1 Principais decisões

- Uso de **MVVM** para separar lógica de negócio da UI  
- **Repository Pattern** mantido como camada de acesso a dados  
- Fluxo unidirecional de dados (UDF) via `ChangeNotifier`  
- Wizard único para criação e edição de medicamentos  
- Foco em UX acessível para idosos  

- **Arquitetura detalhada** → /lib/docs/architeture.md
- **Decisões técnicas (ADRs)** → /lib/docs/adr/

---

## 3. Estrutura de Pastas

```
lib/
├── main.dart
│
├── pages/
│   ├── login_page.dart               ✅ pronto
│   ├── home_page.dart                ✅ pronto
│   ├── medication_wizard_page.dart   ✅ pronto
│   ├── calendar_page.dart            ✅ pronto
│   ├── profile_page.dart             ✅ pronto
│   ├── alarm_page.dart               ✅ pronto
│   └── emergency_page.dart           ✅ pronto
│
├── viewmodels/
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
│   └── medication_repository.dart    ✅ pronto (mockado → Supabase depois)
│
├── widgets/
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

## 4. Como rodar o projeto

```bash
flutter pub get
flutter run
```

## 5. Desenvolvedores
| Nomes |
|---|
| Gabriel Vitor Siqueira |
| Lucas Gonçalves Padilha |
