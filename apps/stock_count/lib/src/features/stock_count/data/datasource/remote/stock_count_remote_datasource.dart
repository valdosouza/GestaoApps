import 'dart:convert';

import 'package:core/gateway.dart';
import '../../../data/model/product_model.dart';
import '../../../data/model/stock_list_model.dart';
import '../../../domain/entity/product_entity.dart';
import '../../../domain/entity/stock_list_entity.dart';

class StockCountRemoteDatasource extends Gateway {
  StockCountRemoteDatasource({required super.httpClient});

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

  // ── Stock Lists ───────────────────────────────────────────────────────────

  Future<List<StockListEntity>> getStockLists() =>
      request('stock-lists', (body) {
        final list = _decodeList(body);
        return list
            .map<StockListEntity>(
                (e) => StockListModel.fromJson(e as Map<String, dynamic>))
            .toList();
      });

  // ── Products ──────────────────────────────────────────────────────────────

  Future<ProductEntity> getProductById(int id) => request(
        'products/$id',
        (body) =>
            ProductModel.fromJson(jsonDecode(body) as Map<String, dynamic>)
                as ProductEntity,
      );

  Future<ProductEntity> getProductByBarcode(String barcode) => request(
        'products/codebar/${Uri.encodeComponent(barcode)}',
        (body) =>
            ProductModel.fromJson(jsonDecode(body) as Map<String, dynamic>)
                as ProductEntity,
      );

  Future<List<ProductEntity>> searchProducts({
    String? description,
    String? codeFactory,
  }) async {
    final params = <String, String>{};
    final searchTerm = codeFactory ?? description;
    if (searchTerm != null && searchTerm.isNotEmpty) {
      params['search'] = searchTerm;
    }
    final query = params.isEmpty
        ? ''
        : '?${params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&')}';

    return request('products$query', (body) {
      final list = _decodeList(body);
      return list
          .map<ProductEntity>(
              (e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  // ── Stock Balance ─────────────────────────────────────────────────────────

  Future<List<StockBalanceEntity>> getStockBalance(int productId) =>
      request('stock-balance/product/$productId', (body) {
        final list = _decodeList(body);
        return list
            .map<StockBalanceEntity>(
                (e) => StockBalanceModel.fromJson(e as Map<String, dynamic>))
            .toList();
      });

  // ── Prices ────────────────────────────────────────────────────────────────

  Future<List<PriceListEntity>> getPrices(int productId) =>
      request('prices/product/$productId', (body) {
        final list = _decodeList(body);
        return list
            .map<PriceListEntity>(
                (e) => PriceListModel.fromJson(e as Map<String, dynamic>))
            .toList();
      });

  // ── Stock Adjustment ──────────────────────────────────────────────────────

  Future<void> adjustStock({
    required int productId,
    required int stockListId,
    required double quantity,
    required String movementType,
  }) async {
    final terminal = await getUserId();
    final today = DateTime.now();
    final date =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    return request(
      'stock-control',
      (_) {},
      method: HTTPMethod.post,
      data: jsonEncode({
        'terminal': terminal,
        'link': 'A',
        'control': 0,
        'itemControl': 0,
        'stockListId': stockListId,
        'operation': movementType,
        'productId': productId,
        'quantity': quantity,
        'date': date,
        'type': 'Avulso',
      }),
    );
  }
}
