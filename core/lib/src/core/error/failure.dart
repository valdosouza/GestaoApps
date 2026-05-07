import 'package:equatable/equatable.dart';

/// Classe base para representar falhas/erros na aplicação
class Failure extends Equatable {
  final String message;
  final String code;
  final dynamic originalException;
  final StackTrace? stackTrace;

  const Failure({
    required this.message,
    required this.code,
    this.originalException,
    this.stackTrace,
  });

  @override
  List<Object?> get props => [message, code];

  @override
  String toString() => 'Failure(code: $code, message: $message)';
}

/// Falha genérica de servidor
class ServerFailure extends Failure {
  const ServerFailure({
    String message = 'Erro ao conectar com o servidor',
    String code = 'SERVER_ERROR',
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    code: code,
    originalException: originalException,
    stackTrace: stackTrace,
  );
}

/// Falha de autenticação
class AuthFailure extends Failure {
  const AuthFailure({
    String message = 'Falha na autenticação',
    String code = 'AUTH_ERROR',
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    code: code,
    originalException: originalException,
    stackTrace: stackTrace,
  );
}

/// Falha de validação
class ValidationFailure extends Failure {
  const ValidationFailure({
    String message = 'Dados inválidos',
    String code = 'VALIDATION_ERROR',
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    code: code,
    originalException: originalException,
    stackTrace: stackTrace,
  );
}

/// Falha de conexão
class ConnectionFailure extends Failure {
  const ConnectionFailure({
    String message = 'Erro de conexão',
    String code = 'CONNECTION_ERROR',
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    code: code,
    originalException: originalException,
    stackTrace: stackTrace,
  );
}

/// Falha de cache
class CacheFailure extends Failure {
  const CacheFailure({
    String message = 'Erro ao acessar cache',
    String code = 'CACHE_ERROR',
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    code: code,
    originalException: originalException,
    stackTrace: stackTrace,
  );
}
