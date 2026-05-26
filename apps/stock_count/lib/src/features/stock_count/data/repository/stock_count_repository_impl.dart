import 'package:dartz/dartz.dart';
import 'package:core/src/core/error/failure.dart';
import '../../domain/entity/product_entity.dart';
import '../../domain/entity/stock_list_entity.dart';
import '../../domain/repository/stock_count_repository.dart';
import '../datasource/remote/stock_count_remote_datasource.dart';

class StockCountRepositoryImpl implements StockCountRepository {
  StockCountRepositoryImpl({required this.remote});

  final StockCountRemoteDatasource remote;

  @override
  Future<Either<Failure, List<StockListEntity>>> getStockLists() async {
    try {
      final result = await remote.getStockLists();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(
        message: 'Erro ao buscar listas de estoque: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> getProductById(int id) async {
    try {
      final result = await remote.getProductById(id);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(
        message: 'Produto não encontrado: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> getProductByBarcode(
      String barcode) async {
    try {
      final result = await remote.getProductByBarcode(barcode);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(
        message: 'Produto não encontrado para o código de barras: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> searchProducts({
    String? description,
    String? codeFactory,
  }) async {
    try {
      final result = await remote.searchProducts(
        description: description,
        codeFactory: codeFactory,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(
        message: 'Erro ao pesquisar produtos: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Either<Failure, List<StockBalanceEntity>>> getStockBalance(
      int productId) async {
    try {
      final result = await remote.getStockBalance(productId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(
        message: 'Erro ao buscar saldo de estoque: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Either<Failure, List<PriceListEntity>>> getPrices(
      int productId) async {
    try {
      final result = await remote.getPrices(productId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(
        message: 'Erro ao buscar preços: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> adjustStock({
    required int productId,
    required int stockListId,
    required double quantity,
    required String movementType,
  }) async {
    try {
      await remote.adjustStock(
        productId: productId,
        stockListId: stockListId,
        quantity: quantity,
        movementType: movementType,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(
        message: 'Erro ao atualizar saldo: ${e.toString()}',
      ));
    }
  }
}
