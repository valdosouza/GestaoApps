import 'package:budget_autocenter/src/features/budget/domain/entity/customer_entity.dart';

class CustomerModel extends CustomerEntity {
  const CustomerModel({
    required super.id,
    required super.name,
    required super.tradeName,
    required super.cnpj,
    required super.person,
    required super.email,
    required super.active,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) => CustomerModel(
        id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
        name: json['name']?.toString() ?? '',
        tradeName: json['tradeName']?.toString() ?? '',
        cnpj: json['cnpj']?.toString() ?? '',
        person: json['person']?.toString() ?? 'J',
        email: json['email']?.toString() ?? '',
        active: json['active']?.toString() ?? 'S',
      );
}
