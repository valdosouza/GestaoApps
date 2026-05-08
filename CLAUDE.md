# 📚 CLAUDE.md - Documentação do Codebase

## 🎯 Visão Geral

Este arquivo documenta a arquitetura, estrutura de código, padrões e convenções do projeto **Apps para ERP**.

**Última atualização**: 2026-05-06
**Versão**: 1.0.0

---

## 🏗️ Arquitetura

### Clean Architecture

A estrutura segue **Clean Architecture**, separando o código em camadas:

```
┌──────────────────────────────────────────┐
│     Presentation Layer (UI)              │
│  ├─ Widgets                              │
│  ├─ Pages                                │
│  └─ Controllers (BLoC/Cubit)             │
├──────────────────────────────────────────┤
│     Business Logic Layer                 │
│  ├─ Use Cases                            │
│  ├─ Entities                             │
│  └─ Services                             │
├──────────────────────────────────────────┤
│     Data Layer                           │
│  ├─ Repositories                         │
│  ├─ Data Sources (Local/Remote)          │
│  └─ Models                               │
└──────────────────────────────────────────┘
```

### Benefícios

✅ Separação de responsabilidades  
✅ Testabilidade  
✅ Escalabilidade  
✅ Manutenibilidade  
✅ Reusabilidade de código  

---

## 📂 Estrutura de Pastas - Core

```
core/
├── lib/
│   ├── src/
│   │   ├── auth/                    # Autenticação
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   ├── repositories/
│   │   │   │   └── usecases/
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   ├── models/
│   │   │   │   └── repositories/
│   │   │   └── presentation/
│   │   │       ├── cubit/
│   │   │       └── widgets/
│   │   │
│   │   ├── erp_integration/         # Integração com ERP
│   │   │   ├── domain/
│   │   │   ├── data/
│   │   │   └── presentation/
│   │   │
│   │   ├── common/                  # Componentes comuns
│   │   │   ├── components/
│   │   │   ├── utilities/
│   │   │   ├── constants/
│   │   │   └── helpers/
│   │   │
│   │   └── core/                    # Núcleo
│   │       ├── di/                  # Dependency Injection
│   │       ├── exceptions/
│   │       ├── interceptors/
│   │       ├── theme/
│   │       └── error/
│   │
│   └── core.dart                    # Main export
│
├── test/
├── pubspec.yaml
└── analysis_options.yaml
```

### Estrutura de Pastas - Apps

```
apps/budget_sales/
├── lib/
│   ├── main.dart                    # Ponto de entrada
│   ├── app.dart                     # Configuração do App
│   ├── src/
│   │   ├── features/
│   │   │   └── orcamento/
│   │   │       ├── domain/
│   │   │       ├── data/
│   │   │       └── presentation/
│   │   ├── config/
│   │   │   ├── routes/
│   │   │   └── theme/
│   │   └── di/
│   │       └── injection_container.dart
│   │
├── test/
├── pubspec.yaml
└── analysis_options.yaml
```

---

## 📦 Módulos

### 1. **Auth Module** (core/src/auth/)

Gerencia autenticação e autorização.

**Responsabilidades**:
- Login/Logout
- Registro de usuários
- Armazenamento de tokens
- Renovação de sessão
- Recuperação de senha

**Estrutura**:
```
auth/
├── domain/
│   ├── entities/
│   │   └── user.dart
│   ├── repositories/
│   │   └── auth_repository.dart
│   └── usecases/
│       ├── login.dart
│       ├── logout.dart
│       └── get_current_user.dart
├── data/
│   ├── datasources/
│   │   ├── auth_local_datasource.dart
│   │   └── auth_remote_datasource.dart
│   ├── models/
│   │   └── user_model.dart
│   └── repositories/
│       └── auth_repository_impl.dart
└── presentation/
    ├── cubit/
    │   ├── auth_cubit.dart
    │   └── auth_state.dart
    └── widgets/
        ├── login_form.dart
        └── signup_form.dart
```

### 2. **ERP Integration Module** (core/src/erp_integration/)

Integração com APIs do ERP.

**Responsabilidades**:
- Comunicação com APIs
- Sincronização de dados
- Tratamento de erros
- Retry logic

**Estrutura**:
```
erp_integration/
├── domain/
│   ├── entities/
│   │   ├── product.dart
│   │   └── customer.dart
│   ├── repositories/
│   │   ├── product_repository.dart
│   │   └── customer_repository.dart
│   └── usecases/
│       ├── get_products.dart
│       └── get_customers.dart
├── data/
│   ├── datasources/
│   │   ├── erp_api_datasource.dart
│   │   └── erp_cache_datasource.dart
│   ├── models/
│   │   ├── product_model.dart
│   │   └── customer_model.dart
│   └── repositories/
│       ├── product_repository_impl.dart
│       └── customer_repository_impl.dart
└── presentation/
    └── (cubit/widgets conforme necessário)
```

### 3. **Common Module** (core/src/common/)

Componentes e utilitários compartilhados.

**Conteúdo**:
- `components/` - Widgets reutilizáveis
- `utilities/` - Funções utilitárias
- `constants/` - Constantes da aplicação
- `helpers/` - Funções auxiliares

---

## 🔄 Padrões e Convenções

### Naming Conventions

