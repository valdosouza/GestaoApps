import '../../domain/entity/stock_item_entity.dart';

class StockItemModel extends StockItemEntity {
  const StockItemModel({
    required super.id,
    required super.code,
    required super.description,
    required super.quantity,
    required super.unit,
  });

  factory StockItemModel.fromJson(Map<String, dynamic> json) => StockItemModel(
        id: json['id'] as int? ?? 0,
        code: json['code']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
        unit: json['unit']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'description': description,
        'quantity': quantity,
        'unit': unit,
      };
}
