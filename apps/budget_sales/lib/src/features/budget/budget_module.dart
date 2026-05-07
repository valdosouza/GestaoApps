import 'package:core/database/app_database.dart';
import 'package:budget_sales/src/features/budget/data/datasource/local/budget_local_datasource.dart';
import 'package:modular_bloc_bind/modular_bloc_bind.dart';
import 'package:budget_sales/src/features/budget/data/datasource/remote/budget_remote_datasource.dart';
import 'package:budget_sales/src/features/budget/data/repository/budget_repository_impl.dart';
import 'package:budget_sales/src/features/budget/domain/repository/budget_repository.dart';
import 'package:budget_sales/src/features/budget/domain/usecase/budget_usecases.dart';
import 'package:budget_sales/src/features/budget/presentation/bloc/budget_list_bloc.dart';
import 'package:budget_sales/src/features/budget/presentation/bloc/budget_register_bloc.dart';
import 'package:budget_sales/src/features/budget/presentation/bloc/customer_search_bloc.dart';
import 'package:budget_sales/src/features/budget/presentation/bloc/payment_type_bloc.dart';
import 'package:budget_sales/src/features/budget/presentation/bloc/product_search_bloc.dart';
import 'package:budget_sales/src/features/budget/presentation/page/budget_list_page.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:http/http.dart' as http;

class BudgetModule extends Module {
  @override
  List<Bind> get binds => [
        // ── HTTP client ──────────────────────────────────────────────────
        Bind.factory<http.Client>((_) => http.Client()),

        // ── Database ─────────────────────────────────────────────────────
        Bind.singleton<AppDatabase>((_) => AppDatabase()),

        // ── Datasources ──────────────────────────────────────────────────
        Bind.factory<BudgetRemoteDatasource>(
          (i) => BudgetRemoteDatasource(httpClient: i<http.Client>()),
        ),
        Bind.singleton<BudgetLocalDatasource>(
          (i) => BudgetLocalDatasource(db: i<AppDatabase>()),
        ),

        // ── Repository ───────────────────────────────────────────────────
        Bind.singleton<BudgetRepository>(
          (i) => BudgetRepositoryImpl(
            remote: i<BudgetRemoteDatasource>(),
            local: i<BudgetLocalDatasource>(),
          ),
        ),

        // ── Use cases ────────────────────────────────────────────────────
        Bind.factory((i) => GetBudgets(i<BudgetRepository>())),
        Bind.factory((i) => GetBudgetById(i<BudgetRepository>())),
        Bind.factory((i) => CreateBudget(i<BudgetRepository>())),
        Bind.factory((i) => UpdateBudget(i<BudgetRepository>())),
        Bind.factory((i) => GetBudgetItems(i<BudgetRepository>())),
        Bind.factory((i) => CreateBudgetItem(i<BudgetRepository>())),
        Bind.factory((i) => UpdateBudgetItem(i<BudgetRepository>())),
        Bind.factory((i) => DeleteBudgetItem(i<BudgetRepository>())),
        Bind.factory((i) => GetCustomers(i<BudgetRepository>())),
        Bind.factory((i) => GetPaymentTypes(i<BudgetRepository>())),
        Bind.factory((i) => GetProducts(i<BudgetRepository>())),
        Bind.factory((i) => GetStockBalance(i<BudgetRepository>())),
        Bind.factory((i) => GetPrices(i<BudgetRepository>())),
        Bind.factory((i) => GetProductImages(i<BudgetRepository>())),
        Bind.factory((i) => SaveLocalBudget(i<BudgetRepository>())),
        Bind.factory((i) => UpdateLocalBudget(i<BudgetRepository>())),
        Bind.factory((i) => GetLocalBudgets(i<BudgetRepository>())),
        Bind.factory((i) => GetLocalBudgetById(i<BudgetRepository>())),
        Bind.factory((i) => DeleteLocalBudget(i<BudgetRepository>())),
        Bind.factory((i) => SaveLocalItem(i<BudgetRepository>())),
        Bind.factory((i) => UpdateLocalItem(i<BudgetRepository>())),
        Bind.factory((i) => GetLocalItems(i<BudgetRepository>())),
        Bind.factory((i) => DeleteLocalItem(i<BudgetRepository>())),

        // ── BLoCs ────────────────────────────────────────────────────────
        BlocBind.singleton<BudgetListBloc>(
          (i) => BudgetListBloc(
            getBudgets: i<GetBudgets>(),
            getLocalBudgets: i<GetLocalBudgets>(),
          ),
        ),
        BlocBind.factory<BudgetRegisterBloc>(
          (i) => BudgetRegisterBloc(
            getBudgetById: i<GetBudgetById>(),
            createBudget: i<CreateBudget>(),
            saveLocalBudget: i<SaveLocalBudget>(),
            updateLocalBudget: i<UpdateLocalBudget>(),
            getLocalBudgetById: i<GetLocalBudgetById>(),
            deleteLocalBudget: i<DeleteLocalBudget>(),
            getLocalItems: i<GetLocalItems>(),
            saveLocalItem: i<SaveLocalItem>(),
            updateLocalItem: i<UpdateLocalItem>(),
            deleteLocalItem: i<DeleteLocalItem>(),
            createBudgetRemoteItems: i<CreateBudgetItem>(),
          ),
        ),
        BlocBind.factory<CustomerSearchBloc>(
          (i) => CustomerSearchBloc(getCustomers: i<GetCustomers>()),
        ),
        BlocBind.factory<PaymentTypeBloc>(
          (i) => PaymentTypeBloc(getPaymentTypes: i<GetPaymentTypes>()),
        ),
        BlocBind.factory<ProductSearchBloc>(
          (i) => ProductSearchBloc(
            getProducts: i<GetProducts>(),
            getStockBalance: i<GetStockBalance>(),
            getPrices: i<GetPrices>(),
            getProductImages: i<GetProductImages>(),
          ),
        ),
      ];

  @override
  List<ModularRoute> get routes => [
        ChildRoute(
          '/',
          child: (_, __) => const BudgetListPage(),
        ),
      ];
}
