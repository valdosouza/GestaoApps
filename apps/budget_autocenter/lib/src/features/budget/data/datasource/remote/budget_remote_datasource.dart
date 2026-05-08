import 'dart:convert';

import 'package:core/gateway.dart';
import 'package:budget_autocenter/src/features/budget/data/model/budget_item_model.dart';
import 'package:budget_autocenter/src/features/budget/data/model/budget_model.dart';
import 'package:budget_autocenter/src/features/budget/data/model/customer_model.dart';
import 'package:budget_autocenter/src/features/budget/data/model/payment_type_model.dart';
import 'package:budget_autocenter/src/features/budget/data/model/product_model.dart';
import 'package:budget_autocenter/src/features/budget/domain/entity/budget_entity.dart';
import 'package:budget_autocenter/src/features/budget/domain/entity/budget_item_entity.dart';

class BudgetRemoteDatasource extends Gateway {
  BudgetRemoteDatasource({required super.httpClient});

  /// Extrai uma List do body, suportando resposta direta `[...]`
  /// ou envelope `{"rows":[...],"data":[...],"items":[...]}`.
  static List<dynamic> _decodeList(String body) {
    final decoded = jsonDecode(body);
    if (decoded is List) return decoded;
    if (decoded is Map<String, dynamic>) {
      for (final key in ['rows', 'data', 'items', 'records', 'result']) {
        if (decoded[key] is List) return decoded[key] as List<dynamic>;
      }
    }
    return [];
  }

  // ── Budgets ──────────────────────────────────────────────────────────────

