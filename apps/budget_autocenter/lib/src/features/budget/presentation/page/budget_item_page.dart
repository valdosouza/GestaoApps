import 'package:budget_autocenter/src/features/budget/domain/entity/budget_item_entity.dart';
import 'package:budget_autocenter/src/features/budget/domain/entity/product_entity.dart';
import 'package:budget_autocenter/src/features/budget/presentation/bloc/budget_register_bloc.dart';
import 'package:budget_autocenter/src/features/budget/presentation/bloc/budget_register_event.dart';
import 'package:budget_autocenter/src/features/budget/presentation/bloc/budget_register_state.dart';
import 'package:budget_autocenter/src/features/budget/presentation/widget/product_search_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class BudgetItemPage extends StatefulWidget {
  const BudgetItemPage({
    super.key,
    required this.localBudgetId,
    required this.registerBloc,
    this.item,
  });

  final int localBudgetId;
  final BudgetRegisterBloc registerBloc;

  /// If null, creating a new item. Otherwise editing existing.
  final BudgetItemEntity? item;

  @override
  State<BudgetItemPage> createState() => _BudgetItemPageState();
}

class _BudgetItemPageState extends State<BudgetItemPage> {
  final _formKey = GlobalKey<FormState>();

  ProductEntity? _selectedProduct;
  StockBalanceEntity? _selectedStock;
  PriceListEntity? _selectedPrice;

  final _descCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController(text: '1');
  final _priceCtrl = TextEditingController();
  final _discValueCtrl = TextEditingController(text: '0');
  final _discPercentCtrl = TextEditingController(text: '0');

  int _productId = 0;
  int _stockId = 0;
  int _priceListId = 0;

  final _currencyFmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  bool get _isEditing => widget.item != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final item = widget.item!;
      _productId = item.productId;
      _stockId = item.stockId;
      _priceListId = item.priceListId;
      _descCtrl.text = item.description;
      _qtyCtrl.text = item.quantity.toStringAsFixed(3);
      _priceCtrl.text = item.unitPrice.toStringAsFixed(2);
      _discValueCtrl.text = item.discountValue.toStringAsFixed(2);
      _discPercentCtrl.text = item.discountPercent.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _qtyCtrl.dispose();
    _priceCtrl.dispose();
    _discValueCtrl.dispose();
    _discPercentCtrl.dispose();
    super.dispose();
  }

  double get _qty => double.tryParse(_qtyCtrl.text.replaceAll(',', '.')) ?? 0;
  double get _unitPrice =>
      double.tryParse(_priceCtrl.text.replaceAll(',', '.')) ?? 0;
  double get _discValue =>
      double.tryParse(_discValueCtrl.text.replaceAll(',', '.')) ?? 0;
  double get _discPercent =>
      double.tryParse(_discPercentCtrl.text.replaceAll(',', '.')) ?? 0;
  double get _subtotal => (_qty * _unitPrice) - _discValue;

  Future<void> _openProductSearch() async {
    final result = await Navigator.of(context).push<ProductSelection>(
      MaterialPageRoute(
        builder: (_) => const ProductSearchDialog(),
        fullscreenDialog: true,
      ),
    );
    if (result == null) return;
    setState(() {
      _selectedProduct = result.product;
      _selectedStock = result.stockBalance;
      _selectedPrice = result.priceList;

      _productId = result.product.id;
      _stockId = result.stockBalance.id == 0
          ? 0
          : result.stockBalance.stockListId;
      _priceListId = result.priceList.priceListId;

      _descCtrl.text = result.product.description;
      _priceCtrl.text = result.priceList.salePrice.toStringAsFixed(2);
      _discValueCtrl.text = '0.00';
      _discPercentCtrl.text = '0.00';
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    if (_productId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um produto antes de salvar.')),
      );
      return;
    }

    if (_priceListId == 0 || _unitPrice <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Selecione uma tabela de preço com valor maior que zero.')),
      );
      return;
    }

    final newItem = (_isEditing ? widget.item! : BudgetItemEntity.empty())
        .copyWith(
          budgetId: widget.localBudgetId,
          productId: _productId,
          description: _descCtrl.text.trim(),
          quantity: _qty,
          unitPrice: _unitPrice,
          discountValue: _discValue,
          discountPercent: _discPercent,
          stockId: _stockId,
          priceListId: _priceListId,
          type: 'P',
        );

    widget.registerBloc.add(BudgetRegisterSaveItem(
      item: newItem,
      isNew: !_isEditing,
    ));

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BudgetRegisterBloc, BudgetRegisterState>(
      bloc: widget.registerBloc,
      listener: (ctx, state) {
        if (state is BudgetRegisterError) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? 'Editar Item' : 'Novo Item'),
          actions: [
            IconButton(
              icon: const Icon(Icons.check),
              tooltip: 'Salvar',
              onPressed: _save,
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product selector
                Row(children: [
                  Expanded(
                    child: TextFormField(
                      controller: _descCtrl,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Produto *',
                        border: OutlineInputBorder(),
                        hintText: 'Toque em "Buscar" para selecionar',
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Selecione um produto' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _openProductSearch,
                    icon: const Icon(Icons.search),
                    label: const Text('Buscar'),
                  ),
                ]),

                if (_selectedProduct != null) ...[
                  const SizedBox(height: 8),
                  _InfoChip(
                    label: 'Estoque',
                    value: _selectedStock != null && _selectedStock!.id != 0
                        ? '${_selectedStock!.stockListDesc}: ${_selectedStock!.quantity.toStringAsFixed(2)}'
                        : 'Não verificado',
                    color: Colors.blue.shade50,
                  ),
                  const SizedBox(height: 4),
                  _InfoChip(
                    label: 'Tabela preço',
                    value: _selectedPrice != null && _selectedPrice!.id != 0
                        ? '${_selectedPrice!.priceListName}: ${_currencyFmt.format(_selectedPrice!.salePrice)}'
                        : 'Nenhuma',
                    color: Colors.green.shade50,
                  ),
                ],

                const SizedBox(height: 16),
                // Quantity
                TextFormField(
                  controller: _qtyCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.,]'))
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Quantidade *',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Informe a quantidade';
                    final d = double.tryParse(v.replaceAll(',', '.'));
                    if (d == null || d <= 0) return 'Quantidade inválida';
                    return null;
                  },
                ),

                const SizedBox(height: 16),
                // Unit price
                TextFormField(
                  controller: _priceCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.,]'))
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Preço unitário *',
                    border: OutlineInputBorder(),
                    prefixText: 'R\$ ',
                  ),
                  onChanged: (_) => setState(() {}),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Informe o preço';
                    final d = double.tryParse(v.replaceAll(',', '.'));
                    if (d == null || d <= 0) return 'Preço inválido';
                    return null;
                  },
                ),

                const SizedBox(height: 16),
                Row(children: [
                  Expanded(
                    child: TextFormField(
                      controller: _discValueCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[\d.,]'))
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Desconto (R\$)',
                        border: OutlineInputBorder(),
                        prefixText: 'R\$ ',
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _discPercentCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[\d.,]'))
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Desconto (%)',
                        border: OutlineInputBorder(),
                        suffixText: '%',
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ]),

                const SizedBox(height: 24),
                // Subtotal
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Subtotal',
                          style: Theme.of(context).textTheme.titleMedium),
                      Text(
                        _currencyFmt.format(_subtotal),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.save),
                    label: const Text('Salvar Item'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip(
      {required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(180)),
      ),
      child: Row(
        children: [
          Text('$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          Expanded(
              child: Text(value,
                  style: const TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}