**Arquivos**:
- `snake_case` para arquivos: `user_repository.dart`
- `PascalCase` para classes: `UserRepository`
- `camelCase` para funções/métodos: `getUserById()`

**Variáveis**:
- `camelCase` para propriedades: `userName`
- `_camelCase` para variáveis privadas: `_isLoading`

**Constantes**:
- `SCREAMING_SNAKE_CASE`: `const String API_URL = '...'`

### Import Organization

```dart
// 1. Dart imports
import 'dart:async';
import 'dart:convert';

// 2. Flutter imports
import 'package:flutter/material.dart';

// 3. Package imports
import 'package:equatable/equatable.dart';

// 4. Relative imports
import '../domain/repositories/user_repository.dart';
```

### Código

**Entity**:
```dart
class User extends Equatable {
  final String id;
  final String name;
  final String email;

  const User({
    required this.id,
    required this.name,
    required this.email,
  });

  @override
  List<Object?> get props => [id, name, email];
}
```

**Repository**:
```dart
abstract class UserRepository {
  Future<Either<Failure, User>> getUserById(String id);
  Future<Either<Failure, void>> updateUser(User user);
}
```

**Use Case**:
```dart
class GetUserById implements UseCase<User, String> {
  final UserRepository repository;

  GetUserById(this.repository);

  @override
  Future<Either<Failure, User>> call(String id) async {
    return await repository.getUserById(id);
  }
}
```

---

## 🧪 Testes

### Estrutura de Testes

```
test/
├── src/
│   ├── auth/
│   │   ├── domain/
│   │   │   └── usecases/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   └── presentation/
│   │       └── cubit/
│   └── ...
```

### Convenções de Teste

```dart
void main() {
  group('AuthRepository', () {
    late AuthRepository authRepository;
    late AuthRemoteDataSource mockRemoteDataSource;

    setUp(() {
      mockRemoteDataSource = MockAuthRemoteDataSource();
      authRepository = AuthRepositoryImpl(
        remoteDataSource: mockRemoteDataSource,
      );
    });

    group('login', () {
      test('should return User when login is successful', () async {
        // Arrange
        when(mockRemoteDataSource.login(any, any))
            .thenAnswer((_) async => userModel);

        // Act
        final result = await authRepository.login('email', 'password');

        // Assert
        expect(result, Right(userModel));
      });
    });
  });
}
```

---

## 🔌 Dependency Injection

**Padrão**: `get_it`

### Setup do DI (core/lib/src/core/di/injection_container.dart)

```dart
final getIt = GetIt.instance;

void setupCoreDependencies() {
  // DataSources
  getIt.registerSingleton<AuthRemoteDataSource>(
    AuthRemoteDataSourceImpl(client: getIt()),
  );

  // Repositories
  getIt.registerSingleton<AuthRepository>(
    AuthRepositoryImpl(remoteDataSource: getIt()),
  );

  // UseCases
  getIt.registerSingleton<LoginUseCase>(
    LoginUseCase(getIt()),
  );

  // Cubits
  getIt.registerSingleton<AuthCubit>(
    AuthCubit(loginUseCase: getIt()),
  );
}
```

---

## 📡 API Integration

### Base Client

```dart
class DioClient {
  final Dio _dio;

  DioClient(this._dio) {
    _dio.options = BaseOptions(
      baseUrl: 'https://api.erp.com',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    );

    _dio.interceptors.add(
      ErrorInterceptor(),
    );
  }
}
```

### Response Pattern

```dart
abstract class Either<L, R> {}

class Left<L, R> extends Either<L, R> {
  final L value;
  Left(this.value);
}

class Right<L, R> extends Either<L, R> {
  final R value;
  Right(this.value);
}
```

---

## 🗄️ Database (Drift)

### Banco de Dados Local

```dart
part 'app_database.g.dart';

@DriftDatabase(tables: [Users, Products])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}
```

---

## 📋 Checklist de Features

Ao adicionar uma nova feature, seguir:

- [ ] Criar structure em `domain/`
- [ ] Criar entities
- [ ] Criar repositories (abstract)
- [ ] Criar use cases
- [ ] Testes unitários para use cases
- [ ] Criar data sources
- [ ] Criar models
- [ ] Implementar repositories
- [ ] Testes para repositories
- [ ] Criar cubits/providers
- [ ] Testes para cubits
- [ ] Criar páginas/widgets
- [ ] Testes para widgets
- [ ] Integração com rotas
- [ ] Documentação

---

## 🚀 Getting Started

### Clonar e Setup

```bash
git clone <repo-url> GestaoERPApps
cd GestaoERPApps/core
flutter pub get
```

### Gerar Código

```bash
flutter pub run build_runner build
```

### Rodar Testes

```bash
flutter test
```

### Build para Produção

```bash
flutter build apk --release
flutter build ios --release
```

---

## 📚 Referências

- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter Docs](https://flutter.dev/docs)
- [BLoC Pattern](https://bloclibrary.dev)
- [Drift Documentation](https://drift.simonbinder.eu/)

---

## 🤝 Contribuindo

Ao contribuir com código:

1. Seguir convenções de código
2. Escrever testes
3. Executar `flutter analyze`
4. Fazer PR com descrição detalhada

---

**Desenvolvido com ❤️ para a plataforma ERP**
