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
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Fechar'),
      ),
    ],
  );
}
