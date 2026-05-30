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

    final results = await Future.wait<Object?>([
      LocalStorageService.instance
          .get(key: LocalStorageKey.serverIp, defaultValue: ''),
      LocalStorageService.instance
          .get(key: LocalStorageKey.token, defaultValue: ''),
      LocalStorageService.instance
          .get(key: LocalStorageKey.keepConnected, defaultValue: false),
      Future.delayed(const Duration(seconds: 2), () => null),
    ]);

    final ip = results[0];
    final token = results[1]?.toString() ?? '';
    final keepConnected = results[2] == true;

    // 1. Verifica se o IP do servidor foi configurado.
    if (ip == null || ip.toString().isEmpty) {
      emit(ServerNotConfiguredState());
      return;
    }

    // 2. Se "Manter conectado" está ativo e há token salvo, entra direto.
    if (keepConnected && token.isNotEmpty) {
      emit(AuthorizedState());
      return;
    }

    emit(NotAuthorizedState());
  }
}
