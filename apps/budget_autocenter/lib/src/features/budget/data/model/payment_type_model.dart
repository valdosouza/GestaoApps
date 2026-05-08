import 'package:budget_autocenter/src/features/budget/domain/entity/payment_type_entity.dart';

class PaymentTypeModel extends PaymentTypeEntity {
  const PaymentTypeModel({
    required super.id,
    required super.description,
  });

  factory PaymentTypeModel.fromJson(Map<String, dynamic> json) =>
      PaymentTypeModel(
        id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
        description: json['description']?.toString() ?? '',
      );
}
