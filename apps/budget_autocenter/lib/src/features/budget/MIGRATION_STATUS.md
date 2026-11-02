# Estado do módulo de orçamento AutoCenter

Atualizado em 2026-11-02. O fluxo aprovado agora é o módulo principal do aplicativo e é aberto por flutter run.

O BudgetModule ativo direciona para presentation/page/autocenter_budget_page.dart. A lista/detalhes está em budget_overview_page.dart e a inspeção em presentation/widget/vehicle_inspection.dart. As entidades ativas estão em domain/entity/autocenter_budget.dart e vehicle_region.dart. O catálogo fictício está separado em data/datasource/local/demo_catalog.dart.

Os arquivos da migração anterior do Sales (datasources HTTP/Drift, repositórios, entidades antigas, BLoCs e outras páginas) foram preservados e ainda não estão conectados ao fluxo aprovado. Login e configuração usam o core real; os orçamentos atuais continuam em memória. Conferir DESENVOLVIMENTO.md na raiz do app antes de integrar persistência.

O antigo checklist de arquivos faltantes foi substituído por este estado, pois as páginas já existem e a arquitetura ativa mudou. Este documento não declara integração Firebird concluída.
