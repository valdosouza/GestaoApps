import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entity/autocenter_budget.dart';
import '../../data/datasource/local/demo_catalog.dart';

typedef EditBudget =
    Future<AutoCenterBudget?> Function(
      BuildContext context,
      AutoCenterBudget budget,
      int step,
    );

class BudgetOverviewPage extends StatefulWidget {
  const BudgetOverviewPage({super.key, required this.onEdit});
  final EditBudget onEdit;
  @override
  State<BudgetOverviewPage> createState() => _OverviewState();
}

class _OverviewState extends State<BudgetOverviewPage> {
  final budgets = <AutoCenterBudget>[];
  final number = TextEditingController(),
      customer = TextEditingController(),
      plate = TextEditingController();
  bool filters = false;
  String numberFilter = '', customerFilter = '', plateFilter = '';
  DateTime? start, end, appliedStart, appliedEnd;
  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    budgets.addAll([
      AutoCenterBudget(
          customer: 'Cliente demonstração',
          vehicle: 'Hatch · 1.6',
          plate: 'ABC1D23',
          date: now,
        )
        ..localNumber = 'DEMO-001'
        ..items.addAll([catalog.first.copy()..quantity = 2, catalog[4].copy()]),
      AutoCenterBudget(
          customer: 'Cliente exemplo · revisão',
          vehicle: 'Sedã · 2.0',
          plate: 'DEF4G56',
          date: now.subtract(const Duration(days: 1)),
        )
        ..localNumber = 'DEMO-002'
        ..items.addAll([
          catalog[2].copy()..quantity = 4,
          catalog[3].copy(),
          catalog[6].copy(),
        ]),
      AutoCenterBudget(
          customer: 'Cliente exemplo · freios',
          vehicle: 'Utilitário · 1.8',
          plate: 'HIJ7K89',
          date: now.subtract(const Duration(days: 2)),
        )
        ..localNumber = 'DEMO-003'
        ..items.addAll([catalog[1].copy(), catalog[7].copy()]),
    ]);
  }

  @override
  void dispose() {
    number.dispose();
    customer.dispose();
    plate.dispose();
    super.dispose();
  }

  void apply() => setState(() {
    numberFilter = number.text.trim().toLowerCase();
    customerFilter = customer.text.trim().toLowerCase();
    plateFilter = plate.text.trim().toLowerCase();
    appliedStart = start;
    appliedEnd = end;
  });
  void clear() {
    number.clear();
    customer.clear();
    plate.clear();
    start = end = null;
    apply();
  }

  Future<void> date(bool first) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: (first ? start : end) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted)
      setState(() {
        if (first) {
          start = picked;
        } else {
          end = picked;
        }
      });
  }

  Future<void> create() async {
    final saved = await widget.onEdit(context, AutoCenterBudget(), 0);
    if (saved != null && mounted)
      setState(() {
        saved.localNumber =
            'DEMO-${(budgets.length + 1).toString().padLeft(3, '0')}';
        budgets.insert(0, saved);
      });
  }

  void open(AutoCenterBudget b) => Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (_) => BudgetDetails(
        budget: b,
        onEdit: widget.onEdit,
        onSaved: (saved) {
          final i = budgets.indexWhere(
            (item) => item.localNumber == saved.localNumber,
          );
          if (i >= 0 && mounted) setState(() => budgets[i] = saved);
        },
      ),
    ),
  );
  Widget input(String name, TextEditingController controller) => TextField(
    controller: controller,
    decoration: InputDecoration(
      labelText: name,
      border: const OutlineInputBorder(),
      isDense: true,
    ),
  );
  @override
  Widget build(BuildContext context) {
    final list = budgets.where((b) {
      final day = DateUtils.dateOnly(b.date);
      return (b.localNumber ?? '').toLowerCase().contains(numberFilter) &&
          b.customer.toLowerCase().contains(customerFilter) &&
          b.plate.toLowerCase().contains(plateFilter) &&
          (appliedStart == null || !day.isBefore(appliedStart!)) &&
          (appliedEnd == null || !day.isAfter(appliedEnd!));
    }).toList();
    return Scaffold(
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
            onPressed: () {
              apply();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Lista demonstrativa atualizada.'),
                ),
              );
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('new-budget'),
        onPressed: create,
        icon: const Icon(Icons.add),
        label: const Text('Novo'),
      ),
      body: demoWidth(
        Column(
          children: [
            const DemoNotice(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 88),
                children: [
                  if (filters)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(child: input('Número', number)),
                                const SizedBox(width: 8),
                                Expanded(child: input('Cliente', customer)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            input('Placa', plate),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => date(true),
                                    icon: const Icon(
                                      Icons.calendar_today,
                                      size: 16,
                                    ),
                                    label: Text(
                                      start == null
                                          ? 'Data inicial'
                                          : DateFormat(
                                              'dd/MM/yyyy',
                                            ).format(start!),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => date(false),
                                    icon: const Icon(
                                      Icons.calendar_today,
                                      size: 16,
                                    ),
                                    label: Text(
                                      end == null
                                          ? 'Data final'
                                          : DateFormat(
                                              'dd/MM/yyyy',
                                            ).format(end!),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Wrap(
                              spacing: 8,
                              children: [
                                TextButton.icon(
                                  onPressed: clear,
                                  icon: const Icon(Icons.clear),
                                  label: const Text('Limpar'),
                                ),
                                ElevatedButton.icon(
                                  onPressed: apply,
                                  icon: const Icon(Icons.search),
                                  label: const Text('Buscar'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.cloud_upload_outlined,
                          size: 18,
                          color: Colors.orange.shade700,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Rascunhos da demonstração (${list.length})',
                            style: TextStyle(
                              color: Colors.orange.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (list.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Nenhum orçamento encontrado.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ...list.map(
                    (b) => Card(
                      elevation: 0,
                      color: Colors.orange.shade50,
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        key: ValueKey('budget-${b.localNumber}'),
                        onTap: () => open(b),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        title: Wrap(
                          spacing: 12,
                          runSpacing: 4,
                          alignment: WrapAlignment.spaceBetween,
                          children: [
                            Text(
                              b.localNumber!,
                              style: TextStyle(
                                color: Colors.orange.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              money(b.total),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                b.customer.isEmpty
                                    ? 'Cliente não informado'
                                    : b.customer,
                              ),
                              Text(
                                '${b.plate.isEmpty ? 'Sem placa' : b.plate} · ${b.vehicle.isEmpty ? 'Veículo não informado' : b.vehicle}',
                              ),
                              Text(
                                '${DateFormat('dd/MM/yyyy').format(b.date)} · ${b.items.length} itens · ${b.inspection.completed}/22 regiões',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BudgetDetails extends StatefulWidget {
  const BudgetDetails({
    super.key,
    required this.budget,
    required this.onEdit,
    required this.onSaved,
  });
  final AutoCenterBudget budget;
  final EditBudget onEdit;
  final ValueChanged<AutoCenterBudget> onSaved;
  @override
  State<BudgetDetails> createState() => _DetailsState();
}

class _DetailsState extends State<BudgetDetails> {
  late AutoCenterBudget b;
  @override
  void initState() {
    super.initState();
    b = widget.budget;
  }

  Future<void> edit(int step) async {
    final saved = await widget.onEdit(context, b.copy(), step);
    if (saved != null && mounted) {
      widget.onSaved(saved);
      setState(() => b = saved);
    }
  }

  Widget card(String title, List<Widget> children) => Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    ),
  );
  Widget row(String name, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(name)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value.isEmpty ? 'Não informado' : value,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    ),
  );
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(b.localNumber ?? 'Orçamento'),
      actions: [
        IconButton(
          key: const Key('edit-budget'),
          tooltip: 'Editar orçamento',
          onPressed: () => edit(0),
          icon: const Icon(Icons.edit_outlined),
        ),
      ],
    ),
    body: demoWidth(
      ListView(
        padding: const EdgeInsets.all(12),
        children: [
          const DemoNotice(),
          const SizedBox(height: 12),
          card('Dados do orçamento', [
            row('Cliente', b.customer),
            row('Contato', b.contact),
            row('Data', DateFormat('dd/MM/yyyy').format(b.date)),
            row('Vendedor', b.salesman),
            row('Pagamento', '${b.payment} · ${b.term}'),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => edit(0),
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Editar orçamento'),
            ),
          ]),
          ...[false, true].map(
            (s) => card(s ? 'Serviços / mão de obra' : 'Produtos / peças', [
              if (!b.items.any((i) => i.service == s))
                const Text('Nenhum item adicionado.'),
              ...b.items
                  .where((i) => i.service == s)
                  .map(
                    (i) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            i.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          row(
                            '${i.quantity} × ${money(i.cents)}',
                            money(i.total),
                          ),
                        ],
                      ),
                    ),
                  ),
            ]),
          ),
          card('Valores', [
            row('Produtos', money(b.subtotal(false))),
            row('Serviços', money(b.subtotal(true))),
            row('Frete', money(b.freight)),
            row('Desconto', money(b.discount)),
            const Divider(),
            DefaultTextStyle.merge(
              style: const TextStyle(fontWeight: FontWeight.bold),
              child: row('Total', money(b.total)),
            ),
          ]),
          card('Veículo', [
            row('Placa', b.plate),
            row('Marca / modelo', b.vehicle),
            row('Ano / cor', '${b.year} / ${b.color}'),
            row('Quilometragem', b.km),
            row('Frota', b.fleet),
            row('Chassi', b.chassis),
            row('Observações', b.vehicleNotes),
            row('Saída prevista', b.departure),
            OutlinedButton.icon(
              key: const Key('details-vehicle'),
              onPressed: () => edit(1),
              icon: const Icon(Icons.directions_car_outlined),
              label: const Text('Ver / editar veículo'),
            ),
          ]),
          card('Checklist de entrada', [
            row('Regiões conferidas', '${b.inspection.completed} de 22'),
            row('Regiões com avarias', '${b.inspection.damages}'),
            LinearProgressIndicator(value: b.inspection.completed / 22),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              key: const Key('details-checklist'),
              onPressed: () => edit(2),
              icon: const Icon(Icons.fact_check_outlined),
              label: const Text('Abrir checklist'),
            ),
          ]),
          card('Observações', [
            Text(b.notes.isEmpty ? 'Sem observações.' : b.notes),
          ]),
        ],
      ),
    ),
  );
}

Widget demoWidth(Widget child) => Align(
  alignment: Alignment.topCenter,
  child: ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 1000),
    child: child,
  ),
);

class DemoNotice extends StatelessWidget {
  const DemoNotice({super.key});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(10),
    color: Theme.of(context).colorScheme.surfaceContainerHighest,
    child: const Text(
      'Demonstração · Dados fictícios em memória · Sem gravação no ERP',
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 11),
    ),
  );
}
