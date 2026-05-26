import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../domain/entity/product_entity.dart';
import '../../domain/usecase/stock_count_usecases.dart';

// ── Mini-BLoC para pesquisa de produtos ───────────────────────────────────────

class _ProductSearchState {
  const _ProductSearchState({
    this.products = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  final List<ProductEntity> products;
  final bool isLoading;
  final String? errorMessage;

  _ProductSearchState copyWith({
    List<ProductEntity>? products,
    bool? isLoading,
    String? errorMessage,
  }) => _ProductSearchState(
    products: products ?? this.products,
    isLoading: isLoading ?? this.isLoading,
    errorMessage: errorMessage,
  );
}

// ── Dialog ────────────────────────────────────────────────────────────────────

/// Diálogo de pesquisa de produto por descrição e código de fábrica.
/// Retorna o [ProductEntity] selecionado via [Navigator.pop] ou null se cancelado.
class ProductSearchDialog extends StatefulWidget {
  const ProductSearchDialog({super.key});

  @override
  State<ProductSearchDialog> createState() => _ProductSearchDialogState();
}

class _ProductSearchDialogState extends State<ProductSearchDialog> {
  final _descCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();

  late final SearchProducts _searchProducts;
  _ProductSearchState _state = const _ProductSearchState();

  @override
  void initState() {
    super.initState();
    _searchProducts = Modular.get<SearchProducts>();
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final desc = _descCtrl.text.trim();
    final code = _codeCtrl.text.trim();

    if (desc.isEmpty && code.isEmpty) return;

    setState(
      () => _state = _state.copyWith(isLoading: true, errorMessage: null),
    );

    final result = await _searchProducts(
      description: desc.isNotEmpty ? desc : null,
      codeFactory: code.isNotEmpty ? code : null,
    );

    result.fold(
      (failure) => setState(
        () => _state = _state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        ),
      ),
      (products) => setState(
        () => _state = _state.copyWith(isLoading: false, products: products),
      ),
    );
  }

  void _openBarcodeScanner() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _BarcodeScannerPage(
          onDetected: (code) async {
            setState(
              () =>
                  _state = _state.copyWith(isLoading: true, errorMessage: null),
            );
            final result = await _searchProducts(codeFactory: code);
            result.fold(
              (failure) => setState(
                () => _state = _state.copyWith(
                  isLoading: false,
                  errorMessage: failure.message,
                ),
              ),
              (products) => setState(
                () => _state = _state.copyWith(
                  isLoading: false,
                  products: products,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesquisa de Produto'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'código de barras',
            onPressed: _openBarcodeScanner,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: _descCtrl,
              decoration: const InputDecoration(
                labelText: 'Descrição',
                isDense: true,
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _search(),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _codeCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Código de Fábrica',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _search(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _state.isLoading ? null : _search,
                  icon: const Icon(Icons.search),
                  label: const Text('Buscar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    if (_state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_state.errorMessage != null) {
      return Center(child: Text(_state.errorMessage!));
    }
    if (_state.products.isEmpty) {
      return const Center(
        child: Text('Use os filtros para pesquisar produtos.'),
      );
    }
    return ListView.separated(
      itemCount: _state.products.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (ctx, i) {
        final p = _state.products[i];
        return ListTile(
          title: Text(
            p.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13),
          ),
          subtitle: Text(
            'Cód. Interno: ${p.id}  |  Fábrica: ${p.codeFactory}  |  Barras: ${p.codeBar}',
            style: const TextStyle(fontSize: 11),
          ),
          trailing: Text(
            p.measureAbbreviation,
            style: const TextStyle(fontSize: 12),
          ),
          onTap: () => Navigator.of(ctx).pop(p),
        );
      },
    );
  }
}

// ── Barcode Scanner ───────────────────────────────────────────────────────────

class _BarcodeScannerPage extends StatefulWidget {
  const _BarcodeScannerPage({required this.onDetected});

  final void Function(String code) onDetected;

  @override
  State<_BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<_BarcodeScannerPage> {
  bool _handled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Leitura de Código de Barras')),
      body: MobileScanner(
        onDetect: (capture) {
          if (_handled) return;
          final barcodes = capture.barcodes;
          if (barcodes.isNotEmpty) {
            final code = barcodes.first.rawValue ?? '';
            if (code.isNotEmpty) {
              _handled = true;
              widget.onDetected(code);
              Navigator.of(context).pop();
            }
          }
        },
      ),
    );
  }
}
