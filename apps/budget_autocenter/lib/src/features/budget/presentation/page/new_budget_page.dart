import 'dart:async';
import 'dart:convert';
import '../../data/repository/complete_budget_repository.dart';
import '../widget/budget_contents_editor.dart';
import 'package:flutter/material.dart';
import '../../data/repository/pending_budget_store.dart';
import 'package:intl/intl.dart';
import '../../data/repository/budget_draft_repository.dart';
import '../../domain/entity/budget_list_entry.dart';

class NewBudgetPage extends StatefulWidget {
  const NewBudgetPage({super.key, this.writer, this.store, this.initialDraft});
  final BudgetDraftWriter? writer;
  final PendingBudgetStore? store;
  final PendingBudget? initialDraft;
  @override
  State<NewBudgetPage> createState() => _NewBudgetState();
}

class _NewBudgetState extends State<NewBudgetPage> {
  late final BudgetDraftWriter writer;
  late PendingBudgetStore store;
  PendingBudget? draft;
  Map<String, dynamic> document = {};
  final form = GlobalKey<FormState>();
  final contact = TextEditingController(), terms = TextEditingController();
  DateTime date = DateTime.now();
  BudgetChoice? customer, payment;
  bool checking = true, saving = false, confirming = false, uncertain = false;
  bool authorized = false, hasEdits = false, completed = false, leaving = false;
  String? error, localError;
  int localWrites = 0;
  Future<void> tail = Future<void>.value();

  @override
  void initState() {
    super.initState();
    writer = widget.writer ?? CompleteBudgetRepository();
    authorize();
  }

  // A leitura do rascunho não depende de conexão. Permissão é checada no envio.
  Future<void> authorize() async {
    setState(() {
      checking = true;
      error = null;
    });
    try {
      store = widget.store ?? await PreferencesPendingBudgetStore.open();
      draft = widget.initialDraft ?? await store.allocate(date);
      document = Map<String, dynamic>.from(
        jsonDecode(jsonEncode(draft!.document)) as Map,
      );
      document.putIfAbsent('items', () => <dynamic>[]);
      final header =
          document.putIfAbsent('header', () => <String, dynamic>{}) as Map;
      header['freight'] ??= 0;
      header['additional'] ??= 0;
      date = draft!.date;
      customer = draft!.customer;
      payment = draft!.payment;
      contact.text = draft!.contact;
      terms.text = draft!.terms;
      uncertain = draft!.review;
      hasEdits = widget.initialDraft != null;
      contact.addListener(changed);
      terms.addListener(changed);
      authorized = true;
    } catch (e) {
      if (mounted) setState(() => error = draftError(e));
    } finally {
      if (mounted) setState(() => checking = false);
    }
  }

  PendingBudget snapshot({bool? review, int? remoteId}) => PendingBudget(
    id: draft!.id,
    sequence: draft!.sequence,
    date: date,
    customer: customer,
    payment: payment,
    contact: contact.text,
    terms: terms.text,
    review: review ?? uncertain,
    remoteId: remoteId,
    document: fullDocument(),
  );

