# Desenvolvimento do AutoCenter

O fluxo aprovado foi promovido em 2026-11-02. Existe uma única entrada, `lib/main.dart`; não há entrada separada de protótipo nem tela de boas-vindas que pule a autenticação.

## Estrutura ativa

- `lib/main.dart`: inicialização Flutter/Modular.
- `lib/app.dart`: router, localização e tema.
- `lib/src/app_module.dart`: splash, configuração e login do core, mais módulo de orçamento.
- `lib/src/core/theme/app_theme.dart`: mesma configuração visual do Sales.
- `lib/src/features/budget/budget_module.dart`: rota da lista aprovada.
- `domain/entity/autocenter_budget.dart`: orçamento, itens e inspeção em memória.
- `domain/entity/vehicle_region.dart`: geometria/IDs das 22 regiões.
- `data/datasource/local/demo_catalog.dart`: catálogo fictício isolado.
- `presentation/page/autocenter_budget_page.dart`: composição e editor por etapas.
- `presentation/page/budget_overview_page.dart`: lista, filtros e consulta de detalhes.
- `presentation/widget/vehicle_inspection.dart`: desenho interativo do veículo.

Os caminhos a partir de domain/data/presentation são relativos a features/budget. Arquivos de datasource, repositório, entidades/BLoCs e páginas migrados anteriormente do Sales foram preservados para a futura integração, mas não são ligados ao BudgetModule ativo. Não confundir as páginas antigas budget_list_page.dart/budget_register_page.dart com as páginas ativas acima.

## Fluxo e dados

Entrada igual ao Sales: SplashModule → ServerIpPage quando necessário → AuthModule → /budget/. A autenticação continua real e compartilhada; o tema do Sales é usado em todas as telas. Nenhuma alteração na API ou no Firebird é necessária para esta organização.

A lista contém três exemplos fictícios, filtros e acesso aos detalhes. A edição tem cliente/pagamento, peças/mão de obra, veículo, inspeção e revisão. O catálogo e os rascunhos permanecem apenas em memória; a promoção da interface não implica persistência de produção. As 22 regiões preservam os IDs do Delphi, mas os nomes e lateralidade ainda precisam de validação com o negócio.

## Verificar

Validação da promoção em 2026-11-02: análise completa de lib/test sem problemas, 8 testes aprovados, build web pela entrada padrão concluído e APK Android debug gerado em build/app/outputs/flutter-apk/app-debug.apk. O primeiro build Android encontrou o problema de cache Kotlin entre discos; após o ajuste descrito abaixo, o build completou. Isso não valida integração de orçamento com o ERP nem assinatura de publicação.

```powershell
flutter analyze
flutter test
flutter build web --no-web-resources-cdn
flutter build apk --debug
```

Os testes cobrem configuração inicial sem servidor salvo, lista/detalhes/edição/filtros em 320 e 1000 pixels, cálculo de valores, cópia de rascunho e correspondência das 22 regiões e quatro condições. O teste de abertura usa armazenamento simulado e não autentica usuários reais.

## Android

No Windows, o Gradle limita workers/memória e desativa o cache incremental Kotlin para evitar erro de caminhos relativos quando o projeto está em D: e o Pub Cache em C:. Essa configuração não altera dados de negócio.

Scaffold próprio gerado com Flutter e ferramentas alinhadas ao Sales: AGP 8.11.1, Kotlin 2.2.20, Gradle 8.14, Java 17 como alvo de bytecode, JDK 21 para build, SDK 36 e NDK 28.2.13676358. Application ID: com.setes.budget_autocenter. Android permite HTTP para a API na rede local. A base não aplica Google Services/Firebase nem usa chaves do Sales; configurar serviços e assinatura quando houver necessidade de produção. Release ainda usa chave debug do scaffold e não deve ser distribuído como release de produção.

## Próxima integração

Substituir fontes demonstrativas por repositórios reais, conferir serviços/técnicos, permissões, concorrência e contrato de gravação das tabelas de veículo/checklist. Referência do legado: D:\tortoise\Valdo\gestao2016\Infra-IA\Gestao\08-autocenter\INDEX.md.
