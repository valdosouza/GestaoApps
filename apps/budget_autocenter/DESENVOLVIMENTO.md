# Desenvolvimento do AutoCenter

## Camada atual — documento completo para homologação (2026-11-02)

RealBudgetListPage abre BudgetDetailsPage. CompleteBudgetRepository lê/salva pelo módulo /autocenter da API; NewBudgetPage usa BudgetContentsEditor para peças, serviços, valores, veículo e checklist. O editor demonstrativo antigo continua isolado em testes, sem fallback para dados reais.

PendingBudgetStore agora persiste o documento completo em JSON, incluindo a versão de origem, itens, veículo, checklist e chave de envio. Mantém namespace por servidor/estabelecimento/usuário e leitura dos pendentes antigos sem document. A marca _transport=autocenter-v1 identifica envios cobertos pela nova idempotência; um envio incerto antigo não pode ser repetido cegamente no endpoint novo.

A API calcula totais, valida referências, respeita permissões com identidade JWT e grava em uma transação. Atualização conserva IDs dos itens e dados desconhecidos; vehicleDirty/checklistDirty evitam regravar seções não alteradas. Versão SHA-256 e CTC_EMUSO impedem sobrescrever mudanças do desktop; não há mesclagem automática. O custo de itens novos vem do cadastro; regras especiais de comissões/campanhas/associações e técnicos não estão homologadas.

TB_APP_BUDGET_OP é uma tabela técnica aditiva para idempotência, criada pelo script setup-autocenter.js. Já foi aplicada à base local, sem alterar registros comerciais. As tabelas do Delphi não foram alteradas. Novos IDs usam os generators existentes; numeração comercial nova continua delegada ao fluxo legado. BLOBs de observação são codificados em WIN1252, compatível com a base/Delphi examinados.

Validação automática: análise Flutter, testes de navegação/edição/persistência em 320/1000 pixels, contrato HTTP, transações/rollback, concorrência, permissões, arredondamento e 22 regiões × 4 estados. Leitura real do orçamento e dos nove cadastros validada; cores retornaram vazias. Build web e APK debug gerados. Escrita comercial real, regras específicas do cliente e uso físico são homologação manual, com roteiro em HOMOLOGACAO.md. Contrato da API em local-gestao-api/CONTRATO-AUTOCENTER.md.

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
- `domain/entity/budget_list_entry.dart`: leitura dos registros reais.
- `data/repository/real_budget_list_repository.dart`: consulta/filtros na API.
- `data/repository/budget_draft_repository.dart`: cadastros auxiliares e envio do cabeçalho.
- `data/repository/pending_budget_store.dart`: persistência dos pendentes locais.
- `presentation/page/real_budget_list_page.dart`: lista ativa, filtros, pendentes e Novo.
- `presentation/page/new_budget_page.dart`: preenchimento, retomada e envio.
- `presentation/page/autocenter_budget_page.dart`: entrada da lista ativa e editor demonstrativo preservado.
- `presentation/page/budget_overview_page.dart`: consulta demonstrativa usada no fixture de testes.
- `presentation/widget/vehicle_inspection.dart`: desenho interativo do veículo.

Os caminhos a partir de domain/data/presentation são relativos a features/budget. Arquivos de datasource, repositório, entidades/BLoCs e páginas migrados anteriormente do Sales foram preservados para a futura integração, mas não são ligados ao BudgetModule ativo. Não confundir as páginas antigas budget_list_page.dart/budget_register_page.dart com as páginas ativas acima.

## Fluxo e dados

Entrada igual ao Sales: SplashModule → ServerIpPage quando necessário → AuthModule → /budget/. A autenticação continua real e compartilhada; o tema do Sales é usado em todas as telas. Nenhuma alteração na API ou no Firebird é necessária para esta organização.

O editor demonstrativo preservado tem três exemplos, peças/mão de obra, veículo, inspeção e revisão, todos em memória e fora da rota ativa. As 22 regiões preservam os IDs do Delphi; nomes e lateralidade ainda precisam de validação com o negócio. O fluxo real disponível está descrito na camada atual acima.

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
