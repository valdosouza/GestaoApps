import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../domain/entity/product_entity.dart';
import '../../domain/entity/stock_list_entity.dart';
import '../bloc/stock_count_bloc.dart';
import '../widget/product_search_dialog.dart';

class StockCountPage extends StatefulWidget {
  const StockCountPage({super.key});

  @override
  State<StockCountPage> createState() => _StockCountPageState();
}

const _kPermissionMenu = 'TFr_estoque_manual';

class _StockCountPageState extends State<StockCountPage> {
  late final StockCountBloc _bloc;
  late final PermissionCubit _permissionCubit;
  final _codeCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController();
  final _currencyFmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  final _qtyFmt = NumberFormat('#,##0.##', 'pt_BR');

  bool _scannerActive = false;

  @override
  void initState() {
    super.initState();
    _bloc = Modular.get<StockCountBloc>();
    _permissionCubit = Modular.get<PermissionCubit>();
    _permissionCubit.check(
      menu: _kPermissionMenu,
      kind: 'Incluir',
      situation: 'S',
    );
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _quantityCtrl.dispose();
    super.dispose();
  }

  void _searchById() {
    final text = _codeCtrl.text.trim();
    if (text.isEmpty) return;
    final id = int.tryParse(text);
    if (id != null && id > 0) {
      _bloc.add(StockCountSearchByIdEvent(id));
    } else {
      _showSnackBar('Digite um código interno numérico válido.', isError: true);
    }
  }

  void _openBarcodeScanner() {
    setState(() => _scannerActive = true);
  }

  void _openProductSearch() async {
    final product = await Navigator.of(context).push<ProductEntity>(
      MaterialPageRoute(
        builder: (_) => const ProductSearchDialog(),
        fullscreenDialog: true,
      ),
    );
    if (product != null) {
      _bloc.add(StockCountProductPickedEvent(product));
    }
  }

