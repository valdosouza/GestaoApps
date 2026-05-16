import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '../bloc/stock_count_bloc.dart';

/// Tela principal da Contagem de Estoque.
/// Em branco — funcionalidades serão implementadas na próxima etapa.
class StockCountPage extends StatefulWidget {
  const StockCountPage({super.key});

  @override
  State<StockCountPage> createState() => _StockCountPageState();
}

class _StockCountPageState extends State<StockCountPage> {
  late final StockCountBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = Modular.get<StockCountBloc>();
    _bloc.add(const StockCountStarted());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StockCountBloc, StockCountState>(
      bloc: _bloc,
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Contagem de Estoque',
              style: TextStyle(fontFamily: 'OpenSans'),
            ),
            backgroundColor: Colors.green.shade700,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Sair',
                onPressed: () => Modular.to.navigate('/auth/'),
              ),
            ],
          ),
          body: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2_outlined, size: 72, color: Colors.green),
                SizedBox(height: 24),
                Text(
                  'Contagem de Estoque',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'OpenSans',
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Funcionalidades em desenvolvimento',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontFamily: 'OpenSans',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
