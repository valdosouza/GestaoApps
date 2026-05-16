import 'package:dartz/dartz.dart';
import 'package:core/src/core/error/failure.dart';
import '../entity/stock_item_entity.dart';

abstract class StockCountRepository {
  Future<Either<Failure, List<StockItemEntity>>> getItems();
  Future<Either<Failure, void>> saveCount(StockItemEntity item);
}
