import 'package:dartz/dartz.dart';
import 'package:core/src/core/error/failure.dart';
import '../entity/stock_item_entity.dart';
import '../repository/stock_count_repository.dart';

class SaveStockCount {
  final StockCountRepository repository;

  SaveStockCount(this.repository);

  Future<Either<Failure, void>> call(StockItemEntity item) =>
      repository.saveCount(item);
}
