import 'package:dartz/dartz.dart';
import 'package:core/src/core/error/failure.dart';
import '../entity/product_entity.dart';
import '../entity/stock_list_entity.dart';
import '../repository/stock_count_repository.dart';

class GetStockLists {
  GetStockLists(this.repository);
  final StockCountRepository repository;

  Future<Either<Failure, List<StockListEntity>>> call() =>
      repository.getStockLists();
}

class GetProductById {
  GetProductById(this.repository);
  final StockCountRepository repository;

  Future<Either<Failure, ProductEntity>> call(int id) =>
      repository.getProductById(id);
}

class GetProductByBarcode {
  GetProductByBarcode(this.repository);
  final StockCountRepository repository;

  Future<Either<Failure, ProductEntity>> call(String barcode) =>
      repository.getProductByBarcode(barcode);
}

class SearchProducts {
  SearchProducts(this.repository);
  final StockCountRepository repository;

  Future<Either<Failure, List<ProductEntity>>> call({
    String? description,
    String? codeFactory,
  }) =>
      repository.searchProducts(
        description: description,
        codeFactory: codeFactory,
      );
}

class GetStockBalance {
  GetStockBalance(this.repository);
  final StockCountRepository repository;

  Future<Either<Failure, List<StockBalanceEntity>>> call(int productId) =>
      repository.getStockBalance(productId);
}

class GetPrices {
  GetPrices(this.repository);
  final StockCountRepository repository;

  Future<Either<Failure, List<PriceListEntity>>> call(int productId) =>
      repository.getPrices(productId);
}

class AdjustStock {
  AdjustStock(this.repository);
  final StockCountRepository repository;

  Future<Either<Failure, void>> call({
    required int productId,
    required int stockListId,
    required double quantity,
    required String movementType,
  }) =>
      repository.adjustStock(
        productId: productId,
        stockListId: stockListId,
        quantity: quantity,
        movementType: movementType,
      );
}
