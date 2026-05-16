import 'package:equatable/equatable.dart';

class StockItemEntity extends Equatable {
  final int id;
  final String code;
  final String description;
  final double quantity;
  final String unit;

  const StockItemEntity({
    required this.id,
    required this.code,
    required this.description,
    required this.quantity,
    required this.unit,
  });

  @override
  List<Object?> get props => [id, code, description, quantity, unit];
}
