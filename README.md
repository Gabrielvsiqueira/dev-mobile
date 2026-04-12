# Alo, Nenê!

É um aplicativo mobile desenvolvido  em Flutter desenhado para ajudar pessoas idosas a se lembrarem de tomar seus medicamentos diarios. O aplicativo combina lembretes com audio gravado por familiares, interfaces de usuários acessíveis e suporte a multiplos tipos de recorrencia.

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

|---|---|
| Frontend | Flutter (Dart) | 
| Arquitetura | Baeada em Repository Pattern | 

---

### 2. Arquitetura
O projeto segue uma arquitetura em camadas com separação clara de responsabilidades:

|---|---|
| pages | UI | 
| model | dominio | 
| repository | acesso aos dados | 

### 2.1 Principais decisões

- Uso de **Repository Pattern** para desacoplar dados  
- Fluxo unidirecional de dados (UDF)  
- Wizard único para criação e edição de medicamentos  
- Foco em UX acessível para idosos  

- **Arquitetura detalhada** → /docs/architecture.md
- **Decisões técnicas (ADRs)** → /docs/adr/

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
│
├── model/
│   └── medication.dart               ✅ pronto
│
└── repository/
    └── medication_repository.dart    ✅ pronto (mockado → Supabase depois)
```

---

## 4. Como rodar o projeto

```bash
flutter pub get
flutter run