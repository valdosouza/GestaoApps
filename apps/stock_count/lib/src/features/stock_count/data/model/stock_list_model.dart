import 'package:stock_count/src/features/stock_count/domain/entity/stock_list_entity.dart';

class StockListModel extends StockListEntity {
  const StockListModel({
    required super.id,
    required super.description,
    super.isMain,
  });

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }

  factory StockListModel.fromJson(Map<String, dynamic> json) => StockListModel(
        id: _toInt(json['id']),
        description: json['description']?.toString() ?? '',
        isMain: json['main']?.toString().toUpperCase() == 'S',
      );
}
