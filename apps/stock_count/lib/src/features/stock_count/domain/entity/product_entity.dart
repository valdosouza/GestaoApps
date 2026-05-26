import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  const ProductEntity({
    required this.id,
    required this.codeFactory,
    required this.codeBar,
    required this.description,
    required this.measureAbbreviation,
  });

  final int id;
  final String codeFactory;
  final String codeBar;
  final String description;
  final String measureAbbreviation;

  static ProductEntity empty() => const ProductEntity(
        id: 0,
        codeFactory: '',
        codeBar: '',
        description: '',
        measureAbbreviation: '',
      );

  @override
  List<Object?> get props => [id, codeFactory, codeBar, description];
}

class StockBalanceEntity extends Equatable {
  const StockBalanceEntity({
    required this.id,
    required this.stockListId,
    required this.stockListDesc,
    required this.productId,
    required this.quantity,
  });

  final int id;
  final int stockListId;
  final String stockListDesc;
  final int productId;
  final double quantity;

  static StockBalanceEntity empty() => const StockBalanceEntity(
        id: 0,
        stockListId: 0,
        stockListDesc: '',
        productId: 0,
        quantity: 0,
      );

  @override
  List<Object?> get props => [id, stockListId, productId, quantity];
}

class PriceListEntity extends Equatable {
  const PriceListEntity({
    required this.id,
    required this.priceListId,
    required this.priceListName,
    required this.productId,
    required this.salePrice,
  });

  final int id;
  final int priceListId;
  final String priceListName;
  final int productId;
  final double salePrice;

  @override
  List<Object?> get props => [id, priceListId, productId, salePrice];
}
