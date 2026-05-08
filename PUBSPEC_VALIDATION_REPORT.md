# 🔍 Validação de pubspec.yaml - Relatório

**Data**: 06/05/2026  
**Status**: ⚠️ Requer Correções

---

## ❌ **PROBLEMAS ENCONTRADOS**

### 1️⃣ **budget_sales/pubspec.yaml**
**Problema**: Nome ainda é `orcamento_vendas` (português)  
**Deve ser**: `budget_sales` (inglês)

```yaml
# ❌ ERRADO
name: orcamento_vendas

# ✅ CORRETO
name: budget_sales
```

**Impacto**: Referências inconsistentes com estrutura de pastas

---

### 2️⃣ **budget_autocenter/pubspec.yaml**
**Problema**: Nome ainda é `orcamento_autocenter` (português)  
**Deve ser**: `budget_autocenter` (inglês)

```yaml
# ❌ ERRADO
name: orcamento_autocenter

# ✅ CORRETO
name: budget_autocenter
```

**Impacto**: Referências inconsistentes com estrutura de pastas

---

### 3️⃣ **stock_count/pubspec.yaml**
**Problema**: Nome ainda é `contagem_estoque` (português)  
**Deve ser**: `stock_count` (inglês)

```yaml
# ❌ ERRADO
name: contagem_estoque

# ✅ CORRETO
name: stock_count
```

**Impacto**: Referências inconsistentes com estrutura de pastas

---

## ⚠️ **DEPENDÊNCIAS FALTANTES**

### Nos Apps (budget_sales, budget_autocenter, stock_count)

Os módulos migrados (Auth, Splash, Budget) usam estas dependências que **FALTAM** nos apps:

| Dependência | Versão | Razão |
|------------|--------|-------|
| `equatable` | ^2.0.8 | Entidades usam Equatable |
| `dartz` | ^0.10.1 | Either<Failure, Success> |
| `shared_preferences` | ^2.5.3 | Cache local (Auth) |
| `json_serializable` | ^6.11.2 | Modelos JSON |
| `build_runner` | ^2.11.1 | Gerador de código |

**Status**: ⚠️ Vão herdar do core, mas melhor ser explícito

---

## ✅ **O QUE ESTÁ BOM**

| Item | Core | budget_sales | budget_autocenter | stock_count |
|------|------|--------------|-------------------|------------|
| SDK Flutter | ✅ 3.41+ | ✅ 3.41+ | ✅ 3.41+ | ✅ 3.41+ |
| SDK Dart | ✅ 3.11+ | ✅ 3.11+ | ✅ 3.11+ | ✅ 3.11+ |
| Path ao core | - | ✅ ../../core | ✅ ../../core | ✅ ../../core |
| Bloc | ✅ 8.1.4 | ✅ 8.1.4 | ✅ 8.1.4 | ✅ 8.1.4 |
| Flutter Bloc | ✅ 8.1.6 | ✅ 8.1.6 | ✅ 8.1.6 | ✅ 8.1.6 |
| Firebase Core | ✅ 3.15.2 | ✅ 3.15.2 | ✅ 3.15.2 | ✅ 3.15.2 |

---

## 🔧 **RECOMENDAÇÕES**

### ✅ EXECUTAR (Necessário)
1. Renomear `name` em budget_sales/pubspec.yaml
2. Renomear `name` em budget_autocenter/pubspec.yaml
3. Renomear `name` em stock_count/pubspec.yaml

### 🟡 CONSIDERAR (Opcional mas recomendado)
1. Adicionar `equatable`, `dartz` aos apps (explícito)
2. Adicionar `json_serializable`, `build_runner` aos apps (dev_dependencies)
3. Adicionar `shared_preferences` aos apps (Auth usa)

### ✅ MANTER (Bom)
- Versões do Flutter e Dart
- Path ao core está correto
- Dependências de BLoC compatíveis
- Firebase setup

---

## 📝 **RESUMO**

| Arquivo | Status | Ação |
|---------|--------|------|
| `core/pubspec.yaml` | ✅ OK | Nenhuma |
| `budget_sales/pubspec.yaml` | ⚠️ Nome errado | Corrigir nome |
| `budget_autocenter/pubspec.yaml` | ⚠️ Nome errado | Corrigir nome |
| `stock_count/pubspec.yaml` | ⚠️ Nome errado | Corrigir nome |

---

## 🚀 **Próximos Passos**

1. **Corrigir nomes** nos 3 pubspec.yaml dos apps
2. **Opcionalmente** adicionar dependências explícitas
3. Rodar `flutter pub get` em cada pasta
4. Validar com `flutter doctor`

---

**Relatório de validação concluído! 📋**
