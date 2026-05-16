part of 'stock_count_bloc.dart';

abstract class StockCountEvent extends Equatable {
  const StockCountEvent();

  @override
  List<Object?> get props => [];
}

class StockCountStarted extends StockCountEvent {
  const StockCountStarted();
}
