import 'package:core/src/shared/widgets/custom_circular_progress_indicator.dart';
import 'package:core/src/splash/presentation/bloc/splash_bloc.dart';
import 'package:core/src/splash/presentation/bloc/splash_event.dart';
import 'package:core/src/splash/presentation/bloc/splash_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key, this.bloc});

  /// Parâmetro opcional para injeção nos testes.
  /// Quando nulo, usa `Modular.get<SplashBloc>()`.
  final Bloc<SplashEvent, SplashState>? bloc;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  late final Bloc<SplashEvent, SplashState> _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = widget.bloc ?? Modular.get<SplashBloc>();
    _bloc.add(SplashInitEvent());
  }

  @override
  Widget build(BuildContext context) => Material(
        child: BlocConsumer<Bloc<SplashEvent, SplashState>, SplashState>(
          bloc: _bloc,
          listener: (context, state) {
            if (state is ServerNotConfiguredState) {
              Modular.to.navigate('/server-config/');
            } else if (state is AuthorizedState) {
              Modular.to.navigate('/budget/');
            } else if (state is NotAuthorizedState) {
              Modular.to.navigate('/auth/');
            }
          },
          builder: (context, state) => const CustomCircularProgressIndicator(),
        ),
      );
}
