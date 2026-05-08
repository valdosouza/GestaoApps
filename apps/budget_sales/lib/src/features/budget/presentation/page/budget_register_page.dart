import 'package:core/shared/local_storage_key.dart';
import 'package:core/shared/helpers/local_storage.dart';
import 'package:budget_sales/src/features/budget/domain/entity/budget_entity.dart';
import 'package:budget_sales/src/features/budget/domain/entity/budget_item_entity.dart';
import 'package:budget_sales/src/features/budget/presentation/bloc/budget_register_bloc.dart';
import 'package:budget_sales/src/features/budget/presentation/bloc/budget_register_event.dart';
import 'package:budget_sales/src/features/budget/presentation/bloc/budget_register_state.dart';
import 'package:budget_sales/src/features/budget/presentation/page/budget_item_page.dart';
import 'package:budget_sales/src/features/budget/presentation/widget/customer_search_dialog.dart';
import 'package:budget_sales/src/features/budget/presentation/widget/payment_type_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:intl/intl.dart';

class BudgetRegisterPage extends StatefulWidget {
  const BudgetRegisterPage({
    super.key,
    this.remoteBudgetId,
    this.localBudgetId,
    this.bloc,
  });

  /// If set, we load an existing remote budget by this ID.
  final int? remoteBudgetId;

  /// If set, we open an existing local draft.
  final int? localBudgetId;

  /// Optional bloc for tests; when null, uses `Modular.get<BudgetRegisterBloc>()`.
  final BudgetRegisterBloc? bloc;

  @override
  State<BudgetRegisterPage> createState() => _BudgetRegisterPageState();
}

class _BudgetRegisterPageState extends State<BudgetRegisterPage> {
  late BudgetRegisterBloc _bloc;

  final _currencyFmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  @override
  void initState() {
    super.initState();
    _bloc = widget.bloc ?? Modular.get<BudgetRegisterBloc>();
    _init();
  }

  Future<void> _init() async {
    if (widget.remoteBudgetId != null && widget.remoteBudgetId! > 0) {
      _bloc.add(BudgetRegisterLoadRemote(budgetId: widget.remoteBudgetId!));
    } else if (widget.localBudgetId != null) {
      _bloc.add(BudgetRegisterLoadLocal(localId: widget.localBudgetId!));
    } else {
      // New budget
      final userId = await _readInt(LocalStorageKey.tbUserId);
      final salesmanId = await _readInt(LocalStorageKey.salesmanId);
      _bloc.add(BudgetRegisterStartNew(
        userId: userId,
        salesmanId: salesmanId,
      ));
    }
  }

  Future<int> _readInt(String key) async {
    final v = await LocalStorageService.instance.get(key: key, defaultValue: 0);
    if (v == null) return 0;
    return v is int ? v : int.tryParse(v.toString()) ?? 0;
  }

