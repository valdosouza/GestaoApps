import 'package:bloc/bloc.dart';
import 'package:core/src/shared/helpers/local_storage.dart';
import 'package:core/src/shared/local_storage_key.dart';
import 'package:core/src/splash/presentation/bloc/splash_event.dart';
import 'package:core/src/splash/presentation/bloc/splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc() : super(LoadingState()) {
    on<SplashInitEvent>(_onInit);
  }

  Future<void> _onInit(
      SplashInitEvent event, Emitter<SplashState> emit) async {
    emit(LoadingState());

    // Executa a verificação e o tempo mínimo de splash em paralelo.
    // O splash fica visível por pelo menos 2 s, sem bloquear caso a
    // verificação demore mais que isso.
    final results = await Future.wait<Object?>([
      LocalStorageService.instance
          .get(key: LocalStorageKey.serverIp, defaultValue: ''),
      Future.delayed(const Duration(seconds: 2), () => null),
    ]);

    final ip = results[0];

    // 1. Verifica se o IP do servidor foi configurado.
    if (ip == null || ip.toString().isEmpty) {
      emit(ServerNotConfiguredState());
      return;
    }

    // 2. Não há sessão persistente neste sistema (sem JWT).
    //    Sempre que o app for aberto, o vendedor precisa fazer login.
    //    O timer de inatividade (10 min) é gerenciado pelo AuthBloc em memória.
    emit(NotAuthorizedState());
  }
}
