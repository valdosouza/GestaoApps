import 'package:equatable/equatable.dart';

enum PermissionStatus { initial, loading, granted, denied, error }

class PermissionState extends Equatable {
  const PermissionState({
    this.status = PermissionStatus.initial,
    this.errorMessage,
  });

  final PermissionStatus status;
  final String? errorMessage;

  @override
  List<Object?> get props => [status, errorMessage];
}
