import 'dart:convert';
import 'package:flutter/material.dart';

import '../../data/repository/complete_budget_repository.dart';
import '../../domain/entity/autocenter_budget.dart';
import 'catalog_dialog.dart';
import 'vehicle_inspection.dart';

num amount(dynamic v) => v is num ? v : 0;
Map<String, dynamic> documentTotals(Map<String, dynamic> doc) {
  double products = 0, services = 0, discount = 0;
  for (final raw in doc['items'] as List? ?? []) {
    final i = raw as Map;
    final gross =
        (amount(i['quantity']) * amount(i['unitPrice']) * 10000).round() /
        10000;
    if (i['type'] == 'S') {
      services += gross;
    } else {
      products += gross;
    }
    discount += amount(i['discountValue']);
  }
  final h = doc['header'] as Map? ?? {};
  return {
    'products': products,
    'services': services,
    'discount': discount,
    'total':
        products +
        services -
        discount +
        amount(h['freight']) +
        amount(h['additional']),
  };
}

class BudgetContentsEditor extends StatefulWidget {
  const BudgetContentsEditor({
    super.key,
    required this.document,
    required this.api,
    required this.onChanged,
    this.readOnly = false,
  });
  final Map<String, dynamic> document;
  final CompleteBudgetWriter api;
  final VoidCallback onChanged;
  final bool readOnly;
  @override
  State<BudgetContentsEditor> createState() => _ContentsState();
}

class _ContentsState extends State<BudgetContentsEditor> {
  Map<String, dynamic> get d => widget.document;
  List get items => d.putIfAbsent('items', () => <dynamic>[]) as List;
  Map<String, dynamic> get h =>
      d.putIfAbsent('header', () => <String, dynamic>{})
          as Map<String, dynamic>;
  int selected = 1;
  void change(VoidCallback f) {
    if (widget.readOnly) return;
    final beforeVehicle = jsonEncode(d['vehicle']),
        beforeCheck = jsonEncode(d['checklist']);
    setState(() {
      f();
      if (jsonEncode(d['vehicle']) != beforeVehicle) d['vehicleDirty'] = true;
      if (jsonEncode(d['checklist']) != beforeCheck) d['checklistDirty'] = true;
    });
    widget.onChanged();
  }

