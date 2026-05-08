import 'dart:convert';

import 'package:budget_autocenter/src/features/budget/domain/entity/product_entity.dart';
import 'package:budget_autocenter/src/features/budget/presentation/bloc/product_search_bloc.dart';
import 'package:budget_autocenter/src/features/budget/presentation/bloc/product_search_event.dart';
import 'package:budget_autocenter/src/features/budget/presentation/bloc/product_search_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Result returned when a product + stock + price are confirmed.
class ProductSelection {
  const ProductSelection({
    required this.product,
    required this.stockBalance,
    required this.priceList,
  });

  final ProductEntity product;
  final StockBalanceEntity stockBalance;
  final PriceListEntity priceList;
}

/// Full-screen product search dialog with tabbed detail view.
/// Returns a [ProductSelection] via [Navigator.pop] or null if cancelled.
class ProductSearchDialog extends StatefulWidget {
  const ProductSearchDialog({super.key, this.bloc});

  /// Optional bloc for tests; when null, uses `Modular.get<ProductSearchBloc>()`.
  final ProductSearchBloc? bloc;

  @override
  State<ProductSearchDialog> createState() => _ProductSearchDialogState();
}

class _ProductSearchDialogState extends State<ProductSearchDialog>
    with SingleTickerProviderStateMixin {
  late ProductSearchBloc _bloc;
  late TabController _tabController;

  final _descCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _barCtrl = TextEditingController();
  final _groupCtrl = TextEditingController();

  bool _showFilters = false;
  StockBalanceEntity? _selectedStock;
  PriceListEntity? _selectedPrice;
  final _currencyFmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  @override
  void initState() {
    super.initState();
    _bloc = widget.bloc ?? Modular.get<ProductSearchBloc>();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _descCtrl.dispose();
    _codeCtrl.dispose();
    _barCtrl.dispose();
    _groupCtrl.dispose();
    super.dispose();
  }

  void _search() {
    final code = _codeCtrl.text.trim();
    final bar = _barCtrl.text.trim();
    final parsed = int.tryParse(code);
    final isProductId = parsed != null && parsed > 0 && parsed <= 2147483647;

    _bloc.add(ProductSearchLoad(
      codeBar: bar.isNotEmpty ? bar : null,
      id: (bar.isEmpty && isProductId) ? parsed : null,
      codeFactory: (bar.isEmpty && !isProductId && code.isNotEmpty) ? code : null,
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      groupDescription:
          _groupCtrl.text.trim().isEmpty ? null : _groupCtrl.text.trim(),
    ));
  }

  void _selectProduct(ProductEntity product) {
    setState(() {
      _selectedStock = null;
      _selectedPrice = null;
    });
    _bloc.add(ProductSearchLoadStock(productId: product.id));
    _bloc.add(ProductSearchLoadPrices(productId: product.id));
    _tabController.animateTo(1);
  }

  void _openBarcodeScanner() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => _BarcodeScannerPage(
        onDetected: (code) {
          _barCtrl.text = code;
          _bloc.add(ProductSearchLoad(codeBar: code));
        },
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pesquisa de Produto'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.search), text: 'Lista'),
              Tab(icon: Icon(Icons.info_outline), text: 'Detalhes'),
              Tab(icon: Icon(Icons.inventory_2_outlined), text: 'Estoque'),
              Tab(icon: Icon(Icons.attach_money), text: 'Preços'),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(_showFilters ? Icons.filter_list_off : Icons.filter_list),
              onPressed: () => setState(() => _showFilters = !_showFilters),
            ),
            IconButton(
              icon: const Icon(Icons.qr_code_scanner),
              tooltip: 'Ler código de barras',
              onPressed: _openBarcodeScanner,
            ),
          ],
        ),
        body: Column(
          children: [
            if (_showFilters) _buildFilters(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildProductList(),
                  _buildDetailsTab(),
                  _buildStockTab(),
                  _buildPriceTab(),
                ],
              ),
            ),
            BlocBuilder<ProductSearchBloc, ProductSearchState>(
              builder: (ctx, state) {
                final detail =
                    state is ProductSearchDetailLoaded ? state : null;
                final canSelect = detail != null &&
                    _selectedStock != null &&
                    _selectedPrice != null;
                return Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: ElevatedButton.icon(
                    onPressed: canSelect
                        ? () => Navigator.of(ctx).pop(ProductSelection(
                              product: detail.selectedProduct,
                              stockBalance: _selectedStock!,
                              priceList: _selectedPrice!,
                            ))
                        : null,
                    icon: const Icon(Icons.add_shopping_cart),
                    label: const Text('Selecionar Item'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
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
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _codeCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Código / Fábrica',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _search(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _groupCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Grupo',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _search(),
                ),
              ),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _barCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Código de Barras',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onSubmitted: (_) => _search(),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _search,
                icon: const Icon(Icons.search),
                label: const Text('Buscar'),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildProductList() {
    return BlocBuilder<ProductSearchBloc, ProductSearchState>(
      builder: (context, state) {
        if (state is ProductSearchLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is ProductSearchError) {
          return Center(child: Text(state.message));
        }
        List<ProductEntity> products = [];
        if (state is ProductSearchLoaded) products = state.products;
        if (state is ProductSearchDetailLoaded) products = state.products;

        if (products.isEmpty && state is! ProductSearchInitial) {
          return const Center(child: Text('Nenhum produto encontrado.'));
        }
        if (state is ProductSearchInitial) {
          return const Center(child: Text('Use os filtros para pesquisar.'));
        }

        return ListView.separated(
          itemCount: products.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (ctx, i) {
            final p = products[i];
            final isSelected = state is ProductSearchDetailLoaded &&
                state.selectedProduct.id == p.id;
            return ListTile(
              selected: isSelected,
              selectedTileColor:
                  Theme.of(context).colorScheme.primaryContainer.withAlpha(80),
              title: Text(p.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13)),
              subtitle: Text('${p.codeFactory}  |  ${p.groupDescription}',
                  style: const TextStyle(fontSize: 11)),
              trailing: Text(p.measureAbbreviation,
                  style: const TextStyle(fontSize: 12)),
              onTap: () => _selectProduct(p),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailsTab() {
    return BlocBuilder<ProductSearchBloc, ProductSearchState>(
      builder: (context, state) {
        if (state is! ProductSearchDetailLoaded) {
          return const Center(
              child: Text('Selecione um produto na aba Lista.'));
        }
        final p = state.selectedProduct;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(p.description,
                  style: Theme.of(context).textTheme.titleMedium),
              const Divider(),
              _DetailRow('Código interno', p.id.toString()),
              _DetailRow('Código fábrica', p.codeFactory),
              _DetailRow('Código fornecedor', p.codeSupplier),
              _DetailRow('Código barras', p.codeBar),
              _DetailRow('Grupo', p.groupDescription),
              _DetailRow('Subgrupo', p.subgroupDescription),
              _DetailRow('Marca', p.brandDescription),
              _DetailRow('Localização', p.location),
              _DetailRow('Unidade',
                  '${p.measureDescription} (${p.measureAbbreviation})'),
              _DetailRow('Peso', '${p.weight} kg'),
              _DetailRow('Subst. tributária',
                  p.taxSubstitution == 'S' ? 'Sim' : 'Não'),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  _bloc.add(ProductSearchLoadImages(productId: p.id));
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: _bloc,
                      child: const _ProductImagesPage(),
                    ),
                  ));
                },
                icon: const Icon(Icons.image_outlined),
                label: const Text('Ver Imagem'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStockTab() {
    return BlocBuilder<ProductSearchBloc, ProductSearchState>(
      builder: (context, state) {
        if (state is! ProductSearchDetailLoaded) {
          return const Center(
              child: Text('Selecione um produto na aba Lista.'));
        }
        if (state.isLoadingDetail && state.stockList.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.stockList.isEmpty) {
          return const Center(child: Text('Sem estoque disponível.'));
        }
        return RadioGroup<StockBalanceEntity>(
          groupValue: _selectedStock,
          onChanged: (v) => setState(() => _selectedStock = v),
          child: ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: state.stockList.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (ctx, i) {
              final s = state.stockList[i];
              final positive = s.quantity > 0;
              return RadioListTile<StockBalanceEntity>(
                value: s,
                title: Text(s.stockListDesc),
                secondary: Text(
                  s.quantity.toStringAsFixed(2),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: positive ? Colors.green[700] : Colors.red[700],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildPriceTab() {
    return BlocBuilder<ProductSearchBloc, ProductSearchState>(
      builder: (context, state) {
        if (state is! ProductSearchDetailLoaded) {
          return const Center(
              child: Text('Selecione um produto na aba Lista.'));
        }
        if (state.isLoadingDetail && state.priceList.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.priceList.isEmpty) {
          return const Center(child: Text('Sem tabela de preço disponível.'));
        }
        return RadioGroup<PriceListEntity>(
          groupValue: _selectedPrice,
          onChanged: (v) => setState(() => _selectedPrice = v),
          child: ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: state.priceList.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (ctx, i) {
              final price = state.priceList[i];
              final enabled = price.salePrice > 0;
              return RadioListTile<PriceListEntity>(
                value: price,
                enabled: enabled,
                title: Text(price.priceListName),
                secondary: Text(
                  _currencyFmt.format(price.salePrice),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: enabled
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Product Images Page ───────────────────────────────────────────────────────

class _ProductImagesPage extends StatefulWidget {
  const _ProductImagesPage();

  @override
  State<_ProductImagesPage> createState() => _ProductImagesPageState();
}

class _ProductImagesPageState extends State<_ProductImagesPage> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Imagens do Produto')),
      body: BlocBuilder<ProductSearchBloc, ProductSearchState>(
        builder: (context, state) {
          if (state is! ProductSearchDetailLoaded) {
            return const Center(child: Text('Nenhum produto selecionado.'));
          }
          if (state.isLoadingDetail && state.images.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.images.isEmpty) {
            return const Center(child: Text('Sem imagens disponíveis.'));
          }
          final images = state.images;
          return Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: images.length,
                  onPageChanged: (p) => setState(() => _currentPage = p),
                  itemBuilder: (_, index) =>
                      _buildImage(images[index].imageUrl),
                ),
              ),
              if (images.length > 1)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton.outlined(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: _currentPage > 0
                            ? () => _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut)
                            : null,
                      ),
                      Text('${_currentPage + 1} / ${images.length}'),
                      IconButton.outlined(
                        icon: const Icon(Icons.arrow_forward),
                        onPressed: _currentPage < images.length - 1
                            ? () => _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut)
                            : null,
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildImage(String imageUrl) {
    if (imageUrl.startsWith('data:')) {
      final comma = imageUrl.indexOf(',');
      if (comma >= 0) {
        try {
          final bytes = base64Decode(imageUrl.substring(comma + 1));
          return InteractiveViewer(
            child: Center(child: Image.memory(bytes, fit: BoxFit.contain)),
          );
        } catch (_) {}
      }
    }
    if (imageUrl.startsWith('http')) {
      return InteractiveViewer(
        child: Center(child: Image.network(imageUrl, fit: BoxFit.contain)),
      );
    }
    return const Center(child: Text('Imagem não disponível.'));
  }
}

// ── Barcode Scanner Page ──────────────────────────────────────────────────────

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