  void _openCustomerSearch(BudgetRegisterReady state) async {
    final customer = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const CustomerSearchDialog(),
        fullscreenDialog: true,
      ),
    );
    if (customer == null) return;
    final updated = state.budget.copyWith(
      customerId: customer.id,
      customerName: customer.name,
    );
    _bloc.add(BudgetRegisterUpdate(budget: updated));
    _bloc.add(BudgetRegisterSaveLocal(budget: updated));
  }

  void _openPaymentSearch(BudgetRegisterReady state) async {
    final payment = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const PaymentTypeDialog(),
        fullscreenDialog: true,
      ),
    );
    if (payment == null) return;
    final updated = state.budget.copyWith(
      paymentTypeId: payment.id,
      paymentTerms: payment.description,
    );
    _bloc.add(BudgetRegisterUpdate(budget: updated));
    _bloc.add(BudgetRegisterSaveLocal(budget: updated));
  }

  void _openAddItem(BudgetRegisterReady state) {
    Navigator.of(context)
        .push(MaterialPageRoute(
          builder: (_) => BudgetItemPage(
            localBudgetId: state.localId,
            registerBloc: _bloc,
          ),
        ))
        .then((_) =>
            _bloc.add(BudgetRegisterLoadItems(localBudgetId: state.localId)));
  }

  void _openEditItem(BudgetRegisterReady state, BudgetItemEntity item) {
    Navigator.of(context)
        .push(MaterialPageRoute(
          builder: (_) => BudgetItemPage(
            localBudgetId: state.localId,
            registerBloc: _bloc,
            item: item,
          ),
        ))
        .then((_) =>
            _bloc.add(BudgetRegisterLoadItems(localBudgetId: state.localId)));
  }

  void _confirmDeleteItem(BudgetRegisterReady state, BudgetItemEntity item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remover item?'),
        content: Text(item.description),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _bloc.add(BudgetRegisterDeleteItem(
                itemId: item.id,
                localBudgetId: state.localId,
              ));
            },
            child:
                const Text('Remover', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _confirmSubmit(BudgetRegisterReady state) {
    if (state.budget.customerId == 0 && state.budget.customerName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o cliente antes de enviar.')),
      );
      return;
    }
    if (state.budget.paymentTypeId == 0 || state.budget.paymentTerms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe a forma de pagamento antes de enviar.')),
      );
      return;
    }
    if (state.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Adicione ao menos um item antes de enviar.')),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Enviar para o sistema?'),
        content: const Text(
            'O orçamento será enviado para o servidor e removido do armazenamento local.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _bloc.add(BudgetRegisterSubmit(localBudgetId: state.localId));
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocConsumer<BudgetRegisterBloc, BudgetRegisterState>(
        listener: (ctx, state) {
          if (state is BudgetRegisterSubmitSuccess) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(
                content: Text(
                    'Orçamento ${state.remoteBudget.number} enviado com sucesso!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(ctx).pop(true);
          }
          if (state is BudgetRegisterError) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (ctx, state) {
          if (state is BudgetRegisterLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (state is BudgetRegisterReady) {
            return _buildReady(ctx, state);
          }
          if (state is BudgetRegisterError) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Orçamento'),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context, true),
                ),
              ),
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: Colors.red),
                    const SizedBox(height: 8),
                    Text(state.message, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _init,
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            );
          }
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }

  Widget _buildReady(BuildContext context, BudgetRegisterReady state) {
    final budget = state.budget;
    final isViewMode = widget.remoteBudgetId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(budget.number.isNotEmpty
            ? budget.number
            : isViewMode
                ? 'Visualizar Orçamento'
                : 'Novo Orçamento'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, true),
        ),
        actions: [
          if (state.isSaving)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2)),
            ),
          if (!isViewMode)
            IconButton(
              icon: const Icon(Icons.send),
              tooltip: 'Enviar para o sistema',
              onPressed: () => _confirmSubmit(state),
            ),
        ],
      ),
      floatingActionButton: isViewMode
          ? null
          : FloatingActionButton(
              onPressed: () => _openAddItem(state),
              child: const Icon(Icons.add),
            ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header card ──────────────────────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dados do Orçamento',
                        style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 12),

                    // Customer
                    Row(children: [
                      Expanded(
                        child: _ReadOnlyField(
                          label: 'Cliente',
                          value: budget.customerName.isNotEmpty
                              ? budget.customerName
                              : 'Não informado',
                        ),
                      ),
                      if (!isViewMode)
                        IconButton(
                          icon: const Icon(Icons.search),
                          tooltip: 'Buscar cliente',
                          onPressed: () => _openCustomerSearch(state),
                        ),
                    ]),

                    const SizedBox(height: 8),
                    // Payment type
                    Row(children: [
                      Expanded(
                        child: _ReadOnlyField(
                          label: 'Forma de Pagamento',
                          value: budget.paymentTerms.isNotEmpty
                              ? budget.paymentTerms
                              : 'Não informada',
                        ),
                      ),
                      if (!isViewMode)
                        IconButton(
                          icon: const Icon(Icons.search),
                          tooltip: 'Buscar pagamento',
                          onPressed: () => _openPaymentSearch(state),
                        ),
                    ]),

                    const SizedBox(height: 8),
                    Row(children: [
                      Expanded(
                        child: _ReadOnlyField(
                            label: 'Data', value: budget.date),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _ReadOnlyField(
                            label: 'Status', value: _statusLabel(budget.status)),
                      ),
                    ]),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Items ────────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Itens (${state.items.length})',
                    style: Theme.of(context).textTheme.titleSmall),
                if (!isViewMode)
                  TextButton.icon(
                    onPressed: () => _openAddItem(state),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Adicionar'),
                  ),
              ],
            ),

            if (state.items.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: Text('Nenhum item adicionado.')),
              )
            else
              ...state.items.map((item) => _ItemTile(
                    item: item,
                    currencyFmt: _currencyFmt,
                    isViewMode: isViewMode,
                    onEdit: () => _openEditItem(state, item),
                    onDelete: () => _confirmDeleteItem(state, item),
                  )),

            const Divider(height: 32),

            // ── Totals ───────────────────────────────────────────────────
            _TotalsCard(items: state.items, budget: budget, currencyFmt: _currencyFmt),

            if (!isViewMode) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _confirmSubmit(state),
                  icon: const Icon(Icons.send),
                  label: const Text('Enviar para o Sistema'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'N':
        return 'Normal';
      case 'C':
        return 'Cancelado';
      case 'F':
        return 'Faturado';
      default:
        return status;
    }
  }
}

