import 'package:flutter_modular/flutter_modular.dart';
import 'package:modular_bloc_bind/modular_bloc_bind.dart';
import 'presentation/bloc/stock_count_bloc.dart';
import 'presentation/page/stock_count_page.dart';

class StockCountModule extends Module {
  @override
  List<Bind> get binds => [
        BlocBind.singleton((i) => StockCountBloc()),
      ];

  @override
  List<ModularRoute> get routes => [
        ChildRoute('/', child: (_, __) => const StockCountPage()),
      ];
}
