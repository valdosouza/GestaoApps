part of 'stock_count_bloc.dart';

abstract class StockCountState extends Equatable {
  const StockCountState();

  @override
  List<Object?> get props => [];
}

class StockCountInitialState extends StockCountState {}

class StockCountReadyState extends StockCountState {}
