part of 'auth_bloc.dart';

abstract class AuthState {
  const AuthState();
}

/// Estado inicial antes de qualquer ação.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Aguardando resposta da API.
class AuthLoadingState extends AuthState {
  const AuthLoadingState();
}

/// Login realizado com sucesso.
class AuthSuccessState extends AuthState {
  const AuthSuccessState();
}

/// Logout concluído.
class AuthLogoutSuccessState extends AuthState {
  const AuthLogoutSuccessState();
}

/// Erro no login (credenciais inválidas, servidor indisponível etc.).
class AuthErrorState extends AuthState {
  const AuthErrorState({required this.error});

  final String error;
}

/// Sessão expirada por inatividade (10 minutos sem interação).
class AuthSessionExpiredState extends AuthState {
  const AuthSessionExpiredState();
}
