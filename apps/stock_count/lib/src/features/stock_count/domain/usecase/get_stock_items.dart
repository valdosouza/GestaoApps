import 'package:dartz/dartz.dart';
import 'package:core/src/core/error/failure.dart';
import '../entity/stock_item_entity.dart';
import '../repository/stock_count_repository.dart';

class GetStockItems {
  final StockCountRepository repository;

  GetStockItems(this.repository);

  Future<Either<Failure, List<StockItemEntity>>> call() =>
      repository.getItems();
}
