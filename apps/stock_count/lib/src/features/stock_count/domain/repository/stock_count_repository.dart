import 'package:dartz/dartz.dart';
import 'package:core/src/core/error/failure.dart';
import '../entity/product_entity.dart';
import '../entity/stock_list_entity.dart';

abstract class StockCountRepository {
  Future<Either<Failure, List<StockListEntity>>> getStockLists();

  Future<Either<Failure, ProductEntity>> getProductById(int id);

  Future<Either<Failure, ProductEntity>> getProductByBarcode(String barcode);

  Future<Either<Failure, List<ProductEntity>>> searchProducts({
    String? description,
    String? codeFactory,
  });

  Future<Either<Failure, List<StockBalanceEntity>>> getStockBalance(
      int productId);

  Future<Either<Failure, List<PriceListEntity>>> getPrices(int productId);

  Future<Either<Failure, void>> adjustStock({
    required int productId,
    required int stockListId,
    required double quantity,
    required String movementType,
  });
}