// ── Supporting widgets ────────────────────────────────────────────────────────

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.grey[600])),
        const SizedBox(height: 2),
        Text(value,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _ItemTile extends StatelessWidget {
  const _ItemTile({
    required this.item,
    required this.currencyFmt,
    required this.isViewMode,
    required this.onEdit,
    required this.onDelete,
  });

  final BudgetItemEntity item;
  final NumberFormat currencyFmt;
  final bool isViewMode;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text(item.description,
            maxLines: 2, overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13)),
        subtitle: Text(
          '${item.quantity.toStringAsFixed(3)} x ${currencyFmt.format(item.unitPrice)}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              currencyFmt.format(item.subtotal),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            if (item.discountValue > 0)
              Text(
                '- ${currencyFmt.format(item.discountValue)}',
                style: const TextStyle(fontSize: 11, color: Colors.red),
              ),
          ],
        ),
        onTap: isViewMode ? null : onEdit,
        onLongPress: isViewMode ? null : onDelete,
      ),
    );
  }
}

class _TotalsCard extends StatelessWidget {
  const _TotalsCard({
    required this.items,
    required this.budget,
    required this.currencyFmt,
  });

  final List<BudgetItemEntity> items;
  final BudgetEntity budget;
  final NumberFormat currencyFmt;

  @override
  Widget build(BuildContext context) {
    double totalProducts = 0;
    double totalDiscount = 0;
    for (final item in items) {
      totalProducts += item.subtotal;
      totalDiscount += item.discountValue;
    }
    final subtotal = totalProducts - totalDiscount;
    final total = subtotal + budget.freight;

    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _TotalRow('Produtos',
                currencyFmt.format(totalProducts), false),
            if (budget.freight > 0)
              _TotalRow('Frete', currencyFmt.format(budget.freight), false),
            if (totalDiscount > 0)
              _TotalRow('Desconto',
                  '- ${currencyFmt.format(totalDiscount)}', false),
            const Divider(),
            _TotalRow('Total', currencyFmt.format(total), true),
          ],
        ),
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow(this.label, this.value, this.isTotal);

  final String label;
  final String value;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: isTotal
                  ? Theme.of(context).textTheme.titleMedium
                  : Theme.of(context).textTheme.bodyMedium),
          Text(
            value,
            style: isTotal
                ? Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    )
                : Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
