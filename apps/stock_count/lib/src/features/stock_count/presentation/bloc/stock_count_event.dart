part of 'stock_count_bloc.dart';

abstract class StockCountEvent extends Equatable {
  const StockCountEvent();

  @override
  List<Object?> get props => [];
}

class StockCountLoadListsEvent extends StockCountEvent {
  const StockCountLoadListsEvent();
}

class StockCountSelectStockListEvent extends StockCountEvent {
  const StockCountSelectStockListEvent(this.stockList);

  final StockListEntity stockList;

  @override
  List<Object?> get props => [stockList];
}

class StockCountSearchByIdEvent extends StockCountEvent {
  const StockCountSearchByIdEvent(this.id);

  final int id;

  @override
  List<Object?> get props => [id];
}

class StockCountSearchByBarcodeEvent extends StockCountEvent {
  const StockCountSearchByBarcodeEvent(this.barcode);

  final String barcode;

  @override
  List<Object?> get props => [barcode];
}

class StockCountProductPickedEvent extends StockCountEvent {
  const StockCountProductPickedEvent(this.product);

  final ProductEntity product;

  @override
  List<Object?> get props => [product];
}

class StockCountAdjustStockEvent extends StockCountEvent {
  const StockCountAdjustStockEvent(this.quantityInformed);

  final double quantityInformed;

  @override
  List<Object?> get props => [quantityInformed];
}

class StockCountClearProductEvent extends StockCountEvent {
  const StockCountClearProductEvent();
}
