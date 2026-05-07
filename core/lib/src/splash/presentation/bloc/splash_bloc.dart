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

    // 1. Verifica se o IP do servidor foi configurado.
    final ip = await LocalStorageService.instance
        .get(key: LocalStorageKey.serverIp, defaultValue: '');

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
