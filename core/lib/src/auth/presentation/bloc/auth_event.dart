import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
}

/// Disparado quando o usuário envia as credenciais de login.
class AuthLoginEvent extends AuthEvent {
  const AuthLoginEvent({
    required this.login,
    required this.password,
    this.keepConnected = false,
  });

  final String login;
  final String password;
  final bool keepConnected;

  @override
  List<Object?> get props => [login, password, keepConnected];
}

/// Disparado para encerrar a sessão do usuário.
class AuthLogoutEvent extends AuthEvent {
  const AuthLogoutEvent();

  @override
  List<Object?> get props => [];
}

/// Disparado pelo timer quando os 10 minutos de inatividade se esgotam.
class AuthSessionExpiredEvent extends AuthEvent {
  const AuthSessionExpiredEvent();

  @override
  List<Object?> get props => [];
}

/// Disparado a cada interação do usuário para resetar o timer de inatividade.
class AuthResetActivityEvent extends AuthEvent {
  const AuthResetActivityEvent();

  @override
  List<Object?> get props => [];
}
