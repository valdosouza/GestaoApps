import 'package:equatable/equatable.dart';

class PermissionEntity extends Equatable {
  const PermissionEntity({required this.result});

  final bool result;

  @override
  List<Object?> get props => [result];
}
