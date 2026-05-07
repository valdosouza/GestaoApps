import 'package:budget_sales/src/features/budget/domain/entity/budget_entity.dart';
import 'package:budget_sales/src/features/budget/presentation/bloc/budget_list_bloc.dart';
import 'package:budget_sales/src/features/budget/presentation/bloc/budget_list_event.dart';
import 'package:budget_sales/src/features/budget/presentation/bloc/budget_list_state.dart';
import 'package:budget_sales/src/features/budget/presentation/page/budget_register_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:intl/intl.dart';

class BudgetListPage extends StatefulWidget {
  const BudgetListPage({super.key, this.bloc});

  /// Optional bloc for tests; when null, uses `Modular.get<BudgetListBloc>()`.
  final BudgetListBloc? bloc;

  @override
  State<BudgetListPage> createState() => _BudgetListPageState();
}

class _BudgetListPageState extends State<BudgetListPage> {
  late BudgetListBloc _bloc;

  // Filter controllers
  final _numberCtrl = TextEditingController();
  final _customerCtrl = TextEditingController();
  final _dateStartCtrl = TextEditingController();
  final _dateEndCtrl = TextEditingController();
  bool _showFilters = false;

  final _currencyFmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  @override
  void initState() {
    super.initState();
    _bloc = widget.bloc ?? Modular.get<BudgetListBloc>();
    _bloc.add(const BudgetListLoad());
  }

  @override
  void dispose() {
    _numberCtrl.dispose();
    _customerCtrl.dispose();
    _dateStartCtrl.dispose();
    _dateEndCtrl.dispose();
    super.dispose();
  }

  void _applyFilters() {
    _bloc.add(BudgetListLoad(
      number: _numberCtrl.text.trim().isEmpty ? null : _numberCtrl.text.trim(),
      dateStart: _dateStartCtrl.text.trim().isEmpty
          ? null
          : _dateStartCtrl.text.trim(),
      dateEnd:
          _dateEndCtrl.text.trim().isEmpty ? null : _dateEndCtrl.text.trim(),
      customerName: _customerCtrl.text.trim().isEmpty
          ? null
          : _customerCtrl.text.trim(),
    ));
  }

  void _clearFilters() {
    _numberCtrl.clear();
    _customerCtrl.clear();
    _dateStartCtrl.clear();
    _dateEndCtrl.clear();
    _bloc.add(const BudgetListClearFilter());
  }

  Future<void> _pickDate(TextEditingController ctrl) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      ctrl.text =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
    }
  }

  void _openRegister({BudgetEntity? budget}) {
    Navigator.of(context)
        .push(MaterialPageRoute(
          builder: (_) => BudgetRegisterPage(remoteBudgetId: budget?.id),
        ))
        .then((result) {
          if (result == true || result == null) {
            _bloc.add(const BudgetListLoad());
          }
        });
  }

  void _openLocalDraft(int localId) {
    Navigator.of(context)
        .push(MaterialPageRoute(
          builder: (_) => BudgetRegisterPage(localBudgetId: localId),
        ))
        .then((result) {
          if (result == true || result == null) {
            _bloc.add(const BudgetListLoad());
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Orçamentos'),
          actions: [
            IconButton(
              icon: Icon(
                  _showFilters ? Icons.filter_list_off : Icons.filter_list),
              tooltip: 'Filtros',
              onPressed: () => setState(() => _showFilters = !_showFilters),
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Atualizar',
              onPressed: _applyFilters,
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _openRegister(),
          icon: const Icon(Icons.add),
          label: const Text('Novo'),
        ),
        body: Column(
          children: [
            if (_showFilters) _buildFilters(),
            Expanded(child: _buildList()),
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
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _numberCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Número',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _customerCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Cliente',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _dateStartCtrl,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Data inicial',
                    isDense: true,
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today, size: 16),
                  ),
                  onTap: () => _pickDate(_dateStartCtrl),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _dateEndCtrl,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Data final',
                    isDense: true,
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today, size: 16),
                  ),
                  onTap: () => _pickDate(_dateEndCtrl),
                ),
              ),
            ]),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              TextButton.icon(
                onPressed: _clearFilters,
                icon: const Icon(Icons.clear),
                label: const Text('Limpar'),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _applyFilters,
                icon: const Icon(Icons.search),
                label: const Text('Buscar'),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    return BlocBuilder<BudgetListBloc, BudgetListState>(
      builder: (context, state) {
        if (state is BudgetListLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is BudgetListError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 8),
                Text(state.message, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                    onPressed: _applyFilters,
                    child: const Text('Tentar novamente')),
              ],
            ),
          );
        }
        if (state is BudgetListLoaded) {
          final pending = state.pendingBudgets;
          final remote = state.budgets;

          if (pending.isEmpty && remote.isEmpty) {
            return const Center(
              child: Text('Nenhum orçamento encontrado.'),
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 80),
            children: [
              if (pending.isNotEmpty) ...[
                _SectionHeader(
                  icon: Icons.cloud_upload_outlined,
                  label: 'Rascunhos pendentes (${pending.length})',
                  color: Colors.orange.shade700,
                ),
                ...pending.map((b) => _BudgetTile(
                      budget: b,
                      currencyFmt: _currencyFmt,
                      isPending: true,
                      onTap: () => _openLocalDraft(b.id),
                    )),
                const Divider(height: 16, thickness: 1),
              ],
              if (remote.isNotEmpty) ...[
                if (pending.isNotEmpty)
                  _SectionHeader(
                    icon: Icons.cloud_done_outlined,
                    label: 'Orçamentos',
                    color: Colors.grey.shade600,
                  ),
                ...remote.map((b) => _BudgetTile(
                      budget: b,
                      currencyFmt: _currencyFmt,
                      onTap: () => _openRegister(budget: b),
                    )),
              ],
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _BudgetTile extends StatelessWidget {
  const _BudgetTile({
    required this.budget,
    required this.currencyFmt,
    required this.onTap,
    this.isPending = false,
  });

  final BudgetEntity budget;
  final NumberFormat currencyFmt;
  final VoidCallback onTap;
  final bool isPending;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pendingColor = Colors.orange.shade700;
    return ListTile(
      onTap: onTap,
      tileColor: isPending ? Colors.orange.shade50 : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: Row(
        children: [
          Expanded(
            child: Text(
              budget.number.isNotEmpty
                  ? budget.number
                  : 'Rascunho #${budget.id}',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: isPending ? pendingColor : null,
              ),
            ),
          ),
          if (isPending)
            Container(
              margin: const EdgeInsets.only(left: 6),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: pendingColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'PENDENTE',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      subtitle: Text(
        budget.customerName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            currencyFmt.format(budget.total),
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            budget.date,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
