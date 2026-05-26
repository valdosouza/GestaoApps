part of 'stock_count_bloc.dart';

abstract class StockCountState extends Equatable {
  const StockCountState();

  @override
  List<Object?> get props => [];
}

class StockCountInitialState extends StockCountState {}

class StockCountLoadingState extends StockCountState {
  const StockCountLoadingState(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class StockCountReadyState extends StockCountState {
  const StockCountReadyState({
    required this.stockLists,
    this.selectedStockList,
  });

  final List<StockListEntity> stockLists;
  final StockListEntity? selectedStockList;

  StockCountReadyState copyWith({
    List<StockListEntity>? stockLists,
    StockListEntity? selectedStockList,
  }) =>
      StockCountReadyState(
        stockLists: stockLists ?? this.stockLists,
        selectedStockList: selectedStockList ?? this.selectedStockList,
      );

  @override
  List<Object?> get props => [stockLists, selectedStockList];
}

class StockCountProductLoadedState extends StockCountState {
  const StockCountProductLoadedState({
    required this.stockLists,
    required this.selectedStockList,
    required this.product,
    required this.currentBalance,
    required this.prices,
    this.isAdjusting = false,
    this.infoMessage,
  });

  final List<StockListEntity> stockLists;
  final StockListEntity selectedStockList;
  final ProductEntity product;
  final double currentBalance;
  final List<PriceListEntity> prices;
  final bool isAdjusting;
  final String? infoMessage;

  StockCountProductLoadedState copyWith({
    List<StockListEntity>? stockLists,
    StockListEntity? selectedStockList,
    ProductEntity? product,
    double? currentBalance,
    List<PriceListEntity>? prices,
    bool? isAdjusting,
    String? infoMessage,
  }) =>
      StockCountProductLoadedState(
        stockLists: stockLists ?? this.stockLists,
        selectedStockList: selectedStockList ?? this.selectedStockList,
        product: product ?? this.product,
        currentBalance: currentBalance ?? this.currentBalance,
        prices: prices ?? this.prices,
        isAdjusting: isAdjusting ?? this.isAdjusting,
        infoMessage: infoMessage,
      );

  @override
  List<Object?> get props => [
        stockLists,
        selectedStockList,
        product,
        currentBalance,
        prices,
        isAdjusting,
        infoMessage,
      ];
}

class StockCountAdjustmentSuccessState extends StockCountState {
  const StockCountAdjustmentSuccessState({
    required this.stockLists,
    required this.selectedStockList,
  });

  final List<StockListEntity> stockLists;
  final StockListEntity selectedStockList;

  @override
  List<Object?> get props => [stockLists, selectedStockList];
}

class StockCountErrorState extends StockCountState {
  const StockCountErrorState({
    required this.message,
    this.stockLists = const [],
    this.selectedStockList,
  });

  final String message;
  final List<StockListEntity> stockLists;
  final StockListEntity? selectedStockList;

  @override
  List<Object?> get props => [message, stockLists, selectedStockList];
}
