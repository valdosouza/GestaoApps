import 'package:core/error/failures.dart';
import 'package:budget_sales/src/features/budget/data/datasource/local/budget_local_datasource.dart';
import 'package:budget_sales/src/features/budget/data/datasource/remote/budget_remote_datasource.dart';
import 'package:budget_sales/src/features/budget/domain/entity/budget_entity.dart';
import 'package:budget_sales/src/features/budget/domain/entity/budget_item_entity.dart';
import 'package:budget_sales/src/features/budget/domain/entity/customer_entity.dart';
import 'package:budget_sales/src/features/budget/domain/entity/payment_type_entity.dart';
import 'package:budget_sales/src/features/budget/domain/entity/product_entity.dart';
import 'package:budget_sales/src/features/budget/domain/repository/budget_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  BudgetRepositoryImpl({
    required this.remote,
    required this.local,
  });

  final BudgetRemoteDatasource remote;
  final BudgetLocalDatasource local;

  // ── Helpers ───────────────────────────────────────────────────────────────

  Future<Either<Failure, T>> _handle<T>(Future<T> Function() call) async {
    try {
      return Right(await call());
    } catch (e) {
      debugPrint('BudgetRepository error: $e');
      return Left(ServerFailure(message: e.toString()));
    }
  }

  // ── Remote: Budget list ──────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<BudgetEntity>>> getBudgets({
    String? number,
    String? dateStart,
    String? dateEnd,
    String? customerName,
    int? institutionId,
  }) =>
      _handle(() => remote.getBudgets(
            number: number,
            dateStart: dateStart,
            dateEnd: dateEnd,
            customerName: customerName,
            institutionId: institutionId,
          ));

  @override
  Future<Either<Failure, BudgetEntity>> getBudgetById(int id) =>
      _handle(() => remote.getBudgetById(id));

  // ── Remote: Budget CRUD ──────────────────────────────────────────────────

  @override
  Future<Either<Failure, BudgetEntity>> createBudget(BudgetEntity budget) =>
      _handle(() => remote.createBudget(budget));

  @override
  Future<Either<Failure, BudgetEntity>> updateBudget(BudgetEntity budget) =>
      _handle(() => remote.updateBudget(budget));

  // ── Remote: Budget items ─────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<BudgetItemEntity>>> getBudgetItems(
          int budgetId) =>
      _handle(() => remote.getBudgetItems(budgetId));

  @override
  Future<Either<Failure, BudgetItemEntity>> createBudgetItem(
          int budgetId, BudgetItemEntity item) =>
      _handle(() => remote.createBudgetItem(budgetId, item));

  @override
  Future<Either<Failure, BudgetItemEntity>> updateBudgetItem(
          int budgetId, BudgetItemEntity item) =>
      _handle(() => remote.updateBudgetItem(budgetId, item));

  @override
  Future<Either<Failure, bool>> deleteBudgetItem(int budgetId, int itemId) =>
      _handle(() => remote.deleteBudgetItem(budgetId, itemId));

  // ── Remote: Customers ────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<CustomerEntity>>> getCustomers({
    int? id,
    String? name,
    String? tradeName,
    String? cnpj,
  }) =>
      _handle(() =>
          remote.getCustomers(id: id, name: name, tradeName: tradeName, cnpj: cnpj));

  // ── Remote: Payment types ────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<PaymentTypeEntity>>> getPaymentTypes(
          {String? description}) =>
      _handle(() => remote.getPaymentTypes(description: description));

  // ── Remote: Products ─────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<ProductEntity>>> getProducts({
    int? id,
    String? codeFactory,
    String? codeBar,
    String? codeSupplier,
    String? description,
    String? groupDescription,
    String? subgroupDescription,
    String? brandDescription,
  }) =>
      _handle(() => remote.getProducts(
            id: id,
            codeFactory: codeFactory,
            codeBar: codeBar,
            codeSupplier: codeSupplier,
            description: description,
            groupDescription: groupDescription,
            subgroupDescription: subgroupDescription,
            brandDescription: brandDescription,
          ));

  // ── Remote: Stock & Prices ────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<StockBalanceEntity>>> getStockBalance(
          int productId) =>
      _handle(() => remote.getStockBalance(productId));

  @override
  Future<Either<Failure, List<PriceListEntity>>> getPrices(int productId) =>
      _handle(() => remote.getPrices(productId));

  @override
  Future<Either<Failure, List<ProductImageEntity>>> getProductImages(
          int productId) =>
      _handle(() => remote.getProductImages(productId));

  // ── Local SQLite ──────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, int>> saveLocalBudget(BudgetEntity budget) =>
      _handle(() => local.insertBudget(budget));

  @override
  Future<Either<Failure, bool>> updateLocalBudget(
          BudgetEntity budget, int localId) =>
      _handle(() => local.updateBudget(budget, localId));

  @override
  Future<Either<Failure, List<BudgetEntity>>> getLocalBudgets() =>
      _handle(() => local.getAllBudgets());

  @override
  Future<Either<Failure, BudgetEntity?>> getLocalBudgetById(int localId) =>
      _handle(() => local.getBudgetById(localId));

  @override
  Future<Either<Failure, bool>> deleteLocalBudget(int localId) =>
      _handle(() => local.deleteBudget(localId));

  @override
  Future<Either<Failure, int>> saveLocalItem(BudgetItemEntity item) =>
      _handle(() => local.insertItem(item));

  @override
  Future<Either<Failure, bool>> updateLocalItem(BudgetItemEntity item) =>
      _handle(() => local.updateItem(item));

  @override
  Future<Either<Failure, List<BudgetItemEntity>>> getLocalItems(
          int localBudgetId) =>
      _handle(() => local.getItemsByBudgetId(localBudgetId));

  @override
  Future<Either<Failure, bool>> deleteLocalItem(int itemId) =>
      _handle(() => local.deleteItem(itemId));

  @override
  Future<Either<Failure, bool>> deleteLocalItemsByBudget(int localBudgetId) =>
      _handle(() => local.deleteItemsByBudget(localBudgetId));
}