  void notify(String text) {
    if (mounted)
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<Map<String, dynamic>?> lookup(
    String kind,
    String title, {
    Map<String, String> params = const {},
  }) async {
    if (widget.readOnly) return null;
    return chooseCatalog(context, widget.api, kind, title, parameters: params);
  }

  Future<void> add(bool service) async {
    final product = await lookup(
      service ? 'services' : 'products',
      service ? 'Selecionar mão de obra' : 'Selecionar peça',
    );
    if (product == null || !mounted) return;
    final price = await lookup(
      'prices',
      'Selecionar preço',
      params: {'productId': '${product['id']}'},
    );
    if (price == null || !mounted) return;
    Map<String, dynamic>? stock;
    if (!service) {
      stock = await lookup('stocks', 'Selecionar estoque');
      if (stock == null || !mounted) return;
    }
    final value = <String, dynamic>{
      'type': service ? 'S' : 'P',
      'productId': product['id'],
      'description': product['label'],
      'quantity': 1.0,
      'unitPrice': price['price'],
      'discountValue': 0.0,
      'stockId': stock?['id'] ?? 0,
      'priceListId': service ? 0 : price['id'],
    };
    final applied = await editItem(value);
    if (applied != null && mounted) change(() => items.add(applied));
  }

  Future<Map<String, dynamic>?> editItem(Map<String, dynamic> source) async {
    final form = GlobalKey<FormState>();
    final name = TextEditingController(text: '${source['description'] ?? ''}');
    final qty = TextEditingController(text: '${source['quantity'] ?? 1}');
    final price = TextEditingController(text: '${source['unitPrice'] ?? 0}');
    final discount = TextEditingController(
      text: '${source['discountValue'] ?? 0}',
    );
    double parse(String s) =>
        double.tryParse(s.replaceAll(',', '.')) ?? double.nan;
    Widget number(String label, TextEditingController c, int decimals) =>
        TextFormField(
          controller: c,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: label),
          validator: (v) {
            final n = parse(v ?? '');
            return !RegExp(
                      '^\\d+(?:[,.]\\d{1,$decimals})?\$',
                    ).hasMatch(v ?? '') ||
                    !n.isFinite ||
                    n < 0 ||
                    n > 99999999
                ? 'Informe um valor válido (até $decimals casas).'
                : null;
          },
        );
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(source['type'] == 'S' ? 'Mão de obra' : 'Peça'),
        content: SizedBox(
          width: 440,
          child: SingleChildScrollView(
            child: Form(
              key: form,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: name,
                    maxLength: 100,
                    decoration: const InputDecoration(labelText: 'Descrição'),
                    validator: (v) =>
                        (v ?? '').trim().isEmpty ? 'Informe a descrição' : null,
                  ),
                  number('Quantidade', qty, 3),
                  number('Valor unitário', price, 6),
                  number('Desconto do item (R\$)', discount, 2),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (!form.currentState!.validate()) return;
              if (parse(qty.text) <= 0 ||
                  parse(discount.text) > parse(qty.text) * parse(price.text)) {
                notify('Confira quantidade e desconto.');
                return;
              }
              Navigator.pop(ctx, true);
            },
            child: const Text('Aplicar'),
          ),
        ],
      ),
    );
    final result = saved == true
        ? {
            ...source,
            'description': name.text.trim(),
            'quantity': parse(qty.text),
            'unitPrice': parse(price.text),
            'discountValue': parse(discount.text),
          }
        : null;
    // Descarte depois de encerrar a animação do diálogo.
    await Future<void>.delayed(const Duration(milliseconds: 250));
    name.dispose();
    qty.dispose();
    price.dispose();
    discount.dispose();
    return result;
  }

  bool unchanged(Map target) =>
      (identical(target, d['vehicle']) && d['vehicleDirty'] == false) ||
      (identical(target, d['checklist']) && d['checklistDirty'] == false);
  Widget field(
    Map target,
    String key,
    String label, {
    int max = 100,
    bool numeric = false,
    int lines = 1,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      key: ValueKey(
        '${d['localKey'] ?? 'contents'}-$key-${target == h
            ? 'header'
            : target == d['vehicle']
            ? 'vehicle'
            : 'check'}',
      ),
      initialValue: '${target[key] ?? ''}',
      enabled: !widget.readOnly,
      maxLength: max,
      maxLines: lines,
      keyboardType: numeric
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        counterText: '',
      ),
      validator: (v) =>
          !unchanged(target) &&
              numeric &&
              (double.tryParse((v ?? '').replaceAll(',', '.')) == null ||
                  double.parse((v ?? '').replaceAll(',', '.')) < 0)
          ? 'Informe um valor válido'
          : null,
      onChanged: (value) => change(
        () => target[key] = numeric
            ? (double.tryParse(value.replaceAll(',', '.')) ?? 0)
            : value,
      ),
    ),
  );
  Widget selector(
    Map target,
    String key,
    String label,
    String kind, {
    Map<String, String> params = const {},
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: FormField<int>(
      key: ValueKey('$key-${target[key]}'),
      initialValue: (target[key] as num?)?.toInt(),
      validator: (_) => !unchanged(target) && (amount(target[key]) <= 0)
          ? 'Selecione $label'
          : null,
      builder: (f) => InkWell(
        onTap: widget.readOnly
            ? null
            : () async {
                final r = await lookup(kind, label, params: params);
                if (r != null && mounted)
                  change(() {
                    target[key] = r['id'];
                    target['${key}Label'] = r['label'];
                    if (key == 'brandId') {
                      target['modelId'] = null;
                      target['modelIdLabel'] = null;
                    }
                  });
              },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            errorText: f.errorText,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${target['${key}Label'] ?? (target[key] == null ? 'Selecionar' : 'Código ${target[key]}')}',
                ),
              ),
              const Icon(Icons.search),
            ],
          ),
        ),
      ),
    ),
  );
  Widget choice(
    Map target,
    String key,
    String label,
    Map<String, String> options,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: DropdownButtonFormField<String>(
      key: ValueKey('$key-${target[key]}'),
      initialValue: options.containsKey(target[key])
          ? target[key] as String
          : null,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: options.entries
          .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
          .toList(),
      validator: (v) =>
          !unchanged(target) && v == null ? 'Confira $label' : null,
      onChanged: widget.readOnly ? null : (v) => change(() => target[key] = v),
    ),
  );
  Widget section(String title, List<Widget> children) => ExpansionTile(
    title: Text(title),
    maintainState: true,
    childrenPadding: const EdgeInsets.all(12),
    children: children,
  );
  Widget vehicle() {
    final v = d['vehicle'] as Map;
    return Column(
      children: [
        OutlinedButton.icon(
          onPressed: widget.readOnly
              ? null
              : () async {
                  final r = await lookup('vehicles', 'Pesquisar placa');
                  if (r == null || !mounted) return;
                  change(() {
                    d['vehicle'] = {
                      ...v,
                      ...Map<String, dynamic>.from(r['value'] as Map),
                    };
                    d['vehicleVersion'] = r['version'];
                    d['localKey'] = r['label'];
                  });
                },
          icon: const Icon(Icons.search),
          label: const Text('Buscar veículo cadastrado'),
        ),
        const SizedBox(height: 12),
        field(v, 'plate', 'Placa', max: 7),
        selector(v, 'brandId', 'Marca', 'brands'),
        if (v['brandId'] != null)
          selector(
            v,
            'modelId',
            'Modelo',
            'models',
            params: {'brandId': '${v['brandId']}'},
          ),
        selector(v, 'kindId', 'Tipo de veículo', 'kinds'),
        selector(v, 'colorId', 'Cor', 'colors'),
        field(v, 'fleet', 'Frota', max: 30),
        field(v, 'year', 'Ano', max: 4),
        field(v, 'km', 'Quilometragem do veículo', max: 15),
        field(v, 'engine', 'Cilindrada', numeric: true, max: 6),
        field(v, 'chassis', 'Chassi', max: 50),
        field(v, 'notes', 'Observação do serviço', max: 16000, lines: 3),
        field(v, 'exitDate', 'Saída (DD/MM/AAAA)', max: 10),
        field(v, 'exitHour', 'Hora de saída (HH:MM)', max: 5),
      ],
    );
  }

  Widget checklist() {
    final c = d['checklist'] as Map;
    final inspection = VehicleInspection();
    final raw = '${c['regions'] ?? ''}'.padRight(22, '_');
    for (var i = 0; i < 22; i++) {
      for (final state in InspectionState.values) {
        if (state.code == raw[i]) inspection.regions[i] = state;
      }
    }
    void changedRegions() {
      c['regions'] = inspection.regions.map((s) => s?.code ?? '_').join();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 340),
            child: InspectionCar(
              inspection: inspection,
              selected: selected,
              onSelect: (v) => setState(() => selected = v),
            ),
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<int>(
          initialValue: selected,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Região'),
          items: List.generate(
            22,
            (i) => DropdownMenuItem(
              value: i + 1,
              child: Text('Região ${(i + 1).toString().padLeft(2, '0')}'),
            ),
          ),
          onChanged: (v) => setState(() => selected = v!),
        ),
        Wrap(
          spacing: 6,
          children: InspectionState.values
              .map(
                (s) => ChoiceChip(
                  label: Text(s.label),
                  selected: inspection.regions[selected - 1] == s,
                  onSelected: widget.readOnly
                      ? null
                      : (_) => change(() {
                          inspection.regions[selected - 1] = s;
                          changedRegions();
                        }),
                ),
              )
              .toList(),
        ),
        TextButton(
          onPressed: widget.readOnly
              ? null
              : () => change(() {
                  inspection.confirmRemainingNormal();
                  changedRegions();
                }),
          child: const Text('Confirmar regiões restantes como normais'),
        ),
        FormField<String>(
          validator: (_) =>
              (d['checklistDirty'] == false ||
                  RegExp(r'^[NRQA]{22}$').hasMatch('${c['regions'] ?? ''}'))
              ? null
              : 'Confira as 22 regiões.',
          builder: (s) => s.hasError
              ? Text(
                  s.errorText!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                )
              : const SizedBox.shrink(),
        ),
        for (final e in {
          'frontTyre': 'Pneu dianteiro',
          'backTyre': 'Pneu traseiro',
          'spareTyre': 'Estepe',
        }.entries)
          choice(c, e.key, e.value, {
            'R': 'Ruim',
            'B': 'Bom',
            'E': 'Excelente',
          }),
        choice(c, 'fuel', 'Combustível', {
          '1': 'Etanol',
          '2': 'Gasolina',
          '3': 'Flex',
          '4': 'Diesel',
          '5': 'G.N.V.',
        }),
        choice(c, 'valves', 'Válvulas', {
          '08': '08',
          '16': '16',
          '20': '20',
          '24': '24',
        }),
        for (final e in accessoryNames.entries)
          CheckboxListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text(e.value),
            value: c[e.key] == 'S',
            onChanged: widget.readOnly
                ? null
                : (v) => change(() => c[e.key] = v == true ? 'S' : 'N'),
          ),
        FormField<bool>(
          validator: (_) =>
              d['checklistDirty'] == false || c['_confirmed'] == true
              ? null
              : 'Confirme a conferência dos acessórios.',
          builder: (s) => Column(
            children: [
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Conferi os acessórios'),
                value: c['_confirmed'] == true,
                onChanged: widget.readOnly
                    ? null
                    : (v) => change(() => c['_confirmed'] = v),
              ),
              if (s.hasError)
                Text(
                  s.errorText!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
            ],
          ),
        ),
        field(c, 'km', 'Quilometragem da inspeção', max: 25),
        field(c, 'notes', 'Observação da inspeção', max: 16000, lines: 3),
        field(c, 'entryDate', 'Entrada (DD/MM/AAAA)', max: 10),
        field(c, 'entryHour', 'Hora de entrada (HH:MM)', max: 5),
        field(c, 'prism', 'Prisma', max: 10),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = documentTotals(d);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        section('Peças e mão de obra', [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: widget.readOnly ? null : () => add(false),
                icon: const Icon(Icons.add),
                label: const Text('Adicionar peça'),
              ),
              OutlinedButton.icon(
                onPressed: widget.readOnly ? null : () => add(true),
                icon: const Icon(Icons.build_outlined),
                label: const Text('Adicionar serviço'),
              ),
            ],
          ),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text('Nenhum item incluído.'),
            ),
          ...List.generate(items.length, (index) {
            final i = Map<String, dynamic>.from(items[index] as Map);
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                i['type'] == 'S'
                    ? Icons.build_outlined
                    : Icons.inventory_2_outlined,
              ),
              title: Text('${i['description']}'),
              subtitle: Text(
                '${i['quantity']} × ${money((amount(i['unitPrice']) * 100).round())} · Desconto ${money((amount(i['discountValue']) * 100).round())}',
              ),
              onTap: widget.readOnly
                  ? null
                  : () async {
                      final r = await editItem(i);
                      if (r != null && mounted) change(() => items[index] = r);
                    },
              trailing: IconButton(
                tooltip: 'Excluir item',
                onPressed: widget.readOnly
                    ? null
                    : () async {
                        final yes = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Excluir item?'),
                            content: Text('${i['description']}'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Cancelar'),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('Excluir'),
                              ),
                            ],
                          ),
                        );
                        if (yes == true && mounted)
                          change(() => items.removeAt(index));
                      },
                icon: const Icon(Icons.delete_outline),
              ),
            );
          }),
        ]),
        section('Valores e observações', [
          field(h, 'freight', 'Frete', numeric: true),
          field(h, 'additional', 'Valor adicional', numeric: true),
          field(h, 'notes', 'Observação do orçamento', max: 16000, lines: 3),
        ]),
        section('Veículo', [
          if (d['vehicle'] == null)
            OutlinedButton(
              onPressed: widget.readOnly
                  ? null
                  : () => change(
                      () => d['vehicle'] = <String, dynamic>{
                        'plate': '',
                        'engine': 0,
                      },
                    ),
              child: const Text('Informar veículo'),
            )
          else
            vehicle(),
        ]),
        if (d['vehicle'] != null)
          section('Checklist', [
            if (d['checklist'] == null)
              OutlinedButton(
                onPressed: widget.readOnly
                    ? null
                    : () => change(
                        () => d['checklist'] = <String, dynamic>{
                          'regions': '_' * 22,
                          for (final k in accessoryNames.keys) k: 'N',
                          '_confirmed': false,
                        },
                      ),
                child: const Text('Iniciar inspeção'),
              )
            else
              checklist(),
          ]),
        const Divider(),
        for (final e in {
          'products': 'Peças',
          'services': 'Mão de obra',
          'discount': 'Desconto',
          'total': 'Total',
        }.entries)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    e.value,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  money((amount(t[e.key]) * 100).round()),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
