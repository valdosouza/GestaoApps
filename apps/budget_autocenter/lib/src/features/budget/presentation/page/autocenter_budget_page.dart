import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widget/vehicle_inspection.dart';
import '../../domain/entity/vehicle_region.dart';
import '../../domain/entity/autocenter_budget.dart';
import '../../data/datasource/local/demo_catalog.dart';
import 'budget_overview_page.dart';

class AutoCenterBudgetPage extends StatelessWidget {
  const AutoCenterBudgetPage({super.key});
  @override
  Widget build(BuildContext context) => BudgetOverviewPage(
    onEdit: (context, budget, step) =>
        Navigator.of(context).push<AutoCenterBudget>(
          MaterialPageRoute(
            builder: (_) =>
                _BudgetEditor(budget: budget.copy(), initialStep: step),
          ),
        ),
  );
}

class _BudgetEditor extends StatefulWidget {
  const _BudgetEditor({required this.budget, this.initialStep = 0});
  final int initialStep;
  final AutoCenterBudget budget;
  @override
  State<_BudgetEditor> createState() => _BudgetEditorState();
}

class _BudgetEditorState extends State<_BudgetEditor> {
  AutoCenterBudget get b => widget.budget;
  int step = 0, selected = 1;
  @override
  void initState() {
    super.initState();
    step = widget.initialStep;
  }

  final scroll = ScrollController();
  @override
  void dispose() {
    scroll.dispose();
    super.dispose();
  }

  void go(int value) {
    setState(() => step = value);
    if (scroll.hasClients) scroll.jumpTo(0);
  }

