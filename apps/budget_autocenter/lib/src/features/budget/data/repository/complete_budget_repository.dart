import 'dart:convert';
import '../../domain/entity/budget_list_entry.dart';
import 'budget_draft_repository.dart';

abstract class CompleteBudgetWriter {
  Future<Map<String, dynamic>> loadDocument(int id);
  Future<Map<String, dynamic>> saveDocument(
    Map<String, dynamic> document,
    String operationId,
  );
  Future<int?> findOperation(String operationId);
  Future<CatalogPage> catalog(
    String kind, {
    String search = '',
    int offset = 0,
    Map<String, String> parameters = const {},
  });
}

class CatalogPage {
  const CatalogPage(this.rows, this.total, this.offset);
  final List<Map<String, dynamic>> rows;
  final int total, offset;
}

class CompleteBudgetRepository extends BudgetDraftRepository
    implements CompleteBudgetWriter {
  CompleteBudgetRepository({super.client});
  Future<Uri> uri(String path, [Map<String, String> params = const {}]) async =>
      Uri.parse('${await getBaseUrl()}autocenter/$path').replace(
        queryParameters: {
          'institutionId': '${await getInstitutionId()}',
          ...params,
        },
      );
  dynamic decode(String body) => jsonDecode(body);
  String message(String body) {
    try {
      return '${(decode(body) as Map)['error'] ?? (decode(body) as Map)['message'] ?? 'A API recusou a operação.'}';
    } catch (_) {
      return 'A API recusou a operação.';
    }
  }

  @override
  Future<Map<String, dynamic>> loadDocument(int id) async {
    final response = await httpClient
        .get(await uri('budgets/$id'), headers: await requestOptions())
        .timeout(const Duration(seconds: 30));
    if (response.statusCode != 200) throw StateError(message(response.body));
    final doc = Map<String, dynamic>.from(decode(response.body) as Map);
    if ('${(doc['header'] as Map)['institutionId']}' !=
        '${await getInstitutionId()}')
      throw const FormatException('Estabelecimento divergente');
    return doc;
  }

  @override
  Future<Map<String, dynamic>> saveDocument(
    Map<String, dynamic> document,
    String operationId,
  ) async {
    final id = (document['header'] as Map)['id'];
    final url = await uri(id == null ? 'budgets' : 'budgets/$id');
    final headers = await requestOptions();
    final body = jsonEncode({
      'institutionId': int.parse('${await getInstitutionId()}'),
      'operationId': operationId,
      'document': document,
    });
    try {
      final response =
          await (id == null
                  ? httpClient.post(url, headers: headers, body: body)
                  : httpClient.put(url, headers: headers, body: body))
              .timeout(const Duration(seconds: 60));
      if ([400, 401, 403, 404, 409, 422, 503].contains(response.statusCode))
        throw StateError(message(response.body));
      if (response.statusCode < 200 || response.statusCode >= 300)
        throw BudgetSaveUncertain();
      final result = Map<String, dynamic>.from(decode(response.body) as Map);
      if ('${(result['header'] as Map)['institutionId']}' !=
          '${await getInstitutionId()}')
        throw BudgetSaveUncertain();
      entryFromDocument(result);
      return result;
    } on StateError {
      rethrow;
    } catch (_) {
      throw BudgetSaveUncertain();
    }
  }

  @override
  Future<int?> findOperation(String operationId) async {
    final response = await httpClient
        .get(
          await uri('operations/$operationId'),
          headers: await requestOptions(),
        )
        .timeout(const Duration(seconds: 30));
    if (response.statusCode == 404) return null;
    if (response.statusCode != 200) throw StateError(message(response.body));
    return (decode(response.body)['id'] as num).toInt();
  }

  @override
  Future<CatalogPage> catalog(
    String kind, {
    String search = '',
    int offset = 0,
    Map<String, String> parameters = const {},
  }) async {
    final response = await httpClient
        .get(
          await uri('catalog/$kind', {
            'search': search,
            'offset': '$offset',
            ...parameters,
          }),
          headers: await requestOptions(),
        )
        .timeout(const Duration(seconds: 30));
    if (response.statusCode != 200) throw StateError(message(response.body));
    final j = decode(response.body) as Map;
    return CatalogPage(
      (j['data'] as List)
          .map((r) => Map<String, dynamic>.from(r as Map))
          .toList(),
      (j['meta']['total'] as num).toInt(),
      (j['meta']['offset'] as num).toInt(),
    );
  }
}

BudgetListEntry entryFromDocument(Map<String, dynamic> doc) =>
    BudgetListEntry.fromJson(Map<String, dynamic>.from(doc['header'] as Map));
