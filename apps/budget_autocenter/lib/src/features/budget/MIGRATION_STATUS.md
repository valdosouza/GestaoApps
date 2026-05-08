# BUDGET MODULE MIGRATION STATUS

## Conclusão da Migração: 17 / 33 arquivos

### Criados com sucesso:

#### Domain Layer (6 arquivos)
- [x] domain/entity/budget_entity.dart
- [x] domain/entity/budget_item_entity.dart
- [x] domain/entity/customer_entity.dart
- [x] domain/entity/product_entity.dart (inclui StockBalanceEntity, PriceListEntity, ProductImageEntity)
- [x] domain/entity/payment_type_entity.dart
- [x] domain/repository/budget_repository.dart
- [x] domain/usecase/budget_usecases.dart

#### Data Layer (6 arquivos)
- [x] data/model/budget_model.dart
- [x] data/model/budget_item_model.dart
- [x] data/model/customer_model.dart
- [x] data/model/payment_type_model.dart
- [x] data/model/product_model.dart (inclui StockBalanceModel, PriceListModel, ProductImageModel)
- [x] data/datasource/local/budget_local_datasource.dart
- [x] data/datasource/remote/budget_remote_datasource.dart
- [x] data/repository/budget_repository_impl.dart

#### Module & Presentation (4 arquivos)
- [x] budget_module.dart
- [x] presentation/bloc/budget_list_event.dart
- [x] presentation/bloc/budget_list_state.dart
- [x] presentation/bloc/budget_list_bloc.dart

### FALTAM CRIAR (16 arquivos):

#### Presentation - BLoCs (7 arquivos)
- [ ] presentation/bloc/budget_register_event.dart
- [ ] presentation/bloc/budget_register_state.dart
- [ ] presentation/bloc/budget_register_bloc.dart
- [ ] presentation/bloc/customer_search_bloc.dart (eventos + states embutidos)
- [ ] presentation/bloc/payment_type_bloc.dart (eventos + states embutidos)
- [ ] presentation/bloc/product_search_event.dart
- [ ] presentation/bloc/product_search_state.dart
- [ ] presentation/bloc/product_search_bloc.dart

#### Presentation - Pages (4 arquivos)
- [ ] presentation/page/budget_list_page.dart
- [ ] presentation/page/budget_register_page.dart
- [ ] presentation/page/budget_item_page.dart

#### Presentation - Widgets (3 arquivos)
- [ ] presentation/widget/customer_search_dialog.dart
- [ ] presentation/widget/payment_type_dialog.dart
- [ ] presentation/widget/product_search_dialog.dart

## Imports Adaptados:

Todos os arquivos criados têm imports adaptados:
- `package:budget_sales/app/modules/budget/` → `package:budget_sales/src/features/budget/`
- `package:budget_sales/app/core/` → `package:core/`

## Próximas Ações:

1. Criar os 8 arquivos de BLoCs (eventos/states/blocs)
2. Criar os 4 arquivos de Pages
3. Criar os 3 arquivos de Widgets
4. Validar todos os imports nas páginas
5. Testar compilação do módulo