  Widget field(
    String label,
    String value,
    ValueChanged<String> change, {
    bool numeric = false,
    int? max,
    int lines = 1,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TextFormField(
      key: ValueKey(label),
      initialValue: value,
      maxLength: max,
      maxLines: lines,
      keyboardType: numeric
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      decoration: InputDecoration(labelText: label, counterText: ''),
      onChanged: (v) => setState(() => change(v)),
    ),
  );
  Widget select(
    String label,
    String value,
    Map<String, String> options,
    ValueChanged<String> change,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: DropdownButtonFormField<String>(
      key: ValueKey('$label-$value'),
      initialValue: value.isEmpty ? null : value,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      items: options.entries
          .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
          .toList(),
      onChanged: (v) => setState(() => change(v!)),
    ),
  );
  Future<void> addItem(bool service) async {
    final item = await showModalBottomSheet<AutoCenterBudgetItem>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              service ? 'Adicionar mão de obra' : 'Adicionar peça',
              style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
            ),
            const Text('Catálogo fictício para testar o fluxo.'),
            ...catalog
                .where((i) => i.service == service)
                .map(
                  (i) => ListTile(
                    leading: Icon(
                      service ? Icons.build_outlined : Icons.tire_repair,
                    ),
                    title: Text(i.name),
                    subtitle: Text(money(i.cents)),
                    trailing: const Icon(Icons.add_circle_outline),
                    onTap: () => Navigator.pop(ctx, i.copy()),
                  ),
                ),
          ],
        ),
      ),
    );
    if (item != null && mounted) setState(() => b.items.add(item));
  }

  Future<void> editItem(AutoCenterBudgetItem item) async {
    final price = TextEditingController(
      text: (item.cents / 100).toStringAsFixed(2).replaceAll('.', ','),
    );
    final qty = TextEditingController(text: '${item.quantity}');
    final form = GlobalKey<FormState>();
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(item.name),
        content: Form(
          key: form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: qty,
                decoration: const InputDecoration(labelText: 'Quantidade'),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                keyboardType: TextInputType.number,
                validator: (s) => (int.tryParse(s ?? '') ?? 0) > 0
                    ? null
                    : 'Informe uma quantidade maior que zero',
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: price,
                decoration: const InputDecoration(
                  labelText: 'Valor unitário (R\$)',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (s) =>
                    RegExp(r'^\d+(?:[,.]\d{1,2})?$').hasMatch(s ?? '')
                    ? null
                    : 'Informe um valor válido',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Voltar'),
          ),
          FilledButton(
            onPressed: () {
              if (form.currentState!.validate()) Navigator.pop(ctx, true);
            },
            child: const Text('Aplicar'),
          ),
        ],
      ),
    );
    if (saved == true && mounted)
      setState(() {
        item.quantity = int.parse(qty.text);
        item.cents = parseMoney(price.text);
      });
    price.dispose();
    qty.dispose();
  }

  Future<void> normalRemaining() async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('As regiões restantes foram conferidas?'),
        content: Text(
          'Marcar ${22 - b.inspection.completed} regiões pendentes como normais? As avarias existentes serão preservadas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Voltar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sim, estão normais'),
          ),
        ],
      ),
    );
    if (yes == true && mounted) setState(b.inspection.confirmRemainingNormal);
  }

  Widget totals() => section('Resumo dos valores', [
    summary('Peças', money(b.subtotal(false))),
    summary('Mão de obra', money(b.subtotal(true))),
    summary('Frete', money(b.freight)),
    summary('Desconto', money(b.discount)),
    const Divider(),
    summary('Total do orçamento', money(b.total), strong: true),
  ]);
  Widget budgetPage() => Column(
    children: [
      section('Quem vamos atender?', [
        field('Nome do cliente', b.customer, (v) => b.customer = v),
        field('Contato / telefone', b.contact, (v) => b.contact = v),
        field('Vendedor', b.salesman, (v) => b.salesman = v),
      ]),
      ...[false, true].map(
        (service) => section(service ? 'Mão de obra' : 'Peças e produtos', [
          if (!b.items.any((i) => i.service == service))
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text(
                'Nenhum item adicionado.',
                style: TextStyle(color: Colors.black54),
              ),
            ),
          ...b.items
              .where((i) => i.service == service)
              .map(
                (i) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(i.name),
                  subtitle: Text('${i.quantity} × ${money(i.cents)}'),
                  onTap: () => editItem(i),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        money(i.total),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        tooltip: 'Remover ${i.name}',
                        onPressed: () => setState(() => b.items.remove(i)),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
              ),
          OutlinedButton.icon(
            onPressed: () => addItem(service),
            icon: const Icon(Icons.add),
            label: Text(service ? 'Adicionar serviço' : 'Adicionar peça'),
          ),
        ]),
      ),
      section('Condições comerciais', [
        select('Forma de pagamento', b.payment, const {
          'A combinar': 'A combinar',
          'Dinheiro': 'Dinheiro',
          'Pix': 'Pix',
          'Cartão': 'Cartão',
        }, (v) => b.payment = v),
        field('Prazo', b.term, (v) => b.term = v),
        field(
          'Frete (R\$)',
          (b.freight / 100).toStringAsFixed(2),
          (v) => b.freight = parseMoney(v),
          numeric: true,
        ),
        field(
          'Desconto (R\$)',
          (b.discount / 100).toStringAsFixed(2),
          (v) => b.discount = parseMoney(v),
          numeric: true,
        ),
        field(
          'Observações do orçamento',
          b.notes,
          (v) => b.notes = v,
          lines: 3,
        ),
      ]),
      totals(),
    ],
  );
  Widget vehiclePage() => Column(
    children: [
      section('O veículo deste atendimento', [
        const Text(
          'As informações são fictícias e não consultam o cadastro da oficina.',
        ),
        const SizedBox(height: 16),
        field(
          'Placa (sem hífen)',
          b.plate,
          (v) => b.plate = v.toUpperCase(),
          max: 7,
        ),
        field('Marca e modelo', b.vehicle, (v) => b.vehicle = v),
        field('Ano', b.year, (v) => b.year = v, numeric: true, max: 4),
        field('Cor', b.color, (v) => b.color = v),
        field('Quilometragem', b.km, (v) => b.km = v, numeric: true, max: 25),
        field('Frota', b.fleet, (v) => b.fleet = v),
        field('Chassi', b.chassis, (v) => b.chassis = v, max: 50),
        field(
          'Observações do veículo',
          b.vehicleNotes,
          (v) => b.vehicleNotes = v,
          lines: 3,
        ),
        field(
          'Saída prevista (data / hora)',
          b.departure,
          (v) => b.departure = v,
        ),
      ]),
    ],
  );
  Widget inspectionPage() {
    final region = carRegions[selected - 1];
    return Column(
      children: [
        section('Condições de entrada', [
          Text(
            '${b.inspection.completed} de 22 regiões conferidas · ${b.inspection.damages} com avarias',
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: b.inspection.completed / 22,
            minHeight: 6,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, box) {
              final drawing = ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 340),
                child: InspectionCar(
                  inspection: b.inspection,
                  selected: selected,
                  onSelect: (id) => setState(() => selected = id),
                ),
              );
              final controls = Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'REGIÃO ${selected.toString().padLeft(2, '0')} · ${region.group.toUpperCase()}',
                    style: const TextStyle(fontSize: 11, color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    region.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    region.description,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: InspectionState.values
                        .map(
                          (state) => ChoiceChip(
                            label: Text(state.label),
                            avatar: CircleAvatar(
                              backgroundColor: stateColor(state),
                              radius: 7,
                            ),
                            selected:
                                b.inspection.regions[selected - 1] == state,
                            onSelected: (_) => setState(
                              () => b.inspection.regions[selected - 1] = state,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        tooltip: 'Região anterior',
                        onPressed: selected > 1
                            ? () => setState(() => selected--)
                            : null,
                        icon: const Icon(Icons.arrow_back),
                      ),
                      Text('$selected / 22'),
                      IconButton(
                        tooltip: 'Próxima região',
                        onPressed: selected < 22
                            ? () => setState(() => selected++)
                            : null,
                        icon: const Icon(Icons.arrow_forward),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: b.inspection.completed < 22
                        ? normalRemaining
                        : null,
                    child: const Text('Confirmar restantes como normais'),
                  ),
                  const Text(
                    'Cinza significa pendente. Inspecione antes de marcar.',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              );
              return box.maxWidth >= 680
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: drawing),
                        const SizedBox(width: 24),
                        Expanded(child: controls),
                      ],
                    )
                  : Column(
                      children: [drawing, const SizedBox(height: 20), controls],
                    );
            },
          ),
          const SizedBox(height: 16),
          ExpansionTile(
            title: const Text('Lista das 22 regiões'),
            children: carRegions
                .map(
                  (r) => ListTile(
                    selected: selected == r.id,
                    leading: CircleAvatar(
                      backgroundColor: stateColor(
                        b.inspection.regions[r.id - 1],
                      ),
                      child: Text('${r.id}'),
                    ),
                    title: Text(r.name),
                    subtitle: Text(
                      b.inspection.regions[r.id - 1]?.label ?? 'Pendente',
                    ),
                    onTap: () => setState(() => selected = r.id),
                  ),
                )
                .toList(),
          ),
        ]),
        section('Pneus', [
          ...{
            'front': 'Dianteiros',
            'back': 'Traseiros',
            'spare': 'Estepe',
          }.entries.map(
            (e) => select('Pneus · ${e.value}', b.tyres[e.key] ?? '', const {
              'R': 'Ruim',
              'B': 'Bom',
              'E': 'Excelente',
            }, (v) => b.tyres[e.key] = v),
          ),
        ]),
        section('Equipamentos e entrada', [
          select('Combustível', b.fuel, const {
            '1': 'Etanol',
            '2': 'Gasolina',
            '3': 'Flex',
            '4': 'Diesel',
            '5': 'G.N.V',
          }, (v) => b.fuel = v),
          select('Válvulas', b.valves, const {
            '08': '08',
            '16': '16',
            '20': '20',
            '24': '24',
          }, (v) => b.valves = v),
          field('Prisma', b.prism, (v) => b.prism = v, max: 10),
          field(
            'Data de entrada (DD/MM/AAAA)',
            b.entryDate,
            (v) => b.entryDate = v,
            max: 10,
          ),
          field(
            'Hora de entrada (HH:MM)',
            b.entryTime,
            (v) => b.entryTime = v,
            max: 5,
          ),
          const Text(
            'Marque os acessórios presentes',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          ...accessoryNames.entries.map(
            (e) => CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(e.value),
              value: b.accessories.contains(e.key),
              onChanged: (v) => setState(() {
                if (v!) {
                  b.accessories.add(e.key);
                } else {
                  b.accessories.remove(e.key);
                }
              }),
            ),
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            value: b.accessoriesConfirmed,
            onChanged: (v) => setState(() => b.accessoriesConfirmed = v!),
            title: const Text(
              'Conferi os acessórios; os desmarcados estão ausentes.',
            ),
          ),
          field(
            'Observações da inspeção',
            b.inspectionNotes,
            (v) => b.inspectionNotes = v,
            lines: 3,
          ),
        ]),
      ],
    );
  }

  Widget reviewPage() => Column(
    children: [
      section('Confira o atendimento', [
        summary('Cliente', b.customer),
        summary('Contato', b.contact),
        summary('Vendedor', b.salesman),
        summary('Veículo', b.vehicle),
        summary('Placa', b.plate),
        summary('Ano / cor', '${b.year} / ${b.color}'),
        summary('Quilometragem', b.km),
        summary('Frota', b.fleet),
        summary('Chassi', b.chassis),
        summary('Observações do veículo', b.vehicleNotes),
        summary('Saída prevista', b.departure),
        summary('Pagamento', '${b.payment} · ${b.term}'),
        summary('Observações', b.notes),
      ]),
      section('Peças e serviços', [
        ...b.items.map(
          (i) => summary('${i.quantity} × ${i.name}', money(i.total)),
        ),
      ]),
      totals(),
      section('Inspeção exterior', [
        Text(
          '${b.inspection.completed}/22 conferidas · ${b.inspection.damages} com avarias',
        ),
        ...carRegions.map(
          (r) => summary(
            '${r.id.toString().padLeft(2, '0')} · ${r.name}',
            b.inspection.regions[r.id - 1]?.label ?? 'Pendente',
          ),
        ),
      ]),
      section('Pneus, acessórios e entrada', [
        ...{
          'front': 'Dianteiros',
          'back': 'Traseiros',
          'spare': 'Estepe',
        }.entries.map(
          (e) => summary(
            e.value,
            const {'R': 'Ruim', 'B': 'Bom', 'E': 'Excelente'}[b.tyres[e.key]] ??
                'Pendente',
          ),
        ),
        summary(
          'Combustível',
          const {
                '1': 'Etanol',
                '2': 'Gasolina',
                '3': 'Flex',
                '4': 'Diesel',
                '5': 'G.N.V',
              }[b.fuel] ??
              'Pendente',
        ),
        summary('Válvulas', b.valves),
        summary('Prisma', b.prism),
        summary('Entrada', '${b.entryDate} ${b.entryTime}'.trim()),
        summary(
          'Itens presentes',
          b.accessories.map((a) => accessoryNames[a]!).join(', '),
        ),
        summary(
          'Conferência dos acessórios',
          b.accessoriesConfirmed ? 'Confirmada' : 'Pendente',
        ),
        summary('Observações', b.inspectionNotes),
      ]),
      if (b.pending.isNotEmpty)
        section('Antes de concluir', [
          ...b.pending.map(
            (p) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text('• $p'),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Você pode guardar um rascunho e continuar depois, nesta sessão.',
          ),
        ]),
      const Text(
        'Regras de preenchimento demonstrativas, sujeitas à sua avaliação.',
        style: TextStyle(fontSize: 12, color: Colors.black54),
      ),
      const SizedBox(height: 12),
      FilledButton.icon(
        key: const Key('complete-demo'),
        onPressed: b.pending.isEmpty
            ? () async {
                await showDialog<void>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Demonstração concluída'),
                    content: const Text(
                      'O atendimento foi revisado. Nenhum dado foi enviado à API ou ao Firebird.',
                    ),
                    actions: [
                      FilledButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Voltar aos orçamentos'),
                      ),
                    ],
                  ),
                );
                if (mounted) Navigator.pop(context, b);
              }
            : null,
        icon: const Icon(Icons.check_circle_outline),
        label: const Text('Concluir demonstração'),
      ),
    ],
  );
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(b.localNumber ?? 'Novo orçamento'),
      actions: [
        TextButton(
          key: const Key('save-draft'),
          onPressed: () => Navigator.pop(context, b),
          child: const Text('Guardar rascunho'),
        ),
      ],
    ),
    body: centered(
      Column(
        children: [
          Container(
            width: double.infinity,
            color: const Color(0xffffeadb),
            padding: const EdgeInsets.all(10),
            child: const Text(
              'DEMONSTRAÇÃO · Apenas em memória · Sem conexão com o ERP',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Color(0xff7e3d20)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: ['Orçamento', 'Veículo', 'Inspeção', 'Revisão']
                  .asMap()
                  .entries
                  .map(
                    (e) => ChoiceChip(
                      key: ValueKey('step-${e.key}'),
                      selected: step == e.key,
                      onSelected: (_) => go(e.key),
                      label: Text('${e.key + 1}. ${e.value}'),
                    ),
                  )
                  .toList(),
            ),
          ),
          Expanded(
            child: ListView(
              controller: scroll,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
              children: [
                switch (step) {
                  0 => budgetPage(),
                  1 => vehiclePage(),
                  2 => inspectionPage(),
                  _ => reviewPage(),
                },
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (step > 0)
                      OutlinedButton(
                        onPressed: () => go(step - 1),
                        child: const Text('← Anterior'),
                      )
                    else
                      const SizedBox(),
                    if (step < 3)
                      FilledButton(
                        onPressed: () => go(step + 1),
                        child: const Text('Continuar →'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget centered(Widget child) => Align(
  alignment: Alignment.topCenter,
  child: ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 1000),
    child: child,
  ),
);
Widget section(String title, List<Widget> children) => Card(
  elevation: 0,
  color: Colors.white,
  margin: const EdgeInsets.only(bottom: 16),
  child: Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    ),
  ),
);
Widget summary(String title, String value, {bool strong = false}) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 7),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Text(
          title,
          style: TextStyle(fontSize: strong ? 17 : 13, color: Colors.black54),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Text(
          value.isEmpty ? 'Não informado' : value,
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: strong ? 19 : 13,
            fontWeight: strong ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
      ),
    ],
  ),
);
