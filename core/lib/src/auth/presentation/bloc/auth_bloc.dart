import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:core/src/core/shared/helpers/local_storage.dart';
import 'package:core/src/core/shared/local_storage_key.dart';
import 'package:core/src/auth/domain/usecase/login_email.dart';
import 'package:core/src/auth/presentation/bloc/auth_event.dart';
import 'package:flutter_modular/flutter_modular.dart';

part 'auth_state.dart';

/// Duração máxima de inatividade antes de encerrar a sessão automaticamente.
const _kSessionTimeout = Duration(minutes: 10);

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required this.loginEmail}) : super(const AuthInitial()) {
    on<AuthLoginEvent>(_onLogin);
    on<AuthLogoutEvent>(_onLogout);
    on<AuthSessionExpiredEvent>(_onSessionExpired);
    on<AuthResetActivityEvent>(_onResetActivity);
  }

  final LoginEmail loginEmail;
  Timer? _inactivityTimer;

  // ──────────────────────────────────────────
  // Handlers de eventos
  // ──────────────────────────────────────────

  Future<void> _onLogin(
      AuthLoginEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoadingState());

    final result = await loginEmail(
      LoginParams(username: event.login, password: event.password),
    );

    result.fold(
      (failure) => emit(AuthErrorState(error: failure.toString())),
      (user) {
        if (user.authenticated) {
          LocalStorageService.instance
              .saveItem(key: LocalStorageKey.tbUserId, value: user.id);
          LocalStorageService.instance
              .saveItem(key: LocalStorageKey.salesmanId, value: user.salesmanId);
          LocalStorageService.instance
              .saveItem(key: LocalStorageKey.userName, value: user.name);
          LocalStorageService.instance
              .saveItem(key: LocalStorageKey.userLevel, value: user.level);
          _startInactivityTimer();
          emit(const AuthSuccessState());
        } else {
          emit(AuthErrorState(
            error: user.error.isNotEmpty
                ? user.error
                : 'Usuário ou senha inválidos.',
          ));
        }
      },
    );
  }

  Future<void> _onLogout(
      AuthLogoutEvent event, Emitter<AuthState> emit) async {
    _cancelInactivityTimer();
    await _clearSession();
    emit(const AuthLogoutSuccessState());
    Modular.to.navigate('/auth/');
  }

  Future<void> _onSessionExpired(
      AuthSessionExpiredEvent event, Emitter<AuthState> emit) async {
    await _clearSession();
    emit(const AuthSessionExpiredState());
    Modular.to.navigate('/auth/');
  }

  void _onResetActivity(
      AuthResetActivityEvent event, Emitter<AuthState> emit) {
    _startInactivityTimer();
  }

  // ──────────────────────────────────────────
  // Gerenciamento do timer de inatividade
  // ──────────────────────────────────────────

  void _startInactivityTimer() {
    _cancelInactivityTimer();
    _inactivityTimer = Timer(_kSessionTimeout, () {
      add(const AuthSessionExpiredEvent());
    });
  }

  void _cancelInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = null;
  }

  // ──────────────────────────────────────────
  // Limpeza de dados de sessão
  // ──────────────────────────────────────────

  Future<void> _clearSession() async {
    await LocalStorageService.instance
        .saveItem(key: LocalStorageKey.tbUserId, value: 0);
    await LocalStorageService.instance
        .saveItem(key: LocalStorageKey.salesmanId, value: 0);
    await LocalStorageService.instance
        .saveItem(key: LocalStorageKey.userName, value: '');
    await LocalStorageService.instance
        .saveItem(key: LocalStorageKey.userLevel, value: '');
  }

  @override
  Future<void> close() {
    _cancelInactivityTimer();
    return super.close();
  }
}
