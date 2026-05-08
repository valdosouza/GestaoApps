# 🔐 Security Guide - Guia de Segurança

**Data**: 06/05/2026  
**Status**: ✅ Implementado

---

## 📋 **O que foi feito**

### ✅ 1. **.gitignore Aprimorado**
Expandimos o arquivo `.gitignore` com proteções completas para dados sensíveis.

### ✅ 2. **.env.example Criado**
Template de configuração de ambiente para referência segura.

---

## 🔒 **Dados Sensíveis Protegidos**

### **1. Credenciais e Chaves**
```
✅ .env                 # Variáveis de ambiente (NUNCA commitar)
✅ .env.local          # Configuração local da máquina
✅ .env.production     # Credenciais de produção
✅ secrets.json        # Arquivo de segredos
✅ *.key, *.pem        # Arquivos de chaves privadas
```

### **2. Configurações Sensíveis**
```
✅ google-services.json           # Firebase Android
✅ GoogleService-Info.plist       # Firebase iOS
✅ serviceAccountKey.json         # Google Cloud Service Account
✅ android/local.properties       # Configuração local Android
✅ ios/local.properties           # Configuração local iOS
```

### **3. OAuth e Tokens**
```
✅ .oauth/                        # OAuth configurations
✅ tokens.json                    # Tokens de autenticação
✅ refresh_token.json             # Refresh tokens
✅ oauth.json                     # Configuração OAuth
```

### **4. Credenciais de Cloud**
```
✅ .aws/                          # AWS configurations
✅ .azure/                        # Azure configurations
✅ .gcp/                          # Google Cloud configurations
```

### **5. Configuração de Banco de Dados**
```
✅ database.conf                  # Configuração do banco
✅ connection.string              # Connection strings
✅ datasource.properties          # Datasource config
```

---

## 📦 **Arquivos de Build Ignorados**

```
✅ pubspec.lock              # Dependências locked (opcional)
✅ *.apk, *.aab             # Builds Android
✅ *.ipa, *.app             # Builds iOS
✅ build/                    # Diretório de build
✅ .gradle/                  # Gradle cache
✅ lib/generated_*           # Arquivos gerados
```

---

## 💾 **Configurações de IDE Ignoradas**

```
✅ .idea/                    # IntelliJ IDEA
✅ .vscode/settings.json    # VS Code config (mantém alguns)
✅ *.iml                     # IntelliJ modules
✅ .classpath               # Eclipse
✅ .project                 # Eclipse projects
✅ .settings/               # Eclipse settings
```

---

## 🗂️ **Sistema Operacional e Temporários**

```
✅ .DS_Store                # macOS
✅ Thumbs.db               # Windows
✅ *.swp, *~               # Swap files
✅ *.tmp, *.temp           # Temporary files
✅ *.log                    # Log files
```

---

## 🚀 **Como Usar a Configuração**

### 1. **Criar arquivo `.env` na raiz**

```bash
# No terminal, na raiz do projeto
cp .env.example .env
```

### 2. **Preencher valores reais**

```bash
# Editar .env com suas credenciais reais
# Exemplo:
API_BASE_URL=https://seu-api.com
FIREBASE_API_KEY=your-real-key-here
DB_PASSWORD=your-real-password
```

### 3. **Configurar para desenvolvimento local**

```bash
# Criar .env.local para overrides locais (opcional)
cat > .env.local << EOF
# Suas configurações locais
DB_HOST=localhost
DEBUG=true
EOF
```

### 4. **Verificar que .env está ignorado**

```bash
# Verificar se Git está ignorando .env
git check-ignore .env    # Deve retornar .env
git check-ignore .env.example  # NÃO deve retornar nada (é permitido)
```

---

## ⚠️ **NUNCA FAÇA**

```bash
❌ git add .env                          # PERIGO!
❌ git commit -m "Add credentials"      # PERIGO!
❌ echo "API_KEY=123" >> .gitignore    # ERRADO!
❌ Clonar repositório com dados reais   # PERIGO!
```

---

## ✅ **SEMPRE FAÇA**

```bash
✅ Manter .env no .gitignore
✅ Usar .env.example como template
✅ Distribuir .env através de canais seguros
✅ Usar variáveis de ambiente em CI/CD
✅ Rotacionar secrets regularmente
✅ Usar gerenciadores de secrets (1Password, LastPass, etc)
```

---

## 🔑 **Para Desenvolvimento**

### Usando variáveis de ambiente no Dart/Flutter

```dart
// ❌ NUNCA faça isso
const apiKey = "sk_live_123456789";  // PERIGO!

// ✅ FAÇA assim
import 'dart:io';

class Config {
  static final apiKey = Platform.environment['API_KEY'] ?? '';
  static final apiBaseUrl = Platform.environment['API_BASE_URL'] ?? '';
}
```

### Acessando em `main.dart`

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: '.env');
  
  final apiKey = dotenv.env['API_KEY'];
  final apiBase = dotenv.env['API_BASE_URL'];
  
  runApp(const MyApp());
}
```

---

## 🛡️ **Adicionar `flutter_dotenv` ao pubspec.yaml**

```yaml
dependencies:
  flutter_dotenv: ^5.0.0
```

---

## 📝 **Checklist de Segurança**

- [ ] `.env` criado e preenchido com valores reais
- [ ] `.env` está no `.gitignore`
- [ ] `.env.example` é um template vazio
- [ ] Nenhuma credencial no código fonte
- [ ] Nenhuma chave privada commitada
- [ ] `google-services.json` ignorado
- [ ] `serviceAccountKey.json` ignorado
- [ ] `pubspec.lock` analisado para vulnerabilidades
- [ ] CI/CD usando variáveis de ambiente
- [ ] Secrets rotacionados regularmente

---

## 🔍 **Verificar Exposição de Dados**

### Antes de fazer push:
```bash
# Procurar por padrões comuns de secrets
grep -r "password\|api_key\|secret\|token" .env
grep -r "private_key\|client_secret" --include="*.dart"

# Verificar o que será commitado
git status

# Ver o que está sendo adicionado
git diff --cached
```

---

## 📚 **Recursos Adicionais**

- [OWASP Security Practices](https://owasp.org/)
- [Flutter Security Best Practices](https://flutter.dev/docs/development/data-and-backend/json)
- [Git Security Credentials](https://git-scm.com/book/en/v2/Git-Tools-Credential-Storage)
- [12factor.net - Config](https://12factor.net/config)

---

## 🚨 **Se Você Commitou Credenciais Acidentalmente**

### Ações Imediatas:
1. **Não panic!** - Pode ser revertido
2. **Rotacione as credenciais** - Invalide as chaves comprometidas
3. **Remova do histórico:**
   ```bash
   # Remove arquivo do histórico Git
   git filter-branch --tree-filter 'rm -f .env' HEAD
   git push --force-with-lease
   ```

---

## 📞 **Contato de Segurança**

Se encontrou uma vulnerabilidade:
1. NÃO publique publicamente
2. Entre em contato através de canais privados
3. Forneça detalhes da vulnerabilidade
4. Aguarde confirmação

---

**Segurança implementada com sucesso! 🔐**

Mantenha seus dados seguros! 🛡️
