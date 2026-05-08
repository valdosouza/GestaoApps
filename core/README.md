# 📦 Core Module

Módulo core compartilhado contendo funcionalidades comuns para todos os aplicativos ERP.

## 📋 Conteúdo

### 🔐 Auth Module (`src/auth/`)

Gerenciamento de autenticação, login, registro e autorização.

**Estrutura**:
- **Domain**: Entidades, repositories abstratos e use cases
- **Data**: Data sources locais/remotas, modelos e implementação de repositories
- **Presentation**: Estados (Cubit) e widgets (em desenvolvimento)

**Uso básico**:

```dart
import 'package:core/core.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

// Setup
await setupCoreInjection();

// Usar
final loginUseCase = getIt<LoginUseCase>();
final result = await loginUseCase(
  email: 'user@example.com',
  password: 'password123',
);

result.fold(
  (failure) => print('Erro: ${failure.message}'),
  (user) => print('Login bem-sucedido: ${user.name}'),
);
```

### 🌐 ERP Integration Module (`src/erp_integration/`)

*Em desenvolvimento*

Integração com APIs do ERP para:
- Sincronização de produtos
- Gerenciamento de clientes
- Busca de dados

### 🎨 Common Components (`src/common/`)

*Em desenvolvimento*

Componentes reutilizáveis:
- Widgets
- Utilitários
- Constantes
- Helpers

### ⚙️ Core Module (`src/core/`)

Infraestrutura básica:
- **Error Handling**: Classes de falha
- **DI**: Configuração de injeção de dependência
- **Interceptors**: Middleware HTTP
- **Theme**: Temas da aplicação

## 🚀 Como Usar em um App

### 1. Adicionar como Dependência

No `pubspec.yaml` do app:

```yaml
dependencies:
  core:
    path: ../../core
```

### 2. Setup Inicial

No `main.dart`:

```dart
import 'package:core/core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Setup dependências do core
  await setupCoreInjection();
  
  // Setup do app
  setupAppInjection();
  
  runApp(const MyApp());
}
```

### 3. Usar Funcionalidades

```dart
import 'package:core/core.dart';
import 'package:get_it/get_it.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final loginUseCase = GetIt.instance<LoginUseCase>();
    
    // Usar o use case
    ...
  }
}
```

## 📚 Estrutura Técnica

### Clean Architecture

Cada módulo segue a divisão:

```
module/
├── domain/          # Regras de negócio
│   ├── entities/    # Entidades
│   ├── repositories/ # Contratos
│   └── usecases/    # Operações
├── data/            # Implementação
│   ├── datasources/ # Fontes de dados
│   ├── models/      # Modelos (JSON)
│   └── repositories/ # Implementação
└── presentation/    # UI (cubits, widgets)
```

### Padrões

- **Equatable**: Comparação de objetos
- **Dartz**: Either<Failure, Success> para tratamento de erros
- **GetIt**: Service locator para DI
- **Shared Preferences**: Cache local
- **JSON Serializable**: Serialização automática

## 🧪 Testes

```bash
# Executar testes do core
flutter test

# Com coverage
flutter test --coverage
```

## 🔄 Dependências

```yaml
flutter:
  sdk: flutter

# DI
get_it: ^8.3.0
injectable: ^2.7.1

# State & Functional
bloc: ^8.1.4
equatable: ^2.0.8
dartz: ^0.10.1

# Data
shared_preferences: ^2.5.3
http: ^1.6.0

# Code Generation
json_serializable: ^6.11.2
build_runner: ^2.11.1
```

## 📝 Próximos Passos

- [ ] Implementar ERP Integration completo
- [ ] Adicionar Cubits/BLoCs para Auth
- [ ] Criar Common Components
- [ ] Setup de Temas
- [ ] Interceptors HTTP
- [ ] Documentação de uso

---

**Desenvolvido com ❤️ para a plataforma ERP**
