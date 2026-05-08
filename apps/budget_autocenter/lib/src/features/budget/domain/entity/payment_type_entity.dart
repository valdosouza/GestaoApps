import 'package:equatable/equatable.dart';

class PaymentTypeEntity extends Equatable {
  const PaymentTypeEntity({
    required this.id,
    required this.description,
  });

  final int id;
  final String description;

  static PaymentTypeEntity empty() =>
      const PaymentTypeEntity(id: 0, description: '');

  @override
  List<Object?> get props => [id, description];
}
