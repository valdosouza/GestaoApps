import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'budget_draft_repository.dart';

/// Cabeçalho ainda não confirmado no ERP. Não usa o ID remoto como ID local.
class PendingBudget {
  const PendingBudget({
    required this.id,
    required this.sequence,
    required this.date,
    this.customer,
    this.payment,
    this.contact = '',
    this.terms = '',
    this.review = false,
    this.remoteId,
    this.document = const {},
  });
  final String id;
  final int sequence;
  final DateTime date;
  final BudgetChoice? customer, payment;
  final String contact, terms;
  final bool review;
  final int? remoteId;
  final Map<String, dynamic> document;
  Map<String, dynamic> toJson() => {
    'version': 1,
    'id': id,
    'sequence': sequence,
    'date': date.toIso8601String(),
    'customer': customer == null
        ? null
        : {'id': customer!.id, 'label': customer!.label},
    'payment': payment == null
        ? null
        : {'id': payment!.id, 'label': payment!.label},
    'contact': contact,
    'terms': terms,
    'review': review,
    'remoteId': remoteId,
    'document': document,
  };
  factory PendingBudget.fromJson(Map<String, dynamic> j) {
    BudgetChoice? choice(dynamic r) => r == null
        ? null
        : BudgetChoice((r['id'] as num).toInt(), r['label'] as String);
    if (j['version'] != 1 || (j['id'] as String).isEmpty)
      throw const FormatException('Rascunho inválido');
    return PendingBudget(
      id: j['id'] as String,
      sequence: (j['sequence'] as num).toInt(),
      date: DateTime.parse(j['date'] as String),
      customer: choice(j['customer']),
      payment: choice(j['payment']),
      contact: j['contact'] as String,
      terms: j['terms'] as String,
      review: j['review'] as bool,
      remoteId: (j['remoteId'] as num?)?.toInt(),
      document: Map<String, dynamic>.from(j['document'] as Map? ?? {}),
    );
  }
}

abstract class PendingBudgetStore {
  Future<List<PendingBudget>> all();
  Future<PendingBudget> allocate(DateTime date);
  Future<void> put(PendingBudget draft);
  Future<void> remove(String id);
}

/// Apenas cabeçalhos pequenos nesta camada. Isolamento por servidor/loja/usuário.
/// Cada rascunho tem uma chave própria, evitando sobrescrever outros rascunhos.
class PreferencesPendingBudgetStore implements PendingBudgetStore {
  PreferencesPendingBudgetStore._(this.prefs, this.scope);
  final SharedPreferences prefs;
  final String scope;
  static Future<PreferencesPendingBudgetStore> open() async {
    final prefs = await SharedPreferences.getInstance();
    final server = (prefs.getString('server_ip') ?? '').trim().toLowerCase();
    final user = int.tryParse('${prefs.get('tb_user_id')}') ?? 0;
    final institution = int.tryParse('${prefs.get('tb_institution_id')}') ?? 0;
    if (server.isEmpty || user <= 0 || institution <= 0)
      throw StateError(
        'Faça login e selecione um estabelecimento para acessar os rascunhos locais.',
      );
    return PreferencesPendingBudgetStore._(
      prefs,
      'autocenter.pending.v1.${Uri.encodeComponent(server)}.$institution.$user.',
    );
  }

  String key(String id) => '${scope}draft.$id';
  @override
  Future<List<PendingBudget>> all() async {
    await prefs.reload();
    final result = <PendingBudget>[];
    for (final k in prefs.getKeys().where(
      (k) => k.startsWith('${scope}draft.'),
    )) {
      final raw = prefs.getString(k);
      if (raw == null) continue;
      final draft = PendingBudget.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
      if (draft.remoteId == null) result.add(draft);
    }
    result.sort((a, b) => b.sequence.compareTo(a.sequence));
    return result;
  }

  @override
  Future<PendingBudget> allocate(DateTime date) async {
    await prefs.reload();
    final sequence = (prefs.getInt('${scope}sequence') ?? 0) + 1;
    if (!await prefs.setInt('${scope}sequence', sequence))
      throw StateError('Não foi possível preparar o rascunho local.');
    final id =
        DateTime.now().microsecondsSinceEpoch.toRadixString(36) +
        '-' +
        Random.secure().nextInt(1 << 30).toRadixString(36);
    return PendingBudget(id: id, sequence: sequence, date: date);
  }

  @override
  Future<void> put(PendingBudget draft) async {
    if (!await prefs.setString(key(draft.id), jsonEncode(draft.toJson()))) {
      throw StateError(
        'Não foi possível salvar no aparelho. Mantenha a tela aberta e tente novamente.',
      );
    }
  }

  @override
  Future<void> remove(String id) async {
    if (!await prefs.remove(key(id)))
      throw StateError('Não foi possível remover o rascunho local.');
  }
}
