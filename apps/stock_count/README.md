# 📦 Contagem de Estoque

Aplicativo para inventário em tempo real com sincronização com ERP e suporte a QR code.

## 🎯 Funcionalidades Planejadas

- [ ] Leitura de QR Code / Código de Barras
- [ ] Contagem de estoque em tempo real
- [ ] Sincronização com ERP
- [ ] Relatórios de discrepâncias
- [ ] Sincronização offline
- [ ] Histórico de contagens
- [ ] Ajustes manuais
- [ ] Exportação de relatórios

## 📂 Estrutura

```
lib/
├── main.dart                    # Ponto de entrada
├── app.dart                     # Configuração do app
└── src/
    ├── features/
    │   └── contagem/           # Feature principal
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
2. **Fase 2**: Scanner de QR code
3. **Fase 3**: Interface de contagem
4. **Fase 4**: Sincronização com ERP
5. **Fase 5**: Relatórios

## 🛠️ Dependências

Veja `pubspec.yaml` para a lista completa.

**Principais**:
- Flutter 3.41+
- core (módulo compartilhado)
- bloc 8.1.4
- mobile_scanner 7.2.0

## 📝 Notas

- Herda funcionalidades do módulo `core`
- Usa Clean Architecture
- Inclui scanner de QR/Código de Barras
- Suporta sincronização offline

---

**Para inventário eficiente e em tempo real**
