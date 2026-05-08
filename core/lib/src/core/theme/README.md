# 🎨 Theme Module

Módulo centralizado de temas para toda a aplicação.

## 📋 Estrutura

```
theme/
├── app_colors.dart      # Cores padronizadas
├── app_theme.dart       # Temas por app
└── README.md
```

## 🎨 Cores Disponíveis

### Cores Base
- `primaryBlue` - Azul principal
- `primaryOrange` - Laranja principal
- `primaryGreen` - Verde principal

### Cores Neutras
- `grey50` até `grey900` - Escala de cinzas

### Cores Semânticas
- `success` - Verde de sucesso
- `warning` - Amarelo de aviso
- `error` - Vermelho de erro
- `info` - Azul de informação

## 🎭 Temas por App

### Budget Sales (Azul)
```dart
final theme = AppTheme.budgetSales();
final themeData = theme.getThemeData();
```

### Budget AutoCenter (Laranja)
```dart
final theme = AppTheme.budgetAutocenter();
final themeData = theme.getThemeData();
```

### Stock Count (Verde)
```dart
final theme = AppTheme.stockCount();
final themeData = theme.getThemeData();
```

## 🚀 Como Usar em um App

### No `main.dart`:
```dart
import 'package:core/core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await setupCoreInjection();
  setupAppInjection();
  
  runApp(const MyApp());
}
```

### No `app.dart`:
```dart
import 'package:core/core.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Escolher tema baseado no app
    final appTheme = AppTheme.budgetSales(); // ou outro
    
    return MaterialApp(
      title: 'Budget Sales',
      theme: appTheme.getThemeData(),
      home: const HomeScreen(),
    );
  }
}
```

## 🎯 Features

✅ **Material Design 3** - Design moderno e responsivo  
✅ **Tema Base Completo** - AppBar, Buttons, Input Fields, Text Styles, etc  
✅ **3 Cores Distintas** - Uma cor por app  
✅ **Cores Padronizadas** - Acesso fácil a cores semânticas  
✅ **Gradientes** - Gradientes pré-definidos por app  
✅ **Customizável** - Fácil estender para novos temas  

## 📝 Customização

Para criar um novo tema:

```dart
factory AppTheme.custom() {
  return const AppTheme(
    primaryColor: Color(0xFF...), 
    accentColor: Color(0xFF...),
    primaryGradient: LinearGradient(...),
  );
}
```

## 🎨 Components Estilizados

### AppBar
- Fundo com cor primária
- Título em branco
- Elevação de 4

### Buttons
- `ElevatedButton` - Primário com cor do tema
- `OutlinedButton` - Contorno com cor do tema
- `TextButton` - Texto com cor do tema

### Input Fields
- Fundo cinza claro
- Borda com cor do tema ao focar
- Validação com cores semânticas

### Cards
- Fundo branco
- Sombra suave
- Border radius de 12

### Dialogs
- Fundo branco
- Border radius de 16
- Sombra elevada

## 🔧 Maintenance

Para manter consistência:
1. Sempre usar `AppColors` para cores
2. Sempre usar `AppTheme.getThemeData()` para ThemeData
3. Nunca hardcodear cores nos widgets
4. Usar `Text()` com estilos do theme

---

**Centralizado, reutilizável e consistente! 🎨**
