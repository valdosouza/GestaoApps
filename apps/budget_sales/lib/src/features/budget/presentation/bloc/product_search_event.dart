import 'package:equatable/equatable.dart';

abstract class ProductSearchEvent extends Equatable {
  const ProductSearchEvent();
}

class ProductSearchLoad extends ProductSearchEvent {
  const ProductSearchLoad({
    this.id,
    this.codeFactory,
    this.codeBar,
    this.codeSupplier,
    this.description,
    this.groupDescription,
    this.subgroupDescription,
    this.brandDescription,
  });

  final int? id;
  final String? codeFactory;
  final String? codeBar;
  final String? codeSupplier;
  final String? description;
  final String? groupDescription;
  final String? subgroupDescription;
  final String? brandDescription;

  @override
  List<Object?> get props => [
        id, codeFactory, codeBar, codeSupplier, description,
        groupDescription, subgroupDescription, brandDescription,
      ];
}

class ProductSearchLoadStock extends ProductSearchEvent {
  const ProductSearchLoadStock({required this.productId});

  final int productId;

  @override
  List<Object?> get props => [productId];
}

class ProductSearchLoadPrices extends ProductSearchEvent {
  const ProductSearchLoadPrices({required this.productId});

  final int productId;

  @override
  List<Object?> get props => [productId];
}

class ProductSearchLoadImages extends ProductSearchEvent {
  const ProductSearchLoadImages({required this.productId});

  final int productId;

  @override
  List<Object?> get props => [productId];
}

class ProductSearchClear extends ProductSearchEvent {
  const ProductSearchClear();

  @override
  List<Object?> get props => [];
}
