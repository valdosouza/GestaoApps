import 'package:stock_count/src/features/stock_count/domain/entity/product_entity.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.codeFactory,
    required super.codeBar,
    required super.description,
    required super.measureAbbreviation,
  });

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final measure = json['measure'] as Map<String, dynamic>? ?? {};
    return ProductModel(
      id: _toInt(json['id']),
      codeFactory: json['codeFactory']?.toString() ?? '',
      codeBar: json['codeBar']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      measureAbbreviation: measure['abbreviation']?.toString() ?? '',
    );
  }
}

class StockBalanceModel extends StockBalanceEntity {
  const StockBalanceModel({
    required super.id,
    required super.stockListId,
    required super.stockListDesc,
    required super.productId,
    required super.quantity,
  });

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  factory StockBalanceModel.fromJson(Map<String, dynamic> json) =>
      StockBalanceModel(
        id: _toInt(json['id']),
        stockListId: _toInt(json['stockListId']),
        stockListDesc: json['stockListDesc']?.toString() ?? '',
        productId: _toInt(json['productId']),
        quantity: _toDouble(json['quantity']),
      );
}

class PriceListModel extends PriceListEntity {
  const PriceListModel({
    required super.id,
    required super.priceListId,
    required super.priceListName,
    required super.productId,
    required super.salePrice,
  });

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  factory PriceListModel.fromJson(Map<String, dynamic> json) => PriceListModel(
        id: _toInt(json['id']),
        priceListId: _toInt(json['priceListId']),
        priceListName: json['priceListName']?.toString() ?? '',
        productId: _toInt(json['productId']),
        salePrice: _toDouble(json['salePrice']),
      );
}
