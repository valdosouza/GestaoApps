import 'package:equatable/equatable.dart';

/// Classe base para representar falhas/erros na aplicação
class Failure extends Equatable {
  const Failure({
    required this.message,
    required this.code,
    this.originalException,
    this.stackTrace,
  });

  final String message;
  final String code;
  final dynamic originalException;
  final StackTrace? stackTrace;

  @override
  List<Object?> get props => [message, code];

  @override
  String toString() => 'Failure(code: $code, message: $message)';
}

/// Falha genérica de servidor
class ServerFailure extends Failure {
  const ServerFailure({
    super.message = 'Erro ao conectar com o servidor',
    super.code = 'SERVER_ERROR',
    super.originalException,
    super.stackTrace,
  });
}

/// Falha de autenticação
class AuthFailure extends Failure {
  const AuthFailure({
    super.message = 'Falha na autenticação',
    super.code = 'AUTH_ERROR',
    super.originalException,
    super.stackTrace,
  });
}

/// Falha de validação
class ValidationFailure extends Failure {
  const ValidationFailure({
    super.message = 'Dados inválidos',
    super.code = 'VALIDATION_ERROR',
    super.originalException,
    super.stackTrace,
  });
}

/// Falha de conexão
class ConnectionFailure extends Failure {
  const ConnectionFailure({
    super.message = 'Erro de conexão',
    super.code = 'CONNECTION_ERROR',
    super.originalException,
    super.stackTrace,
  });
}

/// Falha de cache
class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Erro ao acessar cache',
    super.code = 'CACHE_ERROR',
    super.originalException,
    super.stackTrace,
  });
}