  void _adjustStock() {
    final text = _quantityCtrl.text.trim().replaceAll(',', '.');
    final qty = double.tryParse(text);
    if (qty == null || qty < 0) {
      _showSnackBar('Informe uma quantidade válida.', isError: true);
      return;
    }
    _bloc.add(StockCountAdjustStockEvent(qty));
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PermissionCubit, PermissionState>(
      bloc: _permissionCubit,
      listenWhen: (prev, curr) =>
          curr.status == PermissionStatus.granted &&
          prev.status != PermissionStatus.granted,
      listener: (context, _) {
        _bloc.add(const StockCountLoadListsEvent());
      },
      child: BlocBuilder<PermissionCubit, PermissionState>(
        bloc: _permissionCubit,
        builder: (context, permState) {
          if (permState.status == PermissionStatus.initial ||
              permState.status == PermissionStatus.loading) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: Colors.green),
                    const SizedBox(height: 16),
                    const Text(
                      'Verificando permissões...',
                      style: TextStyle(fontFamily: 'OpenSans'),
                    ),
                  ],
                ),
              ),
            );
          }
          if (permState.status == PermissionStatus.denied) {
            return const UnauthorizedPage();
          }
          if (permState.status == PermissionStatus.error) {
            return Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Erro ao verificar permissão:\n${permState.errorMessage}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontFamily: 'OpenSans'),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => _permissionCubit.check(
                          menu: _kPermissionMenu,
                          kind: 'Incluir',
                          situation: 'S',
                        ),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Tentar Novamente'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          // PermissionStatus.granted → conteúdo principal
          return _buildMainContent();
        },
      ),
    );
  }

  Widget _buildMainContent() {
    return BlocConsumer<StockCountBloc, StockCountState>(
      bloc: _bloc,
      listener: (context, state) {
        if (state is StockCountAdjustmentSuccessState) {
          _quantityCtrl.clear();
          _showSnackBar('Saldo atualizado com sucesso!');
          _bloc.add(const StockCountClearProductEvent());
        }
        if (state is StockCountProductLoadedState &&
            state.infoMessage != null) {
          _showSnackBar(
            state.infoMessage!,
            isError: state.infoMessage!.startsWith('Erro'),
          );
        }
      },
      builder: (context, state) {
        if (_scannerActive) {
          return _buildScannerOverlay();
        }
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
          body: _buildBody(state),
        );
      },
    );
  }

  Widget _buildBody(StockCountState state) {
    if (state is StockCountInitialState || state is StockCountLoadingState) {
      final msg = state is StockCountLoadingState
          ? state.message
          : 'Carregando...';
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Colors.green),
            const SizedBox(height: 16),
            Text(msg, style: const TextStyle(fontFamily: 'OpenSans')),
          ],
        ),
      );
    }

    if (state is StockCountErrorState) {
      return _buildErrorState(state);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildStockListSelector(state),
          const SizedBox(height: 12),
          _buildProductSearch(state),
          if (state is StockCountProductLoadedState) ...[
            const SizedBox(height: 12),
            _buildProductInfo(state.product),
            const SizedBox(height: 12),
            _buildCurrentBalance(state.currentBalance),
            if (state.prices.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildPriceTable(state.prices),
            ],
            const SizedBox(height: 12),
            _buildAdjustmentSection(state),
          ],
        ],
      ),
    );
  }

  // ── Seleção de estoque ────────────────────────────────────────────────────

  Widget _buildStockListSelector(StockCountState state) {
    List<StockListEntity> lists = [];
    StockListEntity? selected;

    if (state is StockCountReadyState) {
      lists = state.stockLists;
      selected = state.selectedStockList;
    } else if (state is StockCountProductLoadedState) {
      lists = state.stockLists;
      selected = state.selectedStockList;
    } else if (state is StockCountAdjustmentSuccessState) {
      lists = state.stockLists;
      selected = state.selectedStockList;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: InputDecorator(
          decoration: const InputDecoration(
            labelText: 'Estoque',
            border: InputBorder.none,
            isDense: true,
          ),
          child: DropdownButton<StockListEntity>(
            value: selected,
            hint: const Text('Selecione o estoque'),
            isExpanded: true,
            underline: const SizedBox(),
            items: lists
                .map(
                  (l) => DropdownMenuItem(value: l, child: Text(l.description)),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                _bloc.add(StockCountSelectStockListEvent(value));
              }
            },
          ),
        ),
      ),
    );
  }

  // ── Busca de produto ──────────────────────────────────────────────────────

  Widget _buildProductSearch(StockCountState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Buscar Produto',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'OpenSans',
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _codeCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Código Interno',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _searchById(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _searchById,
                  icon: const Icon(Icons.search, size: 18),
                  label: const Text('Buscar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _openBarcodeScanner,
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text('Código de Barras'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _openProductSearch,
                    icon: const Icon(Icons.list_alt),
                    label: const Text('Pesquisar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Dados do produto ──────────────────────────────────────────────────────

  Widget _buildProductInfo(ProductEntity product) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              product.description,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                fontFamily: 'OpenSans',
              ),
            ),
            const Divider(),
            _InfoRow('Código Interno', product.id.toString()),
            _InfoRow('Código de Fábrica', product.codeFactory),
            _InfoRow('Código de Barras', product.codeBar),
            _InfoRow('Unidade', product.measureAbbreviation),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentBalance(double balance) {
    final color = balance > 0 ? Colors.green.shade700 : Colors.red.shade700;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Saldo Atual',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontFamily: 'OpenSans',
              ),
            ),
            Text(
              _qtyFmt.format(balance),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceTable(List<PriceListEntity> prices) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Tabelas de Preço',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'OpenSans',
              ),
            ),
            const Divider(),
            ...prices.map(
              (p) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        p.priceListName,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    Text(
                      _currencyFmt.format(p.salePrice),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Ajuste de saldo ───────────────────────────────────────────────────────

  Widget _buildAdjustmentSection(StockCountProductLoadedState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Informar Quantidade',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'OpenSans',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _quantityCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d,.]')),
              ],
              decoration: const InputDecoration(
                labelText: 'Quantidade Atual',
                isDense: true,
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.edit),
              ),
              onSubmitted: (_) => _adjustStock(),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: state.isAdjusting ? null : _adjustStock,
              icon: state.isAdjusting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.update),
              label: Text(
                state.isAdjusting ? 'Atualizando...' : 'Atualizar Saldo',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'OpenSans',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Estado de erro ────────────────────────────────────────────────────────

  Widget _buildErrorState(StockCountErrorState state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontFamily: 'OpenSans'),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _bloc.add(const StockCountLoadListsEvent()),
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar Novamente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Scanner overlay ───────────────────────────────────────────────────────

  Widget _buildScannerOverlay() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leitura de Código de Barras'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => setState(() => _scannerActive = false),
        ),
      ),
      body: MobileScanner(
        onDetect: (capture) {
          final barcodes = capture.barcodes;
          if (barcodes.isNotEmpty) {
            final code = barcodes.first.rawValue ?? '';
            if (code.isNotEmpty) {
              setState(() => _scannerActive = false);
              _bloc.add(StockCountSearchByBarcodeEvent(code));
            }
          }
        },
      ),
    );
  }
}

// ── Auxiliar ──────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontFamily: 'OpenSans',
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: const TextStyle(fontSize: 13, fontFamily: 'OpenSans'),
            ),
          ),
        ],
      ),
    );
  }
}
