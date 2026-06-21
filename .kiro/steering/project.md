# Logos App — Steering de Projeto

## O que é o projeto

Logos é um app de bíblia de estudos com modelo freemium:

- **Versão gratuita**: funciona 100% offline, sem login, com 3 traduções embutidas. O usuário pode fazer backup via Google Drive.
- **Versão paga**: login obrigatório, sincronização na nuvem, todas as traduções disponíveis, assistente IA para estudos.
- **Comunidade** (posts, artigos, comentários): feature planejada para versões futuras, após validação financeira do produto. Não implementar agora.

## Stack

- **Frontend**: Flutter (Dart)
- **Backend**: Firebase (sem servidor próprio)
  - Firebase Auth — autenticação
  - Cloud Firestore — dados da versão paga (comunidade, sync)
  - Firebase Storage — traduções extras para download
  - Firebase Functions — lógica server-side e chamadas à IA
  - Firebase Cloud Messaging — push notifications
- **IA**: OpenAI ou Gemini, chamados via Firebase Functions (nunca direto do app)
- **Pagamento**: RevenueCat
- **Bundle ID**: `com.wandr.logosApp`
- **Firebase project**: `wandr-logos`

## Estrutura de pacotes

```
lib/
├── config/
│   ├── app_config.dart         # configurações globais
│   ├── di/                     # injeção de dependência (Provider)
│   └── l10n/                   # internacionalização
│       └── arb/                # arquivos .arb de tradução
├── core/
│   ├── design_tokens/          # cores, espaçamentos, tipografia, tamanhos
│   ├── app_secure_storage.dart # armazenamento seguro
│   └── preferences.dart        # SharedPreferences wrapper
├── data/
│   ├── repositories/           # implementação dos repositórios (por feature)
│   └── services/               # serviços externos: Firebase, APIs (por feature)
├── domain/                     # entidades, interfaces de repositório, use cases
├── routing/
│   ├── router.dart             # configuração do GoRouter
│   └── routes.dart             # definição das rotas
├── ui/
│   ├── widgets/                # System Design — componentes reutilizáveis globais
│   └── {feature}/              # telas organizadas por feature
├── utils/                      # utilitários genéricos
├── firebase_options.dart       # gerado pelo FlutterFire CLI
└── main.dart
```

## Regras de desenvolvimento

### System Design — `lib/ui/widgets/`

Todo componente de UI reutilizável e genérico (não específico de uma feature) vai para `lib/ui/widgets/`. Sempre verificar se o componente adequado já existe antes de criar um novo.

#### Componentes disponíveis

- **`app_alert_dialog.dart`**
  Use para erros graves ou inesperados que exigem atenção imediata do usuário: falhas de servidor (ex: HTTP 500), serviços indisponíveis, ou exceções não tratadas. O diálogo bloqueia a tela e força uma decisão do usuário.

- **`app_bottom_sheet.dart`**
  Use sempre que precisar exibir um painel deslizante a partir da parte inferior da tela — seleção de opções, confirmações, formulários auxiliares, etc.

- **`app_button.dart`**
  Use para todos os botões de ação do app. Se o caso de uso exigir um comportamento que o componente ainda não suporta, atualize o componente em vez de criar um novo. **Sempre avisar o desenvolvedor ao modificar esse ou qualquer outro componente já existem para validações.**

- **`app_divider.dart`**
  Use para separar seções de conteúdo com uma linha horizontal.

- **`app_empty_state_view.dart`**
  Use quando uma lista ou área de conteúdo não tem dados para exibir, ou como reforço visual em telas de erro (complementa o `app_alert_dialog` em casos onde a tela inteira fica vazia).

- **`app_font.dart`**
  Uso interno — utilizado apenas dentro dos componentes de `app_typography.dart`. Não usar diretamente nas telas.

- **`app_scaffold.dart`**
  Use como wrapper de todas as telas do app no lugar do `Scaffold` padrão do Flutter. Oferece AppBar padronizada com título e badges de notificação, suporte a scroll aninhado (`nestedScrollable`), bottom navigation bar e FAB centralizado com label. Use `nestedScrollable: true` quando a tela tiver tabs ou listas dentro de listas.
  **Exceções — use `Scaffold` diretamente quando a tela não deve ter AppBar**, como: splash screen, onboarding, tela de login/cadastro, e telas fullscreen ou imersivas. O `app_scaffold` sempre renderiza uma AppBar, então não é adequado para essas situações.

- **`app_snack_bar.dart`**
  Use para feedback leve e não bloqueante: erros esperados (ex: campo obrigatório não preenchido), confirmações de ação (ex: "salvo com sucesso"), e alertas simples que não exigem resposta do usuário.

- **`app_text_field.dart`**
  Use para todos os campos de entrada de texto do app.

- **`app_typography.dart`**
  Use para exibir qualquer texto na tela. Nunca usar `Text` do Flutter diretamente — sempre passar pelo `app_typography` para garantir consistência tipográfica.

#### Criando novos componentes

Ao criar um widget reutilizável que não é específico de uma feature:

1. Coloque em `lib/ui/widgets/` com o nome no padrão `app_*.dart`
2. Se o componente precisar de variações de tipo/estilo, crie os tokens correspondentes em `lib/core/design_tokens/`

### Features de UI — `lib/ui/{feature}/`

Telas e widgets específicos de uma feature ficam dentro da pasta da própria feature. Exemplo:

```
lib/ui/auth/
├── login_screen.dart
└── widgets/
    └── social_login_button.dart
```

### Camada de dados

Cada feature segue o padrão interface + implementação separadas:

- `data/services/{feature}/` — interface do service (contrato)
- `data/services/{feature}Impl/` — implementação concreta (Firebase, API, etc.)
- `data/repositories/{feature}/` — interface do repositório (contrato)
- `data/repositories/{feature}Impl/` — implementação concreta, usa o service e implementa a interface do domain
- `domain/` — entidades puras e interfaces de repositório (sem dependência de Flutter ou Firebase)

Exemplo para a feature `auth`:

```
data/
├── services/
│   ├── auth/           # interface: AuthService
│   └── authImpl/       # implementação: AuthServiceImpl (usa Firebase Auth)
├── repositories/
│   ├── auth/           # interface: AuthRepository
│   └── authImpl/       # implementação: AuthRepositoryImpl (usa AuthService)
domain/
└── auth/               # entidade User, interface AuthRepository
```

### Design tokens

Sempre usar os tokens de `lib/core/design_tokens/` para cores, espaçamentos, fontes e tamanhos. Nunca usar valores hardcoded.

### Roteamento

Novas rotas são adicionadas em `lib/routing/routes.dart` e registradas em `lib/routing/router.dart` usando GoRouter.

### Internacionalização

Todos os textos visíveis ao usuário usam o sistema de l10n via arquivos `.arb` em `lib/config/l10n/arb/`. Nunca strings hardcoded na UI.

### State management

O projeto usa `Provider` para injeção de dependência e gerenciamento de estado. Novos providers são registrados no `MultiProvider` em `main.dart` ou via `config/di/`.
