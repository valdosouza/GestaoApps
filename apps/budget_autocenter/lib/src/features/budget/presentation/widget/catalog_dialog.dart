import 'package:flutter/material.dart';
import '../../data/repository/complete_budget_repository.dart';

Future<Map<String, dynamic>?> chooseCatalog(
  BuildContext context,
  CompleteBudgetWriter api,
  String kind,
  String title, {
  Map<String, String> parameters = const {},
}) => showDialog<Map<String, dynamic>>(
  context: context,
  builder: (_) =>
      _Catalog(api: api, kind: kind, title: title, parameters: parameters),
);

class _Catalog extends StatefulWidget {
  const _Catalog({
    required this.api,
    required this.kind,
    required this.title,
    required this.parameters,
  });
  final CompleteBudgetWriter api;
  final String kind, title;
  final Map<String, String> parameters;
  @override
  State<_Catalog> createState() => _CatalogState();
}

class _CatalogState extends State<_Catalog> {
  final controller = TextEditingController();
  CatalogPage? page;
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
    controller.dispose();
    super.dispose();
  }

  Future<void> load([int offset = 0]) async {
    final id = ++request;
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final result = await widget.api.catalog(
        widget.kind,
        search: applied,
        offset: offset,
        parameters: widget.parameters,
      );
      if (mounted && request == id) setState(() => page = result);
    } catch (e) {
      if (mounted && request == id)
        setState(
          () => error = e is StateError
              ? e.message
              : 'Não foi possível consultar o cadastro.',
        );
    } finally {
      if (mounted && request == id) setState(() => loading = false);
    }
  }

  void search() {
    applied = controller.text.trim();
    load();
  }

  Future<void> create() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _CreateCatalog(
        api: widget.api,
        kind: widget.kind,
        title: widget.title,
        parameters: widget.parameters,
        initialName: controller.text.trim(),
      ),
    );
    if (mounted && result != null) Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.title),
    content: SizedBox(
      width: 540,
      height: 380,
      child: Column(
        children: [
          TextField(
            controller: controller,
            onSubmitted: (_) => search(),
            decoration: InputDecoration(
              labelText: 'Buscar',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                tooltip: 'Buscar cadastro',
                onPressed: loading ? null : search,
                icon: const Icon(Icons.search),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : error != null
                ? Center(child: Text(error!))
                : page!.rows.isEmpty
                ? const Center(child: Text('Nenhum cadastro encontrado.'))
                : ListView(
                    children: page!.rows
                        .map(
                          (r) => ListTile(
                            title: Text('${r['label']}'),
                            subtitle: r['price'] == null
                                ? null
                                : Text('R\$ ${r['price']}'),
                            onTap: () => Navigator.pop(context, r),
                          ),
                        )
                        .toList(),
                  ),
          ),
          if (page != null && !loading)
            Row(
              children: [
                IconButton(
                  tooltip: 'Página anterior',
                  onPressed: page!.offset > 0
                      ? () => load((page!.offset - 20).clamp(0, page!.total))
                      : null,
                  icon: const Icon(Icons.chevron_left),
                ),
                Expanded(
                  child: Text(
                    '${page!.total} registro(s)',
                    textAlign: TextAlign.center,
                  ),
                ),
                IconButton(
                  tooltip: 'Próxima página',
                  onPressed: page!.offset + page!.rows.length < page!.total
                      ? () => load(page!.offset + 20)
                      : null,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
        ],
      ),
    ),
    actions: [
      if (page?.canCreate == true)
        TextButton.icon(
          onPressed: loading ? null : create,
          icon: const Icon(Icons.add),
          label: const Text('Cadastrar novo'),
        ),
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Fechar'),
      ),
    ],
  );
}

class _CreateCatalog extends StatefulWidget {
  const _CreateCatalog({
    required this.api,
    required this.kind,
    required this.title,
    required this.parameters,
    required this.initialName,
  });
  final CompleteBudgetWriter api;
  final String kind, title, initialName;
  final Map<String, String> parameters;
  @override
  State<_CreateCatalog> createState() => _CreateCatalogState();
}

class _CreateCatalogState extends State<_CreateCatalog> {
  final form = GlobalKey<FormState>();
  late final name = TextEditingController(text: widget.initialName);
  bool saving = false;
  String? error;

  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (saving || !form.currentState!.validate()) return;
    setState(() {
      saving = true;
      error = null;
    });
    try {
      final result = await widget.api.createCatalog(
        widget.kind,
        name.text.trim(),
        parameters: widget.parameters,
      );
      if (mounted) Navigator.pop(context, result);
    } catch (e) {
      if (mounted)
        setState(() {
          saving = false;
          error = e is StateError
              ? e.message
              : 'Não foi possível salvar o cadastro.';
        });
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !saving,
    child: AlertDialog(
      title: Text('Cadastrar ${widget.title.toLowerCase()}'),
      scrollable: true,
      content: Form(
        key: form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'O cadastro será salvo no Gestão e selecionado neste orçamento.',
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: name,
              autofocus: true,
              enabled: !saving,
              maxLength: 100,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Descrição',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  (value ?? '').trim().isEmpty ? 'Informe a descrição' : null,
              onFieldSubmitted: (_) => save(),
            ),
            if (error != null)
              Text(
                error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: saving ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: saving ? null : save,
          child: Text(saving ? 'Salvando...' : 'Salvar e selecionar'),
        ),
      ],
    ),
  );
}
