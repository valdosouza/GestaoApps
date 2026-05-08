# 🚗 AutoCenter - Orçamento

Aplicativo especializado para orçamentos de serviços automotivos e manutenção.

## 🎯 Funcionalidades Planejadas

- [ ] Orçamento para serviços automotivos
- [ ] Agendamento de serviços
- [ ] Controle de peças e mão de obra
- [ ] Integração com tabelas de preços
- [ ] Histórico de serviços
- [ ] Relatórios de manutenção
- [ ] Sincronização com ERP

## 📂 Estrutura

```
lib/
├── main.dart                    # Ponto de entrada
├── app.dart                     # Configuração do app
└── src/
    ├── features/
    │   └── orcamento/          # Feature de orçamento
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

### 2. Rodar o app

```bash
flutter run
```

## 🔄 Próximos Passos

1. **Fase 1**: Setup base ✅
2. **Fase 2**: Features de listagem
3. **Fase 3**: Features de criação/edição
4. **Fase 4**: Integração com ERP
5. **Fase 5**: Agendamento e sincronização

## 🛠️ Dependências

Veja `pubspec.yaml` para a lista completa.

**Principais**:
- Flutter 3.41+
- core (módulo compartilhado)
- bloc 8.1.4

## 📝 Notas

- Herda funcionalidades do módulo `core`
- Usa Clean Architecture
- Padrão BLoC para estado

---

**Para serviços automotivos profissionais**
