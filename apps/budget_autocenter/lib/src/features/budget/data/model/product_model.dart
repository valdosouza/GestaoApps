import 'package:budget_autocenter/src/features/budget/domain/entity/product_entity.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.codeFactory,
    required super.codeBar,
    required super.codeSupplier,
    required super.description,
    required super.type,
    required super.location,
    required super.weight,
    required super.width,
    required super.length,
    required super.height,
    required super.taxSubstitution,
    required super.active,
    required super.measureDescription,
    required super.measureAbbreviation,
    required super.groupDescription,
    required super.subgroupDescription,
    required super.brandDescription,
  });

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final measure = json['measure'] as Map<String, dynamic>? ?? {};
    final group = json['group'] as Map<String, dynamic>? ?? {};
    final subgroup = json['subgroup'] as Map<String, dynamic>? ?? {};
    final brand = json['brand'] as Map<String, dynamic>? ?? {};

    return ProductModel(
      id: _toInt(json['id']),
      codeFactory: json['codeFactory']?.toString() ?? '',
      codeBar: json['codeBar']?.toString() ?? '',
      codeSupplier: json['codeSupplier']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      type: json['type']?.toString() ?? 'P',
      location: json['location']?.toString() ?? '',
      weight: _toDouble(json['weight']),
      width: _toDouble(json['width']),
      length: _toDouble(json['length']),
      height: _toDouble(json['height']),
      taxSubstitution: json['taxSubstitution']?.toString() ?? 'N',
      active: json['active']?.toString() ?? 'S',
      measureDescription: measure['description']?.toString() ?? '',
      measureAbbreviation: measure['abbreviation']?.toString() ?? '',
      groupDescription: group['description']?.toString() ?? '',
      subgroupDescription: subgroup['description']?.toString() ?? '',
      brandDescription: brand['description']?.toString() ?? '',
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

  factory StockBalanceModel.fromJson(Map<String, dynamic> json) =>
      StockBalanceModel(
        id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
        stockListId: json['stockListId'] is int
            ? json['stockListId']
            : int.tryParse(json['stockListId'].toString()) ?? 0,
        stockListDesc: json['stockListDesc']?.toString() ?? '',
        productId: json['productId'] is int
            ? json['productId']
            : int.tryParse(json['productId'].toString()) ?? 0,
        quantity: json['quantity'] is double
            ? json['quantity']
            : (json['quantity'] is int
                ? (json['quantity'] as int).toDouble()
                : double.tryParse(json['quantity'].toString()) ?? 0.0),
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

  factory PriceListModel.fromJson(Map<String, dynamic> json) => PriceListModel(
        id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
        priceListId: json['priceListId'] is int
            ? json['priceListId']
            : int.tryParse(json['priceListId'].toString()) ?? 0,
        priceListName: json['priceListName']?.toString() ?? '',
        productId: json['productId'] is int
            ? json['productId']
            : int.tryParse(json['productId'].toString()) ?? 0,
        salePrice: json['salePrice'] is double
            ? json['salePrice']
            : (json['salePrice'] is int
                ? (json['salePrice'] as int).toDouble()
                : double.tryParse(json['salePrice'].toString()) ?? 0.0),
      );
}

class ProductImageModel extends ProductImageEntity {
  const ProductImageModel({
    required super.productId,
    required super.imageUrl,
  });

  factory ProductImageModel.fromJson(Map<String, dynamic> json) =>
      ProductImageModel(
        productId: json['productId'] is int
            ? json['productId']
            : int.tryParse(json['productId'].toString()) ?? 0,
        imageUrl: json['dataUri']?.toString() ?? json['link']?.toString() ?? json['imageUrl']?.toString() ?? '',
      );
}
