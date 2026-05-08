# 🚀 Quick Start Guide

Comece em 5 minutos!

---

## 📦 Pré-requisitos

- Flutter 3.41+
- Dart 3.11+
- Git
- Editor (VS Code, Android Studio, etc)

---

## 🎯 1. Setup Inicial

```bash
# Clone o repositório
git clone <repo-url> GestaoERPApps
cd GestaoERPApps

# Setup do core
cd core
flutter pub get

# Gerar código (build_runner)
flutter pub run build_runner build
```

---

## 🏃 2. Rodar um App

### Opção 1: Orçamento Vendas
```bash
cd apps/orcamento_vendas
flutter pub get
flutter run
```

### Opção 2: AutoCenter
```bash
cd apps/orcamento_autocenter
flutter pub get
flutter run
```

### Opção 3: Contagem Estoque
```bash
cd apps/contagem_estoque
flutter pub get
flutter run
```

---

## 🔧 3. Estrutura do Projeto

```
GestaoERPApps/
├── core/                    # Módulo compartilhado
│   └── lib/src/
│       ├── auth/           # ✅ Login/Logout
│       ├── erp_integration/ # 🔄 Em progresso
│       └── common/          # 🔄 Em progresso
│
└── apps/
    ├── orcamento_vendas/   # ✅ Pronto
    ├── orcamento_autocenter/ # ✅ Pronto
    └── contagem_estoque/    # ✅ Pronto
```

---

## 📚 4. Documentação

| Documento | Objetivo |
|-----------|----------|
| README.md | Overview do projeto |
| CLAUDE.md | Arquitetura técnica |
| core/README.md | Como usar o core |
| SUMMARY.md | Sumário executivo |
| CHECKLIST.md | Lista de tarefas |

---

## 💡 5. Próximos Passos

### Hoje
- [ ] Clonar repositório
- [ ] Testar `flutter pub get`
- [ ] Rodar um app: `flutter run`

### Esta semana
- [ ] Revisar estrutura
- [ ] Ler CLAUDE.md
- [ ] Acessar projeto referência (BudgetSales)

### Próxima sprint
- [ ] Copiar features do BudgetSales
- [ ] Implementar ERP Integration
- [ ] Adicionar Cubits/BLoCs

---

## 🤔 Dúvidas Comuns

### P: Onde está o main.dart?
**R:** Cada app tem seu próprio:
- `apps/orcamento_vendas/lib/main.dart`
- `apps/orcamento_autocenter/lib/main.dart`
- `apps/contagem_estoque/lib/main.dart`

### P: O que é o "core"?
**R:** Módulo compartilhado com funcionalidades comuns (Auth, ERP Integration, etc) usado por todos os apps.

### P: Como adicionar uma nova feature?
**R:** Crie uma pasta em `features/` com `domain/`, `data/` e `presentation/`.

### P: Como usar o Auth?
**R:** Injete `LoginUseCase` via GetIt:
```dart
final loginUseCase = GetIt.instance<LoginUseCase>();
final result = await loginUseCase(email: '...', password: '...');
```

### P: Qual é a cor do app?
**R:** Cada app tem uma cor:
- **Vendas**: Azul (Blue)
- **AutoCenter**: Laranja (Orange)
- **Estoque**: Verde (Green)

---

## 🔗 Links Úteis

- [Flutter Docs](https://flutter.dev)
- [Dart Docs](https://dart.dev)
- [BLoC Pattern](https://bloclibrary.dev)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

---

## 🆘 Troubleshooting

### Erro: "Versionamento de SDK"
```bash
flutter upgrade
flutter doctor
```

### Erro: "Pubspec não encontrado"
```bash
cd GestaoERPApps
cd core
flutter pub get
```

### Erro: "Device não encontrado"
```bash
flutter devices
flutter run -d <device-id>
```

### Erro: "Build falha"
```bash
flutter clean
flutter pub get
flutter run
```

---

## 📞 Suporte

Para dúvidas sobre:
- **Estrutura**: Veja `CLAUDE.md`
- **Setup**: Veja `README.md`
- **Apps**: Veja README em cada app
- **Checklist**: Veja `CHECKLIST.md`

---

## ⚡ Comandos Úteis

```bash
# Atualizar dependências
flutter pub upgrade

# Gerar código (json_serializable, etc)
flutter pub run build_runner build

# Limpar build
flutter clean

# Analisar código
flutter analyze

# Rodar testes
flutter test

# Build APK (release)
flutter build apk --release

# Build iOS (release)
flutter build ios --release
```

---

## 🎉 Pronto!

Você está pronto para começar! 

**Próximo passo**: `flutter run`

---

**Desenvolvido com ❤️**  
Data: 06/05/2026
