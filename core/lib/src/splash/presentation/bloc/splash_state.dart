abstract class SplashState {}

class LoadingState extends SplashState {}

/// Servidor não configurado – redirecionar para tela de IP.
class ServerNotConfiguredState extends SplashState {}

/// Sessão válida – redirecionar para home.
class AuthorizedState extends SplashState {}

/// Sem sessão ativa – redirecionar para login.
class NotAuthorizedState extends SplashState {}