  Map<String, dynamic> fullDocument() => {
    ...document,
    'header': {
      ...Map<String, dynamic>.from(document['header'] as Map? ?? {}),
      'customerId': customer?.id,
      'customerName': customer?.label ?? '',
      'paymentTypeId': payment?.id,
      'date': date.toIso8601String().substring(0, 10),
      'contact': contact.text,
      'paymentTerms': terms.text,
      'freight': amount((document['header'] as Map?)?['freight']),
      'additional': amount((document['header'] as Map?)?['additional']),
    },
    'items': document['items'] ?? [],
  };
  Future<void> confirmOperation() async {
    if (writer is! CompleteBudgetWriter || saving) return;
    setState(() => saving = true);
    try {
      final api = writer as CompleteBudgetWriter;
      final id = await api.findOperation(draft!.id);
      if (id == null)
        throw StateError(
          'O servidor ainda não confirmou este envio. Confira novamente antes de iniciar outro orçamento.',
        );
      final result = entryFromDocument(await api.loadDocument(id));
      await store.put(snapshot(review: true, remoteId: result.id));
      try {
        await store.remove(draft!.id);
      } catch (_) {}
      completed = true;
      if (mounted) Navigator.pop<BudgetListEntry>(context, result);
    } catch (e) {
      if (mounted) setState(() => error = draftError(e));
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  void changed() {
    if (!authorized || saving || uncertain || completed) return;
    hasEdits = true;
    unawaited(persist());
  }

  Future<bool> persist() async {
    if (!authorized || completed) return false;
    final value = snapshot();
    final work = tail.then((_) => store.put(value));
    // Uma falha não impede que uma edição posterior seja salva.
    tail = work.then<void>((_) {}, onError: (Object _, StackTrace __) {});
    if (mounted) setState(() => localWrites++);
    try {
      await work;
      if (mounted) setState(() => localError = null);
      return true;
    } catch (_) {
      if (mounted)
        setState(
          () => localError =
              'Não foi possível salvar no aparelho. Mantenha esta tela aberta e tente novamente.',
        );
      return false;
    } finally {
      if (mounted) setState(() => localWrites--);
    }
  }

  Future<void> leave() async {
    if (saving || leaving) return;
    leaving = true;
    if (hasEdits && !await persist()) {
      leaving = false;
      return;
    }
    await tail;
    if (mounted) Navigator.pop(context);
  }

  Future<void> discard() async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Descartar rascunho local?'),
        content: const Text(
          'Isso remove apenas os dados salvos neste aparelho. Um orçamento já recebido pelo ERP não será excluído.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Descartar'),
          ),
        ],
      ),
    );
    if (yes != true || !mounted) return;
    try {
      await tail;
      await store.remove(draft!.id);
      completed = true;
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted)
        setState(
          () => localError = 'Não foi possível descartar o rascunho local.',
        );
    }
  }

  @override
  void dispose() {
    contact.removeListener(changed);
    terms.removeListener(changed);
    contact.dispose();
    terms.dispose();
    if (widget.writer == null) writer.close();
    super.dispose();
  }

  Future<void> choose(bool customers) async {
    final value = await showDialog<BudgetChoice>(
      context: context,
      builder: (_) => _ChoiceDialog(writer: writer, customers: customers),
    );
    if (mounted && value != null) {
      setState(() {
        if (customers) {
          customer = value;
        } else {
          payment = value;
        }
      });
      changed();
    }
  }

  Future<void> save({bool retry = false}) async {
    if (saving || confirming || (uncertain && !retry)) return;
    // Completa apenas a inspeção em edição. Reenvios usam o conteúdo original.
    final checklist = document['checklist'] as Map?;
    if (!retry &&
        !uncertain &&
        checklist != null &&
        document['checklistDirty'] != false) {
      final regions = '${checklist['regions'] ?? ''}';
      if (regions.length <= 22 && RegExp(r'^[NRQA_]*$').hasMatch(regions)) {
        checklist['regions'] = regions.padRight(22, '_').replaceAll('_', 'N');
      }
    }
    if (!(form.currentState?.validate() ?? false)) {
      setState(
        () => error = 'Confira os campos obrigatórios nas seções do orçamento.',
      );
      return;
    }
    setState(() => confirming = true);
    if (!await persist() || !mounted) {
      if (mounted) setState(() => confirming = false);
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          (document['header'] as Map?)?['id'] == null
              ? 'Criar rascunho no ERP?'
              : 'Salvar alterações no ERP?',
        ),
        content: const Text(
          'Serão enviados os dados do orçamento, itens e a inspeção preenchida ao ERP.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              (document['header'] as Map?)?['id'] == null
                  ? 'Criar rascunho'
                  : 'Confirmar alterações',
            ),
          ),
        ],
      ),
    );
    if (!mounted) return;
    setState(() => confirming = false);
    if (confirmed != true) return;
    setState(() {
      saving = true;
      error = null;
    });
    try {
      await tail;
      // Marcador durável ANTES do POST. Se o app fechar durante o envio, não reenvia ao abrir.
      if (writer is CompleteBudgetWriter)
        document['_transport'] = 'autocenter-v1';
      await store.put(snapshot(review: true));
    } catch (_) {
      if (mounted)
        setState(() {
          saving = false;
          localError =
              'Não foi possível proteger o rascunho local. O envio não foi iniciado.';
        });
      return;
    }
    try {
      final result = writer is CompleteBudgetWriter
          ? entryFromDocument(
              await (writer as CompleteBudgetWriter).saveDocument(
                fullDocument(),
                draft!.id,
              ),
            )
          : await writer.create(
              customer: customer!,
              payment: payment!,
              date: date,
              contact: contact.text,
              terms: terms.text,
            );
      // Confirma o ID remoto antes de remover. Se a remoção falhar, não volta a ser pendente.
      await store.put(snapshot(review: true, remoteId: result.id));
      try {
        await store.remove(draft!.id);
      } catch (_) {}
      completed = true;
      if (mounted) Navigator.pop<BudgetListEntry>(context, result);
    } catch (e) {
      bool review = e is! StateError;
      if (!review) {
        try {
          await store.put(snapshot(review: false));
        } catch (_) {
          review = true;
        }
      }
      if (mounted)
        setState(() {
          uncertain = review;
          error = draftError(review ? BudgetSaveUncertain() : e);
        });
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    onPopInvokedWithResult: (didPop, result) {
      if (!didPop) unawaited(leave());
    },
    child: Scaffold(
      appBar: AppBar(
        title: Text(
          widget.initialDraft == null
              ? 'Novo orçamento'
              : 'Rascunho #${draft?.sequence ?? widget.initialDraft!.sequence}',
        ),
        actions: [
          if (hasEdits)
            IconButton(
              tooltip: 'Descartar rascunho local',
              onPressed: saving ? null : discard,
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      body: checking
          ? const Center(child: CircularProgressIndicator())
          : !authorized
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(error!, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: authorize,
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            )
          : Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: form,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (uncertain)
                          const Card(
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: Text(
                                'Envio a conferir. Atualize a lista e confira o ERP antes de iniciar outro orçamento.',
                              ),
                            ),
                          ),
                        if (hasEdits && !uncertain)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              localWrites > 0
                                  ? 'Salvando no aparelho...'
                                  : localError != null
                                  ? 'Rascunho ainda não salvo'
                                  : 'Rascunho salvo no aparelho · PENDENTE',
                              style: TextStyle(color: Colors.orange.shade700),
                            ),
                          ),
                        if (localError != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Column(
                              children: [
                                Text(
                                  localError!,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => persist(),
                                  child: const Text(
                                    'Tentar salvar no aparelho',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'Preencha o orçamento. As alterações ficam pendentes no aparelho até você confirmar o envio ao ERP.',
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _choice(
                          'Cliente',
                          customer,
                          () => choose(true),
                          'Selecione um cliente',
                        ),
                        const SizedBox(height: 16),
                        _choice(
                          'Forma de pagamento',
                          payment,
                          () => choose(false),
                          'Selecione uma forma de pagamento',
                        ),
                        const SizedBox(height: 16),
                        InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Data',
                            border: OutlineInputBorder(),
                          ),
                          child: InkWell(
                            onTap: saving || uncertain
                                ? null
                                : () async {
                                    final d = await showDatePicker(
                                      context: context,
                                      initialDate: date,
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2100),
                                    );
                                    if (mounted && d != null) {
                                      setState(() => date = d);
                                      changed();
                                    }
                                  },
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    DateFormat('dd/MM/yyyy').format(date),
                                  ),
                                ),
                                const Icon(Icons.calendar_today),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: terms,
                          enabled: !saving && !uncertain,
                          maxLength: 100,
                          decoration: const InputDecoration(
                            labelText: 'Prazo / condição de pagamento',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: contact,
                          enabled: !saving && !uncertain,
                          maxLength: 100,
                          decoration: const InputDecoration(
                            labelText: 'Contato',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        if (writer is CompleteBudgetWriter)
                          BudgetContentsEditor(
                            document: document,
                            api: writer as CompleteBudgetWriter,
                            onChanged: changed,
                            readOnly: saving || uncertain,
                          ),
                        if (error != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              error!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                        if (uncertain &&
                            writer is CompleteBudgetWriter &&
                            document['_transport'] == 'autocenter-v1')
                          OutlinedButton(
                            onPressed: saving ? null : confirmOperation,
                            child: const Text('Conferir envio no servidor'),
                          ),
                        if (uncertain &&
                            writer is CompleteBudgetWriter &&
                            document['_transport'] == 'autocenter-v1')
                          OutlinedButton(
                            onPressed: saving ? null : () => save(retry: true),
                            child: const Text('Repetir o mesmo envio'),
                          ),
                        if (uncertain)
                          OutlinedButton(
                            onPressed: leave,
                            child: const Text('Voltar à lista'),
                          ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: saving || confirming || uncertain
                              ? null
                              : save,
                          icon: saving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.save_outlined),
                          label: Text(
                            saving ? 'Salvando...' : 'Salvar rascunho',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    ),
  );

  Widget _choice(
    String label,
    BudgetChoice? value,
    VoidCallback onTap,
    String missing,
  ) => FormField<BudgetChoice>(
    key: ValueKey('$label-${value?.id}'),
    initialValue: value,
    validator: (_) => value == null ? missing : null,
    builder: (field) => InkWell(
      onTap: saving || uncertain ? null : onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          errorText: field.errorText,
        ),
        child: Row(
          children: [
            Expanded(child: Text(value?.label ?? missing)),
            const Icon(Icons.search),
          ],
        ),
      ),
    ),
  );
}

class _ChoiceDialog extends StatefulWidget {
  const _ChoiceDialog({required this.writer, required this.customers});
  final BudgetDraftWriter writer;
  final bool customers;
  @override
  State<_ChoiceDialog> createState() => _ChoiceState();
}

class _ChoiceState extends State<_ChoiceDialog> {
  final search = TextEditingController();
  BudgetChoices? page;
  bool loading = true;
  String? error;
  String applied = '';
  int request = 0;
  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    request++;
    search.dispose();
    super.dispose();
  }

  Future<void> load({int offset = 0}) async {
    final id = ++request;
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final result = await widget.writer.choices(
        customers: widget.customers,
        search: applied,
        offset: offset,
      );
      if (mounted && request == id) setState(() => page = result);
    } catch (e) {
      if (mounted && request == id) setState(() => error = draftError(e));
    } finally {
      if (mounted && request == id) setState(() => loading = false);
    }
  }

  void find() {
    applied = search.text;
    load();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(
      widget.customers ? 'Selecionar cliente' : 'Selecionar pagamento',
    ),
    content: SizedBox(
      width: 520,
      height: 380,
      child: Column(
        children: [
          TextField(
            controller: search,
            onSubmitted: (_) => find(),
            decoration: InputDecoration(
              labelText: 'Buscar',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                tooltip: 'Buscar cadastro',
                onPressed: loading ? null : find,
                icon: const Icon(Icons.search),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : error != null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(error!),
                        TextButton(
                          onPressed: () => load(),
                          child: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  )
                : page!.rows.isEmpty
                ? const Center(child: Text('Nenhum cadastro encontrado.'))
                : ListView.builder(
                    itemCount: page!.rows.length,
                    itemBuilder: (_, i) {
                      final item = page!.rows[i];
                      return ListTile(
                        title: Text(item.label),
                        subtitle: Text('Código ${item.id}'),
                        onTap: () => Navigator.pop(context, item),
                      );
                    },
                  ),
          ),
          if (page != null && !loading && error == null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  tooltip: 'Página anterior',
                  onPressed: page!.offset > 0
                      ? () => load(
                          offset: (page!.offset - 20).clamp(0, page!.total),
                        )
                      : null,
                  icon: const Icon(Icons.chevron_left),
                ),
                Expanded(
                  child: Text(
                    '${page!.total == 0 ? 0 : page!.offset + 1}–${page!.offset + page!.rows.length} de ${page!.total}',
                    textAlign: TextAlign.center,
                  ),
                ),
                IconButton(
                  tooltip: 'Próxima página',
                  onPressed: page!.hasNext
                      ? () => load(offset: page!.offset + 20)
                      : null,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Fechar'),
      ),
    ],
  );
}
