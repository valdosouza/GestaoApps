# 🎨 Exemplo de Uso do Theme Centralizado

## Como os Apps Usam o Theme do Core

### 1. Budget Sales (Azul) - app.dart

```dart
import 'package:flutter/material.dart';
import 'package:core/core.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Usar tema do core específico para este app
    final appTheme = AppTheme.budgetSales();

    return MaterialApp(
      title: 'Budget Sales',
      theme: appTheme.getThemeData(),
      home: const HomeScreen(),
    );
  }
}
```

### 2. Budget AutoCenter (Laranja) - app.dart

```dart
import 'package:flutter/material.dart';
import 'package:core/core.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Usar tema do core específico para este app
    final appTheme = AppTheme.budgetAutocenter();

    return MaterialApp(
      title: 'Budget AutoCenter',
      theme: appTheme.getThemeData(),
      home: const HomeScreen(),
    );
  }
}
```

### 3. Stock Count (Verde) - app.dart

```dart
import 'package:flutter/material.dart';
import 'package:core/core.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Usar tema do core específico para este app
    final appTheme = AppTheme.stockCount();

    return MaterialApp(
      title: 'Stock Count',
      theme: appTheme.getThemeData(),
      home: const HomeScreen(),
    );
  }
}
```

---

## Usando Cores no Código

### ❌ Errado
```dart
Container(
  color: Color(0xFF2196F3), // Hardcoded!
  child: Text('Hi'),
)
```

### ✅ Correto
```dart
import 'package:core/core.dart';

Container(
  color: AppColors.primaryBlue,
  child: Text('Hi'),
)
```

---

## Usando Estilos de Texto

### ❌ Errado
```dart
Text(
  'Title',
  style: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  ),
)
```

### ✅ Correto
```dart
Text(
  'Title',
  style: Theme.of(context).textTheme.titleLarge,
)
```

---

## Cores Disponíveis

```dart
// Cores primárias
AppColors.primaryBlue      // #2196F3
AppColors.primaryOrange    // #FF9800
AppColors.primaryGreen     // #4CAF50

// Neutras
AppColors.white            // #FFFFFF
AppColors.black            // #000000
AppColors.grey100          // #F5F5F5
AppColors.grey500          // #9E9E9E
AppColors.grey900          // #212121

// Semânticas
AppColors.success          // #4CAF50
AppColors.warning          // #FFC107
AppColors.error            // #F44336
AppColors.info             // #2196F3

// Gradients
AppColors.blueGradient
AppColors.orangeGradient
AppColors.greenGradient
```

---

## Vantagens da Centralização

✅ **Consistência** - Mesmo look & feel em todos os apps  
✅ **Manutenção** - Alterar cores em um único lugar  
✅ **Escalabilidade** - Fácil adicionar novos temas  
✅ **Padronização** - Todos seguem os mesmos padrões  
✅ **Reutilização** - Componentes compartilhados  

---

**Theme centralized, app-specific customization! 🎨**
