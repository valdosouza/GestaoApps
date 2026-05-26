import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entity/product_entity.dart';
import '../../domain/entity/stock_list_entity.dart';
import '../../domain/usecase/stock_count_usecases.dart';

part 'stock_count_event.dart';
part 'stock_count_state.dart';

class StockCountBloc extends Bloc<StockCountEvent, StockCountState> {
  StockCountBloc({
    required this.getStockLists,
    required this.getProductById,
    required this.getProductByBarcode,
    required this.searchProducts,
    required this.getStockBalance,
    required this.getPrices,
    required this.adjustStock,
  }) : super(StockCountInitialState()) {
    on<StockCountLoadListsEvent>(_onLoadLists);
    on<StockCountSelectStockListEvent>(_onSelectStockList);
    on<StockCountSearchByIdEvent>(_onSearchById);
    on<StockCountSearchByBarcodeEvent>(_onSearchByBarcode);
    on<StockCountProductPickedEvent>(_onProductPicked);
    on<StockCountAdjustStockEvent>(_onAdjustStock);
    on<StockCountClearProductEvent>(_onClearProduct);
  }

  final GetStockLists getStockLists;
  final GetProductById getProductById;
  final GetProductByBarcode getProductByBarcode;
  final SearchProducts searchProducts;
  final GetStockBalance getStockBalance;
  final GetPrices getPrices;
  final AdjustStock adjustStock;

  Future<void> _onLoadLists(
    StockCountLoadListsEvent event,
    Emitter<StockCountState> emit,
  ) async {
    emit(const StockCountLoadingState('Carregando estoques...'));
    final result = await getStockLists();
    result.fold(
      (failure) => emit(StockCountErrorState(message: failure.message)),
      (lists) {
        final main = lists.where((l) => l.isMain).firstOrNull;
        emit(StockCountReadyState(stockLists: lists, selectedStockList: main));
      },
    );
  }

  void _onSelectStockList(
    StockCountSelectStockListEvent event,
    Emitter<StockCountState> emit,
  ) {
    final current = state;
    if (current is StockCountReadyState) {
      emit(current.copyWith(selectedStockList: event.stockList));
    } else if (current is StockCountProductLoadedState) {
      emit(current.copyWith(selectedStockList: event.stockList));
      add(StockCountProductPickedEvent(current.product));
    }
  }

  Future<void> _onSearchById(
    StockCountSearchByIdEvent event,
    Emitter<StockCountState> emit,
  ) async {
    final stockList = _selectedStockList();
    final lists = _stockLists(); // captura ANTES do loading state
    if (stockList == null) {
      emit(StockCountErrorState(
        message: 'Selecione um estoque antes de buscar o produto.',
        stockLists: lists,
      ));
      return;
    }

    emit(const StockCountLoadingState('Buscando produto...'));
    final result = await getProductById(event.id);
    await result.fold(
      (failure) async => emit(StockCountErrorState(
        message: failure.message,
        stockLists: lists,
        selectedStockList: stockList,
      )),
      (product) async =>
          _loadProductDetails(product, stockList, lists, emit),
    );
  }

  Future<void> _onSearchByBarcode(
    StockCountSearchByBarcodeEvent event,
    Emitter<StockCountState> emit,
  ) async {
    final stockList = _selectedStockList();
    final lists = _stockLists(); // captura ANTES do loading state
    if (stockList == null) {
      emit(StockCountErrorState(
        message: 'Selecione um estoque antes de ler o código de barras.',
        stockLists: lists,
      ));
      return;
    }

    emit(const StockCountLoadingState(
        'Buscando produto pelo código de barras...'));
    final result = await getProductByBarcode(event.barcode);
    await result.fold(
      (failure) async => emit(StockCountErrorState(
        message: failure.message,
        stockLists: lists,
        selectedStockList: stockList,
      )),
      (product) async =>
          _loadProductDetails(product, stockList, lists, emit),
    );
  }

  Future<void> _onProductPicked(
    StockCountProductPickedEvent event,
    Emitter<StockCountState> emit,
  ) async {
    final stockList = _selectedStockList();
    final lists = _stockLists(); // captura ANTES do loading state
    if (stockList == null) return;
    emit(const StockCountLoadingState('Carregando dados do produto...'));
    await _loadProductDetails(event.product, stockList, lists, emit);
  }

  Future<void> _loadProductDetails(
    ProductEntity product,
    StockListEntity stockList,
    List<StockListEntity> lists, // recebe como parâmetro — não chama _stockLists()
    Emitter<StockCountState> emit,
  ) async {
    final balanceResult = await getStockBalance(product.id);
    final pricesResult = await getPrices(product.id);

    double currentBalance = 0;
    balanceResult.fold(
      (_) {},
      (balances) {
        final match = balances.where((b) => b.stockListId == stockList.id);
        if (match.isNotEmpty) currentBalance = match.first.quantity;
      },
    );

    List<PriceListEntity> prices = [];
    pricesResult.fold(
      (_) {},
      (list) => prices = list.where((p) => p.salePrice > 0).toList(),
    );

    emit(StockCountProductLoadedState(
      stockLists: lists,
      selectedStockList: stockList,
      product: product,
      currentBalance: currentBalance,
      prices: prices,
    ));
  }

  Future<void> _onAdjustStock(
    StockCountAdjustStockEvent event,
    Emitter<StockCountState> emit,
  ) async {
    final current = state;
    if (current is! StockCountProductLoadedState) return;

    final qin = event.quantityInformed;
    final qat = current.currentBalance;

    if (qin == qat) {
      emit(current.copyWith(
        infoMessage: 'Quantidades iguais, nada a fazer.',
      ));
      return;
    }

    final quantity = (qin - qat).abs();
    final movementType = qin > qat ? 'E' : 'S';

    emit(current.copyWith(isAdjusting: true, infoMessage: null));

    final result = await adjustStock(
      productId: current.product.id,
      stockListId: current.selectedStockList.id,
      quantity: quantity,
      movementType: movementType,
    );

    result.fold(
      (failure) => emit(current.copyWith(
        isAdjusting: false,
        infoMessage: 'Erro: ${failure.message}',
      )),
      (_) => emit(StockCountAdjustmentSuccessState(
        stockLists: current.stockLists,
        selectedStockList: current.selectedStockList,
      )),
    );
  }

  void _onClearProduct(
    StockCountClearProductEvent event,
    Emitter<StockCountState> emit,
  ) {
    final s = state;
    List<StockListEntity> lists = [];
    StockListEntity? selected;

    if (s is StockCountAdjustmentSuccessState) {
      lists = s.stockLists;
      selected = s.selectedStockList;
    } else {
      lists = _stockLists();
      selected = _selectedStockList();
    }

    emit(StockCountReadyState(
      stockLists: lists,
      selectedStockList: selected,
    ));
  }

  List<StockListEntity> _stockLists() {
    final s = state;
    if (s is StockCountReadyState) return s.stockLists;
    if (s is StockCountProductLoadedState) return s.stockLists;
    if (s is StockCountAdjustmentSuccessState) return s.stockLists;
    if (s is StockCountErrorState) return s.stockLists;
    return [];
  }

  StockListEntity? _selectedStockList() {
    final s = state;
    if (s is StockCountReadyState) return s.selectedStockList;
    if (s is StockCountProductLoadedState) return s.selectedStockList;
    if (s is StockCountAdjustmentSuccessState) return s.selectedStockList;
    if (s is StockCountErrorState) return s.selectedStockList;
    return null;
  }
}
