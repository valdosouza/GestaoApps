import 'dart:convert';
import 'package:flutter/material.dart';
import '../../data/repository/complete_budget_repository.dart';
import '../../data/repository/budget_draft_repository.dart';
import '../../data/repository/pending_budget_store.dart';
import '../../domain/entity/budget_list_entry.dart';
import '../widget/budget_contents_editor.dart';
import 'new_budget_page.dart';

class BudgetDetailsPage extends StatefulWidget {
  const BudgetDetailsPage({
    super.key,
    required this.id,
    required this.store,
    this.writer,
  });
  final int id;
  final PendingBudgetStore store;
  final BudgetDraftWriter? writer;
  @override
  State<BudgetDetailsPage> createState() => _DetailsState();
}

class _DetailsState extends State<BudgetDetailsPage> {
  late final BudgetDraftWriter writer;
  CompleteBudgetWriter get api => writer as CompleteBudgetWriter;
  Map<String, dynamic>? document;
  bool loading = true;
  String? error;
  @override
  void initState() {
    super.initState();
    writer = widget.writer ?? CompleteBudgetRepository();
    load();
  }

  @override
  void dispose() {
    if (widget.writer == null) writer.close();
    super.dispose();
  }

  Future<void> load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final d = await api.loadDocument(widget.id);
      if (mounted) setState(() => document = d);
    } catch (e) {
      if (mounted) setState(() => error = draftError(e));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> edit() async {
    try {
      final d = Map<String, dynamic>.from(
            jsonDecode(jsonEncode(document)) as Map,
          ),
          h = d['header'] as Map;
      if (d['checklist'] != null) (d['checklist'] as Map)['_confirmed'] = true;
      final date = DateTime.parse(h['date'] as String),
          seed = await widget.store.allocate(
            DateTime.parse(h['date'] as String),
          );
      final draft = PendingBudget(
        id: seed.id,
        sequence: seed.sequence,
        date: date,
        customer: (h['customerId'] as num? ?? 0) <= 0
            ? null
            : BudgetChoice(
                (h['customerId'] as num).toInt(),
                '${h['customerName'] ?? ''}',
              ),
        payment: (h['paymentTypeId'] as num? ?? 0) <= 0
            ? null
            : BudgetChoice(
                (h['paymentTypeId'] as num).toInt(),
                '${h['paymentLabel'] ?? 'Pagamento'}',
              ),
        contact: '${h['contact'] ?? ''}',
        terms: '${h['paymentTerms'] ?? ''}',
        document: d,
      );
      if (!mounted) return;
      final result = await Navigator.push<BudgetListEntry>(
        context,
        MaterialPageRoute(
          builder: (_) => NewBudgetPage(
            writer: writer,
            store: widget.store,
            initialDraft: draft,
          ),
        ),
      );
      if (mounted && result != null) await load();
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(draftError(e))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final h = document?['header'] as Map?;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          h == null
              ? 'Orçamento'
              : '${h['number'] ?? ''}'.isEmpty
              ? 'Orçamento #${widget.id}'
              : '${h['number']}',
        ),
        actions: [
          IconButton(
            tooltip: 'Atualizar detalhes',
            onPressed: loading ? null : load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(error!),
                  TextButton(
                    onPressed: load,
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            )
          : Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        '${h!['customerName'] ?? 'Cliente não informado'}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text('Data: ${h['date']}'),
                      Text('Contato: ${h['contact'] ?? ''}'),
                      Text(
                        'Pagamento: ${h['paymentLabel'] ?? ''} · ${h['paymentTerms'] ?? ''}',
                      ),
                      const SizedBox(height: 12),
                      if (document!['editable'] == true)
                        FilledButton.icon(
                          onPressed: edit,
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('Editar orçamento'),
                        )
                      else
                        const Text(
                          'Consulta: orçamento em uso no desktop, aprovado, encerrado ou convertido em pedido.',
                        ),
                      const SizedBox(height: 12),
                      Text('Total registrado no ERP: ${h['total']}'),
                      BudgetContentsEditor(
                        document: document!,
                        api: api,
                        onChanged: () {},
                        readOnly: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
