import 'dart:convert';
import 'dart:io';
import 'package:core/gateway.dart';
import 'package:core/src/permission/data/datasource/remote/permission_remote_datasource.dart';
import 'package:http/http.dart' as http;
import '../../domain/entity/budget_list_entry.dart';

class BudgetChoice {
  const BudgetChoice(this.id, this.label);
  final int id;
  final String label;
}

class BudgetChoices {
  const BudgetChoices(this.rows, this.total, this.offset);
  final List<BudgetChoice> rows;
  final int total, offset;
  bool get hasNext => offset + rows.length < total;
}

abstract class BudgetDraftWriter {
  Future<void> authorize();
  Future<BudgetChoices> choices({
    required bool customers,
    String search = '',
    int offset = 0,
  });
  Future<BudgetListEntry> create({
    required BudgetChoice customer,
    required BudgetChoice payment,
    required DateTime date,
    String contact = '',
    String terms = '',
  });
  void close();
}

/// Uma falha após o envio pode ter ocorrido depois do commit no Firebird.
class BudgetSaveUncertain implements Exception {}

class BudgetDraftRepository extends Gateway implements BudgetDraftWriter {
  BudgetDraftRepository({http.Client? client})
    : super(httpClient: client ?? http.Client());

  Future<int> _institution() async {
    final id = int.tryParse('${await getInstitutionId()}') ?? 0;
    final user = int.tryParse('${await getUserId()}') ?? 0;
    if ((await getToken()).isEmpty || user <= 0) {
      throw StateError('Faça login novamente para criar o orçamento.');
    }
    if (id <= 0)
      throw StateError(
        'Selecione um estabelecimento na configuração do servidor.',
      );
    return id;
  }

  @override
  Future<void> authorize() async {
    await _institution();
    final allowed = await PermissionRemoteDatasource(
      httpClient: httpClient,
    ).checkPermission(menu: 'Fr_Cotacao', kind: 'Inserir', situation: 'S');
    if (!allowed.result)
      throw StateError('Usuário sem permissão para inserir orçamentos.');
  }

  @override
  Future<BudgetChoices> choices({
    required bool customers,
    String search = '',
    int offset = 0,
  }) async {
    await _institution();
    final query = Uri(
      queryParameters: {
        'limit': '20',
        'offset': '$offset',
        if (search.trim().isNotEmpty) 'search': search.trim(),
      },
    ).query;
    return request('${customers ? 'customers' : 'payment-types'}?$query', (
      body,
    ) {
      final j = jsonDecode(body as String) as Map<String, dynamic>;
      final rows = (j['data'] as List).map((raw) {
        final r = raw as Map;
        final id = int.tryParse('${r['id']}');
        final label =
            (customers ? (r['name'] ?? r['tradeName']) : r['description'])
                ?.toString()
                .trim() ??
            '';
        if (id == null || id <= 0 || label.isEmpty)
          throw const FormatException('Cadastro inválido');
        return BudgetChoice(id, label);
      }).toList();
      final meta = j['meta'] as Map;
      return BudgetChoices(
        rows,
        (meta['total'] as num).toInt(),
        (meta['offset'] as num).toInt(),
      );
    });
  }

  @override
  Future<BudgetListEntry> create({
    required BudgetChoice customer,
    required BudgetChoice payment,
    required DateTime date,
    String contact = '',
    String terms = '',
  }) async {
    await authorize();
    final institution = await _institution();
    final user = int.parse('${await getUserId()}');
    final salesman = await getSalesmanId();
    if (salesman <= 0)
      throw StateError('O usuário precisa ter um vendedor associado no ERP.');
    if (customer.id <= 0 ||
        payment.id <= 0 ||
        customer.label.isEmpty ||
        customer.label.length > 100 ||
        contact.trim().length > 100 ||
        terms.trim().length > 100) {
      throw StateError(
        'Confira cliente, pagamento e os campos de até 100 caracteres.',
      );
    }
    final data = jsonEncode({
      'userId': user,
      'institutionId': institution,
      'salesmanId': salesman,
      'customerId': customer.id,
      'customerName': customer.label,
      'paymentTypeId': payment.id,
      'date': date.toIso8601String().substring(0, 10),
      'contact': contact.trim(),
      'paymentTerms': terms.trim(),
      'status': 'A',
      'approved': 'N',
      'quantityProducts': 0,
      'totalProducts': 0,
      'freight': 0,
      'discountPercent': 0,
      'discountValue': 0,
      'total': 0,
    });
    // Resolve configuração/cabeçalhos antes da região de resultado incerto.
    final uri = Uri.parse('${await getBaseUrl()}budgets');
    final headers = await requestOptions();
    try {
      final response = await httpClient
          .post(uri, headers: headers, body: data)
          .timeout(const Duration(seconds: 20));
      if ([400, 401, 403, 422].contains(response.statusCode)) {
        throw StateError(
          response.statusCode == 401
              ? 'Sessão expirada. Faça login novamente.'
              : response.statusCode == 403
              ? 'Usuário sem permissão para inserir orçamentos.'
              : 'A API recusou o cadastro. Confira os campos antes de tentar novamente.',
        );
      }
      if (response.statusCode < 200 || response.statusCode >= 300)
        throw BudgetSaveUncertain();
      final result = BudgetListEntry.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
      if (result.id <= 0 || result.institutionId != institution)
        throw BudgetSaveUncertain();
      return result;
    } on StateError {
      rethrow;
    } catch (_) {
      throw BudgetSaveUncertain();
    }
  }

  @override
  void close() => httpClient.close();
}

String draftError(Object error) {
  if (error is StateError) return error.message;
  if (error is BudgetSaveUncertain)
    return 'Não foi possível confirmar a gravação. Volte à lista e atualize para verificar se o rascunho foi criado antes de iniciar outro.';
  if (error is HttpException && error.message.contains('[401]'))
    return 'Sessão expirada. Faça login novamente.';
  return 'Não foi possível acessar o servidor. Confira a conexão e tente novamente.';
}
