import 'package:equatable/equatable.dart';

class StockListEntity extends Equatable {
  const StockListEntity({
    required this.id,
    required this.description,
    this.isMain = false,
  });

  final int id;
  final String description;
  final bool isMain;

  @override
  List<Object?> get props => [id, description, isMain];
}
