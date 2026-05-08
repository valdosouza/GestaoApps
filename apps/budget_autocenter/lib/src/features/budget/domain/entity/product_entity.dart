import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  const ProductEntity({
    required this.id,
    required this.codeFactory,
    required this.codeBar,
    required this.codeSupplier,
    required this.description,
    required this.type,
    required this.location,
    required this.weight,
    required this.width,
    required this.length,
    required this.height,
    required this.taxSubstitution,
    required this.active,
    required this.measureDescription,
    required this.measureAbbreviation,
    required this.groupDescription,
    required this.subgroupDescription,
    required this.brandDescription,
  });

  final int id;
  final String codeFactory;
  final String codeBar;
  final String codeSupplier;
  final String description;
  final String type;
  final String location;
  final double weight;
  final double width;
  final double length;
  final double height;
  final String taxSubstitution;
  final String active;
  final String measureDescription;
  final String measureAbbreviation;
  final String groupDescription;
  final String subgroupDescription;
  final String brandDescription;

  static ProductEntity empty() => const ProductEntity(
        id: 0,
        codeFactory: '',
        codeBar: '',
        codeSupplier: '',
        description: '',
        type: 'P',
        location: '',
        weight: 0,
        width: 0,
        length: 0,
        height: 0,
        taxSubstitution: 'N',
        active: 'S',
        measureDescription: '',
        measureAbbreviation: '',
        groupDescription: '',
        subgroupDescription: '',
        brandDescription: '',
      );

  @override
  List<Object?> get props => [id, description, codeFactory, codeBar];
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

  static PriceListEntity empty() => const PriceListEntity(
        id: 0,
        priceListId: 0,
        priceListName: '',
        productId: 0,
        salePrice: 0,
      );

  @override
  List<Object?> get props => [id, priceListId, productId, salePrice];
}

class ProductImageEntity extends Equatable {
  const ProductImageEntity({
    required this.productId,
    required this.imageUrl,
  });

  final int productId;
  final String imageUrl;

  static ProductImageEntity empty() => const ProductImageEntity(
        productId: 0,
        imageUrl: '',
      );

  @override
  List<Object?> get props => [productId, imageUrl];
}
