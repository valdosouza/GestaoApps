import 'dart:convert';
import 'dart:io';
import 'package:core/gateway.dart';
import 'package:core/src/permission/data/datasource/remote/permission_remote_datasource.dart';
import 'package:http/http.dart' as http;
import '../../domain/entity/budget_list_entry.dart';

abstract class BudgetListReader {
  Future<BudgetListPageData> load({
    int offset = 0,
    int limit = 20,
    DateTime? from,
    DateTime? to,
    String? number,
    String? customerName,
  });
  void close();
}

/// Apenas leitura de orçamentos. Permissão e sessão seguem o Sales/core.
class RealBudgetListRepository extends Gateway implements BudgetListReader {
  RealBudgetListRepository({http.Client? client})
    : super(httpClient: client ?? http.Client());
  @override
  Future<BudgetListPageData> load({
    int offset = 0,
    int limit = 20,
    DateTime? from,
    DateTime? to,
    String? number,
    String? customerName,
  }) async {
    if ((await getToken()).isEmpty)
      throw StateError('Faça login novamente para consultar os orçamentos.');
    final institution = int.tryParse('${await getInstitutionId()}') ?? 0;
    if (institution <= 0)
      throw StateError(
        'Selecione um estabelecimento na configuração do servidor.',
      );
    if (from != null && to != null && from.isAfter(to))
      throw StateError('A data inicial deve ser anterior à data final.');
    final allowed = await PermissionRemoteDatasource(
      httpClient: httpClient,
    ).checkPermission(menu: 'Fr_Cotacao', kind: 'Visualizar', situation: 'S');
    if (!allowed.result)
      throw StateError('Usuário sem permissão para visualizar orçamentos.');
    String day(DateTime d) =>
        '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    final query = Uri(
      queryParameters: {
        'institutionId': '$institution',
        'limit': '$limit',
        'offset': '$offset',
        if (number?.trim().isNotEmpty ?? false) 'number': number!.trim(),
        if (customerName?.trim().isNotEmpty ?? false)
          'customerName': customerName!.trim(),
        if (from != null) 'dateFrom': day(from),
        if (to != null) 'dateTo': day(to),
      },
    ).query;
    return request('budgets?$query', (body) {
      final json = jsonDecode(body as String) as Map<String, dynamic>;
      final rows = (json['data'] as List)
          .map(
            (r) =>
                BudgetListEntry.fromJson(Map<String, dynamic>.from(r as Map)),
          )
          .toList();
      if (rows.any((r) => r.institutionId != institution))
        throw const FormatException('Estabelecimento divergente');
      final meta = json['meta'] as Map<String, dynamic>;
      return BudgetListPageData(
        rows,
        (meta['total'] as num).toInt(),
        (meta['offset'] as num).toInt(),
        (meta['limit'] as num).toInt(),
      );
    });
  }

  @override
  void close() => httpClient.close();
}

String budgetListError(Object error) {
  if (error is StateError) return error.message;
  if (error is HttpException && error.message.contains('[401]'))
    return 'Sessão expirada. Faça login novamente.';
  if (error is HttpException && error.message.contains('[403]'))
    return 'Acesso negado à consulta de orçamentos.';
  if (error is FormatException)
    return 'A API retornou dados em um formato inesperado.';
  return 'Não foi possível carregar os orçamentos. Verifique o servidor e tente novamente.';
}
