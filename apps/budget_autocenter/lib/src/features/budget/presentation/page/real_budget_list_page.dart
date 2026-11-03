import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/repository/pending_budget_store.dart';
import 'package:intl/intl.dart';
import '../../data/repository/real_budget_list_repository.dart';
import '../../data/repository/budget_draft_repository.dart';
import '../../domain/entity/budget_list_entry.dart';
import '../../domain/entity/autocenter_budget.dart' show money;
import 'new_budget_page.dart';
import 'budget_details_page.dart';
import '../widget/budget_contents_editor.dart';

class RealBudgetListPage extends StatefulWidget {
  const RealBudgetListPage({
    super.key,
    this.reader,
    this.writer,
    this.store,
    this.detailBuilder,
  });
  final BudgetListReader? reader;
  final BudgetDraftWriter? writer;
  final PendingBudgetStore? store;
  final Widget Function(int)? detailBuilder;
  @override
  State<RealBudgetListPage> createState() => _RealListState();
}

class _RealListState extends State<RealBudgetListPage> {
  late final BudgetListReader reader;
  BudgetListPageData? page;
  bool loading = true, filters = true;
  String? error;
  final number = TextEditingController(), customer = TextEditingController();
  DateTime? from, to, appliedFrom, appliedTo;
  String appliedNumber = '', appliedCustomer = '';
  int requestId = 0;
  late final Future<PendingBudgetStore> localStore;
  List<PendingBudget> pending = [];
  String? localError;
  int localRequest = 0;
  Future<void> loadPending() async {
    final id = ++localRequest;
    try {
      final rows = await (await localStore).all();
      if (mounted && id == localRequest)
        setState(() {
          pending = rows;
          localError = null;
        });
    } catch (_) {
      if (mounted && id == localRequest)
        setState(
          () => localError =
              'Não foi possível recuperar os rascunhos deste aparelho.',
        );
    }
  }

  List<PendingBudget> get visiblePending => pending.where((d) {
    final n = appliedNumber.toLowerCase(), c = appliedCustomer.toLowerCase();
    return (n.isEmpty || d.sequence.toString().contains(n)) &&
        (c.isEmpty || (d.customer?.label ?? '').toLowerCase().contains(c)) &&
        (appliedFrom == null || !d.date.isBefore(appliedFrom!)) &&
        (appliedTo == null ||
            !DateTime(
              d.date.year,
              d.date.month,
              d.date.day,
            ).isAfter(appliedTo!));
  }).toList();
  @override
  void initState() {
    super.initState();
    reader = widget.reader ?? RealBudgetListRepository();
    localStore = widget.store == null
        ? PreferencesPendingBudgetStore.open()
        : Future.value(widget.store);
    load();
  }

  @override
  void dispose() {
    requestId++;
    if (widget.reader == null) reader.close();
    number.dispose();
    customer.dispose();
    super.dispose();
  }

  Future<void> load({int offset = 0}) async {
    unawaited(loadPending());
    final id = ++requestId;
    setState(() {
      loading = true;
      error = null;
      page = null;
    });
    try {
      final result = await reader.load(
        offset: offset,
        from: appliedFrom,
        to: appliedTo,
        number: appliedNumber,
        customerName: appliedCustomer,
      );
      if (mounted && id == requestId) setState(() => page = result);
    } catch (e) {
      if (mounted && id == requestId)
        setState(() => error = budgetListError(e));
    } finally {
      if (mounted && id == requestId) setState(() => loading = false);
    }
  }

