import 'package:core/core.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:http/http.dart' as http;
import 'package:modular_bloc_bind/modular_bloc_bind.dart';
import 'data/datasource/remote/stock_count_remote_datasource.dart';
import 'data/repository/stock_count_repository_impl.dart';
import 'domain/repository/stock_count_repository.dart';
import 'domain/usecase/stock_count_usecases.dart';
import 'presentation/bloc/stock_count_bloc.dart';
import 'presentation/page/stock_count_page.dart';

class StockCountModule extends Module {
  @override
  List<Bind> get binds => [
        // ── HTTP client ──────────────────────────────────────────────────
        Bind.factory<http.Client>((_) => http.Client()),

        // ── Datasource ───────────────────────────────────────────────────
        Bind.factory<StockCountRemoteDatasource>(
          (i) => StockCountRemoteDatasource(httpClient: i<http.Client>()),
        ),

        // ── Repository ───────────────────────────────────────────────────
        Bind.singleton<StockCountRepository>(
          (i) => StockCountRepositoryImpl(
            remote: i<StockCountRemoteDatasource>(),
          ),
        ),

        // ── Use cases ────────────────────────────────────────────────────
        Bind.factory((i) => GetStockLists(i<StockCountRepository>())),
        Bind.factory((i) => GetProductById(i<StockCountRepository>())),
        Bind.factory((i) => GetProductByBarcode(i<StockCountRepository>())),
        Bind.factory((i) => SearchProducts(i<StockCountRepository>())),
        Bind.factory((i) => GetStockBalance(i<StockCountRepository>())),
        Bind.factory((i) => GetPrices(i<StockCountRepository>())),
        Bind.factory((i) => AdjustStock(i<StockCountRepository>())),

        // ── Permission ───────────────────────────────────────────────────
        Bind.factory<PermissionRemoteDatasource>(
          (i) => PermissionRemoteDatasource(httpClient: i<http.Client>()),
        ),
        Bind.singleton<PermissionRepository>(
          (i) => PermissionRepositoryImpl(remote: i<PermissionRemoteDatasource>()),
        ),
        Bind.factory((i) => CheckPermission(i<PermissionRepository>())),
        BlocBind.singleton<PermissionCubit>(
          (i) => PermissionCubit(checkPermission: i<CheckPermission>()),
        ),

        // ── BLoC ─────────────────────────────────────────────────────────
        BlocBind.singleton<StockCountBloc>(
          (i) => StockCountBloc(
            getStockLists: i<GetStockLists>(),
            getProductById: i<GetProductById>(),
            getProductByBarcode: i<GetProductByBarcode>(),
            searchProducts: i<SearchProducts>(),
            getStockBalance: i<GetStockBalance>(),
            getPrices: i<GetPrices>(),
            adjustStock: i<AdjustStock>(),
          ),
        ),
      ];

  @override
  List<ModularRoute> get routes => [
        ChildRoute('/', child: (_, __) => const StockCountPage()),
      ];
}
