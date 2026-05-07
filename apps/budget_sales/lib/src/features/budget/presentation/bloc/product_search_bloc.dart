import 'package:budget_sales/src/features/budget/domain/entity/product_entity.dart';
import 'package:budget_sales/src/features/budget/domain/usecase/budget_usecases.dart';
import 'package:budget_sales/src/features/budget/presentation/bloc/product_search_event.dart';
import 'package:budget_sales/src/features/budget/presentation/bloc/product_search_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductSearchBloc extends Bloc<ProductSearchEvent, ProductSearchState> {
  ProductSearchBloc({
    required this.getProducts,
    required this.getStockBalance,
    required this.getPrices,
    required this.getProductImages,
  }) : super(const ProductSearchInitial()) {
    on<ProductSearchLoad>(_onLoad);
    on<ProductSearchLoadStock>(_onLoadStock);
    on<ProductSearchLoadPrices>(_onLoadPrices);
    on<ProductSearchLoadImages>(_onLoadImages);
    on<ProductSearchClear>(_onClear);
  }

  final GetProducts getProducts;
  final GetStockBalance getStockBalance;
  final GetPrices getPrices;
  final GetProductImages getProductImages;

  Future<void> _onLoad(
      ProductSearchLoad event, Emitter<ProductSearchState> emit) async {
    emit(const ProductSearchLoading());
    final result = await getProducts(
      id: event.id,
      codeFactory: event.codeFactory,
      codeBar: event.codeBar,
      codeSupplier: event.codeSupplier,
      description: event.description,
      groupDescription: event.groupDescription,
      subgroupDescription: event.subgroupDescription,
      brandDescription: event.brandDescription,
    );
    result.fold(
      (failure) => emit(ProductSearchError(message: failure.message)),
      (products) => emit(ProductSearchLoaded(products: products)),
    );
  }

  Future<void> _onLoadStock(
      ProductSearchLoadStock event, Emitter<ProductSearchState> emit) async {
    final current = state;
    List<ProductEntity> products = [];
    ProductEntity? selected;

    if (current is ProductSearchLoaded) {
      products = current.products;
      final idx = products.indexWhere((p) => p.id == event.productId);
      selected = idx >= 0 ? products[idx] : null;
    } else if (current is ProductSearchDetailLoaded) {
      products = current.products;
      selected = current.selectedProduct;
    }

    if (selected == null || selected.id == 0) return;

    if (current is ProductSearchDetailLoaded) {
      emit(current.copyWith(isLoadingDetail: true));
    } else {
      emit(ProductSearchDetailLoaded(
        products: products,
        selectedProduct: selected,
        stockList: const [],
        priceList: const [],
        images: const [],
        isLoadingDetail: true,
      ));
    }

    final result = await getStockBalance(event.productId);
    final currentDetail = state;
    if (currentDetail is ProductSearchDetailLoaded) {
      result.fold(
        (f) => emit(currentDetail.copyWith(isLoadingDetail: false)),
        (stock) =>
            emit(currentDetail.copyWith(stockList: stock, isLoadingDetail: false)),
      );
    }
  }

  Future<void> _onLoadPrices(
      ProductSearchLoadPrices event, Emitter<ProductSearchState> emit) async {
    final current = state;
    if (current is! ProductSearchDetailLoaded) return;
    emit(current.copyWith(isLoadingDetail: true));

    final result = await getPrices(event.productId);
    final latest = state;
    if (latest is! ProductSearchDetailLoaded) return;
    result.fold(
      (f) => emit(latest.copyWith(isLoadingDetail: false)),
      (prices) =>
          emit(latest.copyWith(priceList: prices, isLoadingDetail: false)),
    );
  }

  Future<void> _onLoadImages(
      ProductSearchLoadImages event, Emitter<ProductSearchState> emit) async {
    final current = state;
    if (current is! ProductSearchDetailLoaded) return;
    emit(current.copyWith(isLoadingDetail: true));

    final result = await getProductImages(event.productId);
    final latest = state;
    if (latest is! ProductSearchDetailLoaded) return;
    result.fold(
      (f) => emit(latest.copyWith(isLoadingDetail: false)),
      (images) =>
          emit(latest.copyWith(images: images, isLoadingDetail: false)),
    );
  }

  void _onClear(ProductSearchClear event, Emitter<ProductSearchState> emit) {
    emit(const ProductSearchInitial());
  }
}
