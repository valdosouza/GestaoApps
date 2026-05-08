# 📚 Core Exports Guide

## O que foi atualizado?

O arquivo `core/lib/core.dart` agora exporta **todos os módulos migrados** de forma centralizada.

---

## 📦 **Módulos Exportados**

### 1. 🎬 **SPLASH Module**
```dart
import 'package:core/core.dart';

// Usar
final splashBloc = SplashBloc();
final event = SplashInitEvent();
final state = LoadingState();
final page = const SplashPage();
```

**Exports:**
- Domain: `splash_respository.dart`, `get_authorization.dart`
- Data: `splash_datasource.dart`, `splash_repository_impl.dart`
- Presentation: `splash_bloc.dart`, `splash_event.dart`, `splash_state.dart`, `splash_page.dart`
- Module: `splash_module.dart`

---

### 2. 🔐 **AUTH Module**
```dart
import 'package:core/core.dart';

// Usar entidades
final user = AuthEntity(...);
final model = AuthModel.fromJson(json);

// Usar repositories
final repo = AuthRepositoryImpl(...);

// Usar use cases
final login = LoginEmailUseCase(...);

// Usar BLoCs
final authBloc = AuthBloc(...);

// Usar pages
final page = AuthPage();
final form = AuthForm();
final serverConfig = ServerIpPage();
```

**Exports:**
- Domain: 3 entities + 1 repository + 3 use cases
- Data: 3 models + 2 datasources + 1 repository impl
- Presentation: 1 bloc + 3 pages
- Module: `auth_module.dart`

---

### 3. 🎨 **THEME Module**
```dart
import 'package:core/core.dart';

// Usar temas
final theme = AppTheme.budgetSales();
final themeData = theme.getThemeData();

// Usar cores
Container(
  color: AppColors.primaryBlue,
  child: Text('Hello'),
)
```

**Exports:**
- `app_theme.dart` - Temas por app
- `app_colors.dart` - Cores padronizadas

---

### 4. ⚙️ **CORE Module**
```dart
import 'package:core/core.dart';

// DI
await setupCoreInjection();

// Error handling
try {
  // ...
} catch (e) {
  final failure = Failure(message: 'Erro', code: 'ERROR_CODE');
}
```

**Exports:**
- `injection_container.dart` - Setup de DI
- `failure.dart` - Classes de erro

---

## 🎯 **Como Usar nos Apps**

### Em `budget_sales/lib/app.dart`:
```dart
import 'package:core/core.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appTheme = AppTheme.budgetSales();
    
    return MaterialApp(
      title: 'Budget Sales',
      theme: appTheme.getThemeData(),
      home: const SplashPage(), // Direto do core
    );
  }
}
```

### Em qualquer widget:
```dart
import 'package:core/core.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryBlue, // Do core
      child: BlocBuilder<AuthBloc, AuthState>( // Do core
        builder: (context, state) {
          if (state is AuthorizedState) {
            return const SplashPage(); // Do core
          }
          return Container();
        },
      ),
    );
  }
}
```

---

## 📋 **Lista Completa de Exports**

### SPLASH (5 exports)
- `splash_respository.dart`
- `get_authorization.dart`
- `splash_datasource.dart`
- `splash_repository_impl.dart`
- `splash_bloc.dart`
- `splash_event.dart`
- `splash_state.dart`
- `splash_page.dart`
- `splash_module.dart`

### AUTH (14 exports)
- **Entities**: `auth_entity.dart`, `auth_change_password_entity.dart`, `auth_recovery_password_entity.dart`
- **Repository**: `auth_repository.dart`
- **UseCases**: `login_email.dart`, `change_password.dart`, `recovery_password.dart`
- **Models**: `auth_model.dart`, `auth_change_password_model.dart`, `auth_recovery_password_model.dart`
- **DataSources**: `auth_local_datasource.dart`, `auth_datasource.dart`
- **RepositoryImpl**: `auth_repository_impl.dart`
- **BLoC**: `auth_bloc.dart`, `auth_event.dart`, `auth_state.dart`
- **Pages**: `auth_page.dart`, `auth_form.dart`, `server_ip_page.dart`
- **Module**: `auth_module.dart`

### THEME (2 exports)
- `app_theme.dart`
- `app_colors.dart`

### CORE (2 exports)
- `injection_container.dart`
- `failure.dart`

---

## ✨ **Benefícios**

✅ **Um único import** - `import 'package:core/core.dart';`  
✅ **Acesso a tudo** - Splash, Auth, Theme, Core em um só lugar  
✅ **Manutenção centralizada** - Novos exports vão aqui  
✅ **Consistência** - Todos os apps usam o mesmo padrão  
✅ **Produtividade** - Menos digitação, menos erros  

---

## 📍 **Localização**

**Arquivo**: `D:\GestaoERPApps\core\lib\core.dart`

```dart
library core;

// ===== SPLASH MODULE =====
// ... 9 exports

// ===== AUTH MODULE =====
// ... 20 exports

// ===== THEME MODULE =====
// ... 2 exports

// ===== CORE MODULE =====
// ... 2 exports

// TOTAL: 33 exports
```

---

## 🚀 **Próximo Passo**

Agora você pode:
1. Importar do core em qualquer lugar
2. Usar Splash, Auth, Themes diretamente
3. Adicionar novos módulos conforme necessário

**Exemplo completo:**
```dart
import 'package:core/core.dart';

void main() async {
  await setupCoreInjection();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.budgetSales().getThemeData(),
      home: const SplashPage(),
    );
  }
}
```

---

**Core exports centralizados e prontos! 📚✨**
