import 'package:core/error/failures.dart';
import 'package:budget_autocenter/src/features/budget/domain/entity/budget_entity.dart';
import 'package:budget_autocenter/src/features/budget/domain/entity/budget_item_entity.dart';
import 'package:budget_autocenter/src/features/budget/domain/entity/customer_entity.dart';
import 'package:budget_autocenter/src/features/budget/domain/entity/payment_type_entity.dart';
import 'package:budget_autocenter/src/features/budget/domain/entity/product_entity.dart';
import 'package:dartz/dartz.dart';

abstract class BudgetRepository {
  // ── Remote: Budget list ─────────────────────────────────────────────────
  Future<Either<Failure, List<BudgetEntity>>> getBudgets({
    String? number,
    String? dateStart,
    String? dateEnd,
    String? customerName,
    int? institutionId,
  });

  Future<Either<Failure, BudgetEntity>> getBudgetById(int id);

  // ── Remote: Budget register/update ─────────────────────────────────────
  Future<Either<Failure, BudgetEntity>> createBudget(BudgetEntity budget);
  Future<Either<Failure, BudgetEntity>> updateBudget(BudgetEntity budget);

  // ── Remote: Budget items ────────────────────────────────────────────────
  Future<Either<Failure, List<BudgetItemEntity>>> getBudgetItems(int budgetId);
  Future<Either<Failure, BudgetItemEntity>> createBudgetItem(
      int budgetId, BudgetItemEntity item);
  Future<Either<Failure, BudgetItemEntity>> updateBudgetItem(
      int budgetId, BudgetItemEntity item);
  Future<Either<Failure, bool>> deleteBudgetItem(int budgetId, int itemId);

  // ── Remote: Customers ──────────────────────────────────────────────────
  Future<Either<Failure, List<CustomerEntity>>> getCustomers({
    int? id,
    String? name,
    String? tradeName,
    String? cnpj,
  });

  // ── Remote: Payment types ──────────────────────────────────────────────
  Future<Either<Failure, List<PaymentTypeEntity>>> getPaymentTypes({
    String? description,
  });

  // ── Remote: Products ──────────────────────────────────────────────────
  Future<Either<Failure, List<ProductEntity>>> getProducts({
    int? id,
    String? codeFactory,
    String? codeBar,
    String? codeSupplier,
    String? description,
    String? groupDescription,
    String? subgroupDescription,
    String? brandDescription,
  });

  // ── Remote: Stock & Prices ────────────────────────────────────────────
  Future<Either<Failure, List<StockBalanceEntity>>> getStockBalance(
      int productId);
  Future<Either<Failure, List<PriceListEntity>>> getPrices(int productId);
  Future<Either<Failure, List<ProductImageEntity>>> getProductImages(
      int productId);

  // ── Local SQLite ──────────────────────────────────────────────────────
  Future<Either<Failure, int>> saveLocalBudget(BudgetEntity budget);
  Future<Either<Failure, bool>> updateLocalBudget(BudgetEntity budget, int localId);
  Future<Either<Failure, List<BudgetEntity>>> getLocalBudgets();
  Future<Either<Failure, BudgetEntity?>> getLocalBudgetById(int localId);
  Future<Either<Failure, bool>> deleteLocalBudget(int localId);

  Future<Either<Failure, int>> saveLocalItem(BudgetItemEntity item);
  Future<Either<Failure, bool>> updateLocalItem(BudgetItemEntity item);
  Future<Either<Failure, List<BudgetItemEntity>>> getLocalItems(int localBudgetId);
  Future<Either<Failure, bool>> deleteLocalItem(int itemId);
  Future<Either<Failure, bool>> deleteLocalItemsByBudget(int localBudgetId);
}
