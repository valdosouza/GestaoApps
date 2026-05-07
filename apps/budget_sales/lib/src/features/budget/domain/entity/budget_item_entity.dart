import 'package:equatable/equatable.dart';

class BudgetItemEntity extends Equatable {
  const BudgetItemEntity({
    required this.id,
    required this.budgetId,
    required this.type,
    required this.productId,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.discountValue,
    required this.discountPercent,
    required this.stockId,
    required this.priceListId,
    required this.sequence,
  });

  final int id;
  final int budgetId;
  final String type;
  final int productId;
  final String description;
  final double quantity;
  final double unitPrice;
  final double discountValue;
  final double discountPercent;
  final int stockId;
  final int priceListId;
  final int sequence;

  double get subtotal {
    final base = quantity * unitPrice;
    return base - discountValue;
  }

  static BudgetItemEntity empty() => const BudgetItemEntity(
        id: 0,
        budgetId: 0,
        type: 'P',
        productId: 0,
        description: '',
        quantity: 1,
        unitPrice: 0,
        discountValue: 0,
        discountPercent: 0,
        stockId: 0,
        priceListId: 0,
        sequence: 0,
      );

  BudgetItemEntity copyWith({
    int? id,
    int? budgetId,
    String? type,
    int? productId,
    String? description,
    double? quantity,
    double? unitPrice,
    double? discountValue,
    double? discountPercent,
    int? stockId,
    int? priceListId,
    int? sequence,
  }) {
    return BudgetItemEntity(
      id: id ?? this.id,
      budgetId: budgetId ?? this.budgetId,
      type: type ?? this.type,
      productId: productId ?? this.productId,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      discountValue: discountValue ?? this.discountValue,
      discountPercent: discountPercent ?? this.discountPercent,
      stockId: stockId ?? this.stockId,
      priceListId: priceListId ?? this.priceListId,
      sequence: sequence ?? this.sequence,
    );
  }

  @override
  List<Object?> get props => [
        id, budgetId, type, productId, description,
        quantity, unitPrice, discountValue, discountPercent,
        stockId, priceListId, sequence,
      ];
}
