import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'stock_count_event.dart';
part 'stock_count_state.dart';

class StockCountBloc extends Bloc<StockCountEvent, StockCountState> {
  StockCountBloc() : super(StockCountInitialState()) {
    on<StockCountStarted>(_onStarted);
  }

  Future<void> _onStarted(
    StockCountStarted event,
    Emitter<StockCountState> emit,
  ) async {
    // TODO: Implementar lógica na próxima etapa
    emit(StockCountReadyState());
  }
}
