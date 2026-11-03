# GestaoApps

Aplicativos Flutter integrados à `local-gestao-api`, que acessa o Firebird do ERP. O `core` reúne autenticação, permissões, HTTP e banco local.

| Pasta | Aplicativo |
| --- | --- |
| `apps/budget_sales` | Orçamentos de vendas, com rascunhos em SQLite/Drift |
| `apps/stock_count` | Consulta de produtos e ajuste de estoque |
| `apps/budget_autocenter` | Orçamentos automotivos Web/Android, com lista real e rascunhos locais em desenvolvimento |

## Requisitos

- Flutter 3.41+ e Dart 3.11+ no `PATH`.
- Android Studio, SDK Platform 36 e NDK `28.2.13676358`.
- Emulador ou aparelho Android com depuração USB (API 24+).
- [API configurada e rodando](../local-gestao-api/readme.md), com uma base existente do ERP.
- Usuário ativo do ERP com vendedor associado.

## Preparação

Comandos para Windows/PowerShell. Execute primeiro no `core` para gerar os arquivos Drift e JSON:

```powershell
Set-Location 'D:\git\valdosouza\GestaoApps\core'
flutter doctor -v
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

Os projetos Android de vendas e estoque leem `android/key.properties` durante a configuração do Gradle. A ausência das propriedades pode causar erro de cast mesmo em debug. Configure em cada app com os dados válidos da assinatura:

```properties
keyAlias=ALIAS_DA_CHAVE
keyPassword=SENHA_DA_CHAVE
storeFile=C:/caminho/assinatura.jks
storePassword=SENHA_DO_ARQUIVO
```

Mantenha senhas e chaves fora do Git. Para desenvolver sem a configuração de release, o Gradle ainda precisa ser ajustado.

## Executar

Vendas:

```powershell
Set-Location 'D:\git\valdosouza\GestaoApps\apps\budget_sales'
flutter pub get
flutter devices
flutter run -d ID_DO_DISPOSITIVO
```

Estoque, em outro terminal:

```powershell
Set-Location 'D:\git\valdosouza\GestaoApps\apps\stock_count'
flutter pub get
flutter devices
flutter run -d ID_DO_DISPOSITIVO
```

Use o ID listado por `flutter devices`. A raiz do repositório não é um pacote Flutter.

## Conectar à API

Na primeira execução, informe apenas o IPv4 do servidor, teste a conexão, selecione o estabelecimento e faça login com a senha normal do ERP.

- Emulador Android padrão, com API no computador hospedeiro: `10.0.2.2`.
- Aparelho físico: IPv4 do computador na rede, por exemplo `192.168.0.10`, com acesso à porta TCP 3000.

A URL é `http://IP:3000/api/v1/`. Porta e caminho ficam em `core/lib/shared/constants.dart`.

## Verificação e pendências

- Rode `flutter analyze` no pacote alterado e `flutter test` no app de vendas.
- Erro de `.g.dart` ausente: repita a geração no `core`.
- HTTP 401: faça login novamente. Se os estabelecimentos falharem, confira a API e o Firebird.
- O splash do estoque ainda pode restaurar sessão em `/budget/`; há também divergência na leitura do ID do estabelecimento em BLoCs do orçamento.
- O orçamento envia cabeçalho e itens separadamente; confira gravações parciais antes de reenviar.

A execução integrada com o banco real ainda precisa ser validada. Veja também o [aplicativo original](../budget_sales_app/README.md).
