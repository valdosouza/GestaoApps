# 📱 Orçamento de Vendas

Aplicativo para criação e gerenciamento de orçamentos de vendas com integração ao ERP.

## 🎯 Funcionalidades Planejadas

- [ ] Listagem de orçamentos
- [ ] Criação de novo orçamento
- [ ] Edição de orçamento
- [ ] Aprovação de orçamento
- [ ] Exportação em PDF
- [ ] Integração com produtos do ERP
- [ ] Integração com clientes do ERP
- [ ] Workflow de aprovação
- [ ] Sincronização offline

## 📂 Estrutura

```
lib/
├── main.dart                    # Ponto de entrada
├── app.dart                     # Configuração do app
└── src/
    ├── features/
    │   └── orcamento/          # Feature principal
    │       ├── domain/
    │       ├── data/
    │       └── presentation/
    ├── config/
    │   ├── routes/
    │   └── theme/
    └── di/
        └── injection_container.dart
```

## 🚀 Getting Started

### 1. Instalar dependências

```bash
flutter pub get
```

### 2. Gerar código (se necessário)

```bash
flutter pub run build_runner build
```

### 3. Rodar o app

```bash
flutter run
```

## 🔄 Próximos Passos

1. **Fase 1**: Setup base ✅
2. **Fase 2**: Features de listagem
3. **Fase 3**: Features de criação/edição
4. **Fase 4**: Integração com ERP
5. **Fase 5**: Testes e polimento

## 🛠️ Dependências

Veja `pubspec.yaml` para a lista completa.

**Principais**:
- Flutter 3.41+
- core (módulo compartilhado)
- bloc 8.1.4
- go_router 14.0.0

## 📝 Notas

- Este app herda funcionalidades do módulo `core`
- Usa Clean Architecture
- Padrão BLoC para gerenciamento de estado

---

**Desenvolvido com ❤️ para a plataforma ERP**
