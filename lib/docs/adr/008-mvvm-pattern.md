# 008 - Adoção do MVVM

## Status
Aceito

## Contexto
O projeto iniciou com lógica de negócio diretamente nas `pages`. À medida que as telas cresceram (home, wizard, calendar, profile, alarm, emergency), ficou evidente que:

- As `pages` acumulavam responsabilidades de UI, estado e acesso a dados
- Código de carregamento, loading state e validações estava duplicado entre telas
- Testar comportamentos exigia instanciar widgets Flutter completos

## Decisão
Adotar **MVVM (Model-View-ViewModel)** como padrão arquitetural principal, com os seguintes papéis:

- **View (pages/)** — constrói a UI e delega eventos ao ViewModel. Nunca acessa o repositório.
- **ViewModel (viewmodels/)** — mantém o estado da tela, executa lógica de negócio e chama o repositório. Estende `ChangeNotifier`.
- **Model (model/)** — entidades de domínio puras, sem dependência de Flutter.

O binding é feito via `ListenableBuilder`, que re-renderiza a UI somente quando o ViewModel emite `notifyListeners()`.

## Alternativas consideradas

| Alternativa | Motivo de não adotar |
|---|---|
| Provider / Riverpod | Overhead desnecessário para o tamanho atual do projeto |
| BLoC | Curva de aprendizado maior sem ganho proporcional nesta fase |
| setState puro | Não escala — lógica ficaria presa nos widgets |

## Consequências
✅ Pages focadas exclusivamente em UI  
✅ ViewModels testáveis sem depender do Flutter  
✅ Estado centralizado por tela — sem setState espalhado  
✅ Fácil evolução para Riverpod ou outro gerenciador se necessário  
❌ Um arquivo ViewModel por tela aumenta o número de arquivos  
❌ `ChangeNotifier` não é thread-safe por padrão
