# 🎨 Common Components Module

Componentes, utilitários e constantes compartilhadas entre todos os aplicativos.

## 📋 Estrutura

```
common/
├── components/
│   ├── buttons/
│   │   ├── primary_button.dart
│   │   └── secondary_button.dart
│   ├── inputs/
│   │   └── text_field.dart
│   ├── dialogs/
│   │   └── loading_dialog.dart
│   └── app_bar/
│       └── custom_app_bar.dart
├── utilities/
│   ├── validators/
│   │   ├── email_validator.dart
│   │   └── password_validator.dart
│   ├── extensions/
│   │   ├── string_extensions.dart
│   │   └── date_extensions.dart
│   └── formatters/
│       ├── currency_formatter.dart
│       └── date_formatter.dart
├── constants/
│   ├── app_constants.dart
│   ├── api_constants.dart
│   └── colors.dart
└── helpers/
    ├── logger_helper.dart
    └── navigation_helper.dart
```

## 🎯 Componentes Planejados

### Buttons
- `PrimaryButton` - Botão principal
- `SecondaryButton` - Botão secundário
- `IconButton` - Botão com ícone

### Inputs
- `AppTextField` - Campo de texto
- `PasswordField` - Campo de senha
- `CurrencyField` - Campo monetário

### Dialogs
- `LoadingDialog` - Dialog de carregamento
- `ConfirmDialog` - Dialog de confirmação

### App Bar
- `CustomAppBar` - App bar customizada

## 📚 Constantes

```dart
// App
const String APP_NAME = 'ERP Apps';
const String APP_VERSION = '1.0.0';

// API
const String API_BASE_URL = 'https://api.erp.com';
const Duration API_TIMEOUT = Duration(seconds: 30);

// Colors
const Color PRIMARY_COLOR = Color(0xFF6200EE);
const Color ERROR_COLOR = Color(0xFFB00020);
```

## 🛠️ Utilitários

### Validators

```dart
// Email
if (isValidEmail(email)) {
  // OK
}

// Password
if (isValidPassword(password)) {
  // OK
}
```

### Formatters

```dart
// Currency
final formatted = formatCurrency(1234.56); // R$ 1.234,56

// Date
final formatted = formatDate(DateTime.now()); // 06/05/2026
```

### Extensions

```dart
// String
'  hello  '.trimAll(); // 'hello'

// Date
DateTime.now().isToday(); // true
```

## 🚀 Próximos Passos

- [ ] Implementar Buttons
- [ ] Implementar Inputs
- [ ] Implementar Dialogs
- [ ] Criar Validators
- [ ] Criar Formatters
- [ ] Adicionar Extensions
- [ ] Definir Colors & Themes

---

**Status**: Em desenvolvimento
