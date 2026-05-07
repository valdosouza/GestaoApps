import 'package:budget_sales/src/features/budget/domain/entity/budget_item_entity.dart';

class BudgetItemModel extends BudgetItemEntity {
  const BudgetItemModel({
    required super.id,
    required super.budgetId,
    required super.type,
    required super.productId,
    required super.description,
    required super.quantity,
    required super.unitPrice,
    required super.discountValue,
    required super.discountPercent,
    required super.stockId,
    required super.priceListId,
    required super.sequence,
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

  factory BudgetItemModel.fromJson(Map<String, dynamic> json) =>
      BudgetItemModel(
        id: _toInt(json['id']),
        budgetId: _toInt(json['budgetId']),
        type: json['type']?.toString() ?? 'P',
        productId: _toInt(json['productId']),
        description: json['description']?.toString() ?? '',
        quantity: _toDouble(json['quantity']),
        unitPrice: _toDouble(json['unitPrice']),
        discountValue: _toDouble(json['discountValue']),
        discountPercent: _toDouble(json['discountPercent']),
        stockId: _toInt(json['stockId']),
        priceListId: _toInt(json['priceListId']),
        sequence: _toInt(json['sequence']),
      );

  Map<String, dynamic> toJson() => {
        'budgetId': budgetId,
        'type': type,
        'productId': productId,
        'description': description,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'discountValue': discountValue,
        'discountPercent': discountPercent,
        'stockId': stockId,
        'priceListId': priceListId,
        'sequence': sequence,
      };

  static BudgetItemModel empty() {
    final e = BudgetItemEntity.empty();
    return BudgetItemModel(
      id: e.id, budgetId: e.budgetId, type: e.type, productId: e.productId,
      description: e.description, quantity: e.quantity, unitPrice: e.unitPrice,
      discountValue: e.discountValue, discountPercent: e.discountPercent,
      stockId: e.stockId, priceListId: e.priceListId, sequence: e.sequence,
    );
  }

  static BudgetItemModel fromEntity(BudgetItemEntity e) => BudgetItemModel(
        id: e.id, budgetId: e.budgetId, type: e.type, productId: e.productId,
        description: e.description, quantity: e.quantity, unitPrice: e.unitPrice,
        discountValue: e.discountValue, discountPercent: e.discountPercent,
        stockId: e.stockId, priceListId: e.priceListId, sequence: e.sequence,
      );
}