  void find() {
    if (from != null && to != null && from!.isAfter(to!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A data inicial deve ser anterior à data final.'),
        ),
      );
      return;
    }
    appliedNumber = number.text.trim();
    appliedCustomer = customer.text.trim();
    appliedFrom = from;
    appliedTo = to;
    load();
  }

  void clear() {
    number.clear();
    customer.clear();
    setState(() {
      from = to = null;
    });
    find();
  }

  Future<void> pick(bool first) async {
    final d = await showDatePicker(
      context: context,
      initialDate: (first ? from : to) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (d != null && mounted)
      setState(() {
        if (first) {
          from = d;
        } else {
          to = d;
        }
      });
  }

  Future<void> newBudget([PendingBudget? draft]) async {
    PendingBudgetStore store;
    try {
      store = await localStore;
    } catch (_) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Não foi possível preparar o armazenamento local. Confira a sessão e atualize a lista.',
            ),
          ),
        );
      return;
    }
    if (!mounted) return;
    final created = await Navigator.of(context).push<BudgetListEntry>(
      MaterialPageRoute(
        builder: (_) => NewBudgetPage(
          writer: widget.writer,
          store: store,
          initialDraft: draft,
        ),
      ),
    );
    if (!mounted) return;
    await loadPending();
    if (!mounted || created == null) return;
    clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Orçamento #${created.id} salvo no ERP.')),
    );
  }

  Widget section(String title, IconData icon, Color color) => Padding(
    padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
    child: Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
  Widget pendingTile(PendingBudget d) {
    final orange = Colors.orange.shade700;
    return ListTile(
      key: ValueKey('pending-budget-${d.id}'),
      trailing: Text(
        money((amount(documentTotals(d.document)['total']) * 100).round()),
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
      tileColor: Colors.orange.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      onTap: () => newBudget(d),
      title: Wrap(
        spacing: 8,
        runSpacing: 4,
        alignment: WrapAlignment.spaceBetween,
        children: [
          Text(
            'Rascunho #${d.sequence}',
            style: TextStyle(color: orange, fontWeight: FontWeight.w600),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: orange,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              d.review ? 'CONFERIR ENVIO' : 'PENDENTE',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(d.customer?.label ?? 'Cliente não informado'),
          Text(DateFormat('dd/MM/yyyy').format(d.date)),
        ],
      ),
    );
  }

  Future<void> openRemote(int id) async {
    try {
      final store = await localStore;
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              widget.detailBuilder?.call(id) ??
              BudgetDetailsPage(id: id, store: store, writer: widget.writer),
        ),
      );
      if (mounted) await load(offset: page?.offset ?? 0);
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(budgetListError(e))));
    }
  }

  Widget remoteTile(BudgetListEntry b) => ListTile(
    key: ValueKey('real-budget-${b.id}'),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    title: Wrap(
      spacing: 16,
      runSpacing: 4,
      alignment: WrapAlignment.spaceBetween,
      children: [
        Text(
          b.number.isEmpty ? 'Rascunho #${b.id}' : b.number,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        Text(
          money(b.totalCents),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    ),
    subtitle: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(b.customer.isEmpty ? 'Cliente não informado' : b.customer),
        Text(
          b.date == null
              ? 'Data não informada'
              : DateFormat('dd/MM/yyyy').format(b.date!),
        ),
      ],
    ),
    onTap: () => openRemote(b.id),
  );

  Widget dateField(bool first) => InkWell(
    onTap: () => pick(first),
    child: InputDecorator(
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        suffixIcon: const Icon(Icons.calendar_today, size: 20),
      ),
      child: Text(
        (first ? from : to) == null
            ? (first ? 'Data inicial' : 'Data final')
            : DateFormat('dd/MM/yyyy').format((first ? from : to)!),
      ),
    ),
  );

  Widget filterCard() => Card(
    margin: const EdgeInsets.all(8),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, c) {
          final width = c.maxWidth >= 500 ? (c.maxWidth - 12) / 2 : c.maxWidth;
          return Column(
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 10,
                children: [
                  SizedBox(
                    width: width,
                    child: TextField(
                      controller: number,
                      onSubmitted: (_) => find(),
                      decoration: const InputDecoration(
                        labelText: 'Número',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: TextField(
                      controller: customer,
                      onSubmitted: (_) => find(),
                      decoration: const InputDecoration(
                        labelText: 'Cliente',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: width, child: dateField(true)),
                  SizedBox(width: width, child: dateField(false)),
                ],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Wrap(
                  spacing: 12,
                  children: [
                    TextButton.icon(
                      onPressed: loading ? null : clear,
                      icon: const Icon(Icons.close),
                      label: const Text('Limpar'),
                    ),
                    OutlinedButton.icon(
                      onPressed: loading ? null : find,
                      icon: const Icon(Icons.search),
                      label: const Text('Buscar'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Orçamentos'),
      actions: [
        IconButton(
          tooltip: 'Filtros',
          onPressed: () => setState(() => filters = !filters),
          icon: Icon(filters ? Icons.filter_list_off : Icons.filter_list),
        ),
        IconButton(
          tooltip: 'Atualizar',
          onPressed: loading ? null : () => load(offset: page?.offset ?? 0),
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: newBudget,
      icon: const Icon(Icons.add),
      label: const Text('Novo'),
    ),
    body: Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: Column(
          children: [
            if (filters) filterCard(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => load(offset: page?.offset ?? 0),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
                  children: [
                    if (localError != null)
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Text(localError!),
                            TextButton(
                              onPressed: loadPending,
                              child: const Text('Tentar recuperar rascunhos'),
                            ),
                          ],
                        ),
                      ),
                    if (visiblePending.isNotEmpty) ...[
                      section(
                        'Rascunhos pendentes (${visiblePending.length})',
                        Icons.cloud_upload_outlined,
                        Colors.orange.shade700,
                      ),
                      ...visiblePending.map(pendingTile),
                      const Divider(),
                    ],
                    section(
                      'Orçamentos',
                      Icons.cloud_done_outlined,
                      Colors.grey.shade700,
                    ),
                    if (loading)
                      const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (error != null)
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            const Icon(Icons.error_outline, size: 44),
                            const SizedBox(height: 12),
                            Text(error!, textAlign: TextAlign.center),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () => load(),
                              child: const Text('Tentar novamente'),
                            ),
                          ],
                        ),
                      )
                    else if (page!.rows.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(
                          child: Text('Nenhum orçamento encontrado.'),
                        ),
                      )
                    else
                      ...page!.rows.map(remoteTile),
                  ],
                ),
              ),
            ),
            if (page != null && !loading)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  alignment: WrapAlignment.center,
                  children: [
                    OutlinedButton(
                      onPressed: page!.offset > 0
                          ? () => load(
                              offset: (page!.offset - page!.limit).clamp(
                                0,
                                page!.total,
                              ),
                            )
                          : null,
                      child: const Text('Anterior'),
                    ),
                    Text(
                      '${page!.total == 0 ? 0 : page!.offset + 1}–${page!.offset + page!.rows.length} de ${page!.total}',
                    ),
                    OutlinedButton(
                      onPressed: page!.hasNext
                          ? () => load(offset: page!.offset + page!.limit)
                          : null,
                      child: const Text('Próxima'),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    ),
  );
}
