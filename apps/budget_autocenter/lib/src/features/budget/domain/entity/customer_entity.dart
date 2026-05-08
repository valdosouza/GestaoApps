import 'package:equatable/equatable.dart';

class CustomerEntity extends Equatable {
  const CustomerEntity({
    required this.id,
    required this.name,
    required this.tradeName,
    required this.cnpj,
    required this.person,
    required this.email,
    required this.active,
  });

  final int id;
  final String name;
  final String tradeName;
  final String cnpj;
  final String person;
  final String email;
  final String active;

  static CustomerEntity empty() => const CustomerEntity(
        id: 0,
        name: '',
        tradeName: '',
        cnpj: '',
        person: 'J',
        email: '',
        active: 'S',
      );

  @override
  List<Object?> get props => [id, name, tradeName, cnpj, person, email, active];
}
