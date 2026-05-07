import 'package:budget_sales/src/features/budget/domain/entity/product_entity.dart';
import 'package:equatable/equatable.dart';

abstract class ProductSearchState extends Equatable {
  const ProductSearchState();
}

class ProductSearchInitial extends ProductSearchState {
  const ProductSearchInitial();

  @override
  List<Object?> get props => [];
}

class ProductSearchLoading extends ProductSearchState {
  const ProductSearchLoading();

  @override
  List<Object?> get props => [];
}

class ProductSearchLoaded extends ProductSearchState {
  const ProductSearchLoaded({required this.products});

  final List<ProductEntity> products;

  @override
  List<Object?> get props => [products];
}

class ProductSearchDetailLoaded extends ProductSearchState {
  const ProductSearchDetailLoaded({
    required this.products,
    required this.selectedProduct,
    required this.stockList,
    required this.priceList,
    required this.images,
    this.isLoadingDetail = false,
  });

  final List<ProductEntity> products;
  final ProductEntity selectedProduct;
  final List<StockBalanceEntity> stockList;
  final List<PriceListEntity> priceList;
  final List<ProductImageEntity> images;
  final bool isLoadingDetail;

  ProductSearchDetailLoaded copyWith({
    List<ProductEntity>? products,
    ProductEntity? selectedProduct,
    List<StockBalanceEntity>? stockList,
    List<PriceListEntity>? priceList,
    List<ProductImageEntity>? images,
    bool? isLoadingDetail,
  }) {
    return ProductSearchDetailLoaded(
      products: products ?? this.products,
      selectedProduct: selectedProduct ?? this.selectedProduct,
      stockList: stockList ?? this.stockList,
      priceList: priceList ?? this.priceList,
      images: images ?? this.images,
      isLoadingDetail: isLoadingDetail ?? this.isLoadingDetail,
    );
  }

  @override
  List<Object?> get props =>
      [products, selectedProduct, stockList, priceList, images, isLoadingDetail];
}

class ProductSearchError extends ProductSearchState {
  const ProductSearchError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