  Future<List<BudgetModel>> getBudgets({
    String? number,
    String? dateStart,
    String? dateEnd,
    String? customerName,
    int? institutionId,
  }) async {
    final params = <String, String>{};
    if (number != null && number.isNotEmpty) params['number'] = number;
    if (dateStart != null && dateStart.isNotEmpty) params['dateStart'] = dateStart;
    if (dateEnd != null && dateEnd.isNotEmpty) params['dateEnd'] = dateEnd;
    if (customerName != null && customerName.isNotEmpty) {
      params['customerName'] = customerName;
    }
    if (institutionId != null && institutionId > 0) {
      params['institutionId'] = institutionId.toString();
    }

    final query =
        params.isEmpty ? '' : '?${params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&')}';

    return request(
      'budgets$query',
      (body) {
        final list = _decodeList(body);
        return list
            .map((e) => BudgetModel.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  Future<BudgetModel> getBudgetById(int id) => request(
        'budgets/$id',
        (body) => BudgetModel.fromJson(jsonDecode(body) as Map<String, dynamic>),
      );

  Future<BudgetModel> createBudget(BudgetEntity budget) => request(
        'budgets',
        (body) => BudgetModel.fromJson(jsonDecode(body) as Map<String, dynamic>),
        method: HTTPMethod.post,
        data: jsonEncode(BudgetModel.fromEntity(budget).toJson()),
      );

  Future<BudgetModel> updateBudget(BudgetEntity budget) => request(
        'budgets/${budget.id}',
        (body) => BudgetModel.fromJson(jsonDecode(body) as Map<String, dynamic>),
        method: HTTPMethod.put,
        data: jsonEncode(BudgetModel.fromEntity(budget).toJson()),
      );

  // ── Budget Items ──────────────────────────────────────────────────────────

  Future<List<BudgetItemModel>> getBudgetItems(int budgetId) => request(
        'budgets/$budgetId/items',
        (body) {
          final list = _decodeList(body);
          return list
              .map((e) => BudgetItemModel.fromJson(e as Map<String, dynamic>))
              .toList();
        },
      );

  Future<BudgetItemModel> createBudgetItem(
          int budgetId, BudgetItemEntity item) =>
      request(
        'budgets/$budgetId/items',
        (body) =>
            BudgetItemModel.fromJson(jsonDecode(body) as Map<String, dynamic>),
        method: HTTPMethod.post,
        data: jsonEncode(BudgetItemModel.fromEntity(item).toJson()),
      );

  Future<BudgetItemModel> updateBudgetItem(
          int budgetId, BudgetItemEntity item) =>
      request(
        'budgets/$budgetId/items/${item.id}',
        (body) =>
            BudgetItemModel.fromJson(jsonDecode(body) as Map<String, dynamic>),
        method: HTTPMethod.put,
        data: jsonEncode(BudgetItemModel.fromEntity(item).toJson()),
      );

  Future<bool> deleteBudgetItem(int budgetId, int itemId) => request(
        'budgets/$budgetId/items/$itemId',
        (body) => true,
        method: HTTPMethod.delete,
      );

  // ── Customers ─────────────────────────────────────────────────────────────

  Future<List<CustomerModel>> getCustomers({
    int? id,
    String? name,
    String? tradeName,
    String? cnpj,
  }) async {
    final params = <String, String>{};
    if (id != null && id > 0) params['id'] = id.toString();
    if (name != null && name.isNotEmpty) params['name'] = name;
    if (tradeName != null && tradeName.isNotEmpty) params['tradeName'] = tradeName;
    if (cnpj != null && cnpj.isNotEmpty) params['cnpj'] = cnpj;

    final query =
        params.isEmpty ? '' : '?${params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&')}';

    return request(
      'customers$query',
      (body) {
        final list = _decodeList(body);
        return list
            .map((e) => CustomerModel.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  // ── Payment Types ─────────────────────────────────────────────────────────

  Future<List<PaymentTypeModel>> getPaymentTypes({String? description}) async {
    final query = (description != null && description.isNotEmpty)
        ? '?description=${Uri.encodeComponent(description)}'
        : '';

    return request(
      'payment-types$query',
      (body) {
        final list = _decodeList(body);
        return list
            .map((e) => PaymentTypeModel.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  // ── Products ──────────────────────────────────────────────────────────────

  Future<List<ProductModel>> getProducts({
    int? id,
    String? codeFactory,
    String? codeBar,
    String? codeSupplier,
    String? description,
    String? groupDescription,
    String? subgroupDescription,
    String? brandDescription,
  }) async {
    // Código de barras → GET /products/codebar/{codeBar}
    if (codeBar != null && codeBar.isNotEmpty) {
      try {
        final product = await request(
          'products/codebar/${Uri.encodeComponent(codeBar)}',
          (body) => ProductModel.fromJson(jsonDecode(body) as Map<String, dynamic>),
        );
        return [product];
      } catch (_) {
        return [];
      }
    }

    // ID interno numérico → GET /products/{id}
    if (id != null && id > 0) {
      try {
        final product = await request(
          'products/$id',
          (body) => ProductModel.fromJson(jsonDecode(body) as Map<String, dynamic>),
        );
        return [product];
      } catch (_) {
        return [];
      }
    }

    // Texto → GET /products?search=... (busca em descrição, codeFactory, codeBar)
    final searchTerm = codeFactory ?? codeSupplier ?? description;
    final params = <String, String>{};
    if (searchTerm != null && searchTerm.isNotEmpty) params['search'] = searchTerm;

    final query =
        params.isEmpty ? '' : '?${params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&')}';

    return request(
      'products$query',
      (body) {
        final list = _decodeList(body);
        return list
            .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  // ── Stock Balance ─────────────────────────────────────────────────────────

  Future<List<StockBalanceModel>> getStockBalance(int productId) => request(
        'stock-balance/product/$productId',
        (body) {
          final list = _decodeList(body);
          return list
              .map((e) => StockBalanceModel.fromJson(e as Map<String, dynamic>))
              .toList();
        },
      );

  // ── Price List ────────────────────────────────────────────────────────────

  Future<List<PriceListModel>> getPrices(int productId) => request(
        'prices/product/$productId',
        (body) {
          final list = _decodeList(body);
          return list
              .map((e) => PriceListModel.fromJson(e as Map<String, dynamic>))
              .toList();
        },
      );

  // ── Product Images ────────────────────────────────────────────────────────

  Future<List<ProductImageModel>> getProductImages(int productId) => request(
        'product-images/product/$productId',
        (body) {
          final list = _decodeList(body);
          return list
              .map(
                  (e) => ProductImageModel.fromJson(e as Map<String, dynamic>))
              .toList();
        },
      );
}
