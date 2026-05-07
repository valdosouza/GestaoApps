import 'package:core/error/failures.dart';
import 'package:budget_sales/src/features/budget/domain/entity/budget_entity.dart';
import 'package:budget_sales/src/features/budget/domain/entity/budget_item_entity.dart';
import 'package:budget_sales/src/features/budget/domain/entity/customer_entity.dart';
import 'package:budget_sales/src/features/budget/domain/entity/payment_type_entity.dart';
import 'package:budget_sales/src/features/budget/domain/entity/product_entity.dart';
import 'package:budget_sales/src/features/budget/domain/repository/budget_repository.dart';
import 'package:dartz/dartz.dart';

// ── Remote: Budget list ──────────────────────────────────────────────────────

class GetBudgets {
  GetBudgets(this.repository);
  final BudgetRepository repository;

  Future<Either<Failure, List<BudgetEntity>>> call({
    String? number,
    String? dateStart,
    String? dateEnd,
    String? customerName,
    int? institutionId,
  }) =>
      repository.getBudgets(
        number: number,
        dateStart: dateStart,
        dateEnd: dateEnd,
        customerName: customerName,
        institutionId: institutionId,
      );
}

class GetBudgetById {
  GetBudgetById(this.repository);
  final BudgetRepository repository;

  Future<Either<Failure, BudgetEntity>> call(int id) =>
      repository.getBudgetById(id);
}

// ── Remote: Budget CRUD ──────────────────────────────────────────────────────

class CreateBudget {
  CreateBudget(this.repository);
  final BudgetRepository repository;

  Future<Either<Failure, BudgetEntity>> call(BudgetEntity budget) =>
      repository.createBudget(budget);
}

class UpdateBudget {
  UpdateBudget(this.repository);
  final BudgetRepository repository;

  Future<Either<Failure, BudgetEntity>> call(BudgetEntity budget) =>
      repository.updateBudget(budget);
}

// ── Remote: Budget items ──────────────────────────────────────────────────────

class GetBudgetItems {
  GetBudgetItems(this.repository);
  final BudgetRepository repository;

  Future<Either<Failure, List<BudgetItemEntity>>> call(int budgetId) =>
      repository.getBudgetItems(budgetId);
}

class CreateBudgetItem {
  CreateBudgetItem(this.repository);
  final BudgetRepository repository;

  Future<Either<Failure, BudgetItemEntity>> call(
          int budgetId, BudgetItemEntity item) =>
      repository.createBudgetItem(budgetId, item);
}

class UpdateBudgetItem {
  UpdateBudgetItem(this.repository);
  final BudgetRepository repository;

  Future<Either<Failure, BudgetItemEntity>> call(
          int budgetId, BudgetItemEntity item) =>
      repository.updateBudgetItem(budgetId, item);
}

class DeleteBudgetItem {
  DeleteBudgetItem(this.repository);
  final BudgetRepository repository;

  Future<Either<Failure, bool>> call(int budgetId, int itemId) =>
      repository.deleteBudgetItem(budgetId, itemId);
}

// ── Remote: Customers ─────────────────────────────────────────────────────────

class GetCustomers {
  GetCustomers(this.repository);
  final BudgetRepository repository;

  Future<Either<Failure, List<CustomerEntity>>> call({
    int? id,
    String? name,
    String? tradeName,
    String? cnpj,
  }) =>
      repository.getCustomers(
          id: id, name: name, tradeName: tradeName, cnpj: cnpj);
}

// ── Remote: Payment types ─────────────────────────────────────────────────────

class GetPaymentTypes {
  GetPaymentTypes(this.repository);
  final BudgetRepository repository;

  Future<Either<Failure, List<PaymentTypeEntity>>> call({String? description}) =>
      repository.getPaymentTypes(description: description);
}

// ── Remote: Products ──────────────────────────────────────────────────────────

class GetProducts {
  GetProducts(this.repository);
  final BudgetRepository repository;

  Future<Either<Failure, List<ProductEntity>>> call({
    int? id,
    String? codeFactory,
    String? codeBar,
    String? codeSupplier,
    String? description,
    String? groupDescription,
    String? subgroupDescription,
    String? brandDescription,
  }) =>
      repository.getProducts(
        id: id,
        codeFactory: codeFactory,
        codeBar: codeBar,
        codeSupplier: codeSupplier,
        description: description,
        groupDescription: groupDescription,
        subgroupDescription: subgroupDescription,
        brandDescription: brandDescription,
      );
}

// ── Remote: Stock & Prices ────────────────────────────────────────────────────

class GetStockBalance {
  GetStockBalance(this.repository);
  final BudgetRepository repository;

  Future<Either<Failure, List<StockBalanceEntity>>> call(int productId) =>
      repository.getStockBalance(productId);
}

class GetPrices {
  GetPrices(this.repository);
  final BudgetRepository repository;

  Future<Either<Failure, List<PriceListEntity>>> call(int productId) =>
      repository.getPrices(productId);
}

class GetProductImages {
  GetProductImages(this.repository);
  final BudgetRepository repository;

  Future<Either<Failure, List<ProductImageEntity>>> call(int productId) =>
      repository.getProductImages(productId);
}

// ── Local SQLite ──────────────────────────────────────────────────────────────

class SaveLocalBudget {
  SaveLocalBudget(this.repository);
  final BudgetRepository repository;

  Future<Either<Failure, int>> call(BudgetEntity budget) =>
      repository.saveLocalBudget(budget);
}

class UpdateLocalBudget {
  UpdateLocalBudget(this.repository);
  final BudgetRepository repository;

  Future<Either<Failure, bool>> call(BudgetEntity budget, int localId) =>
      repository.updateLocalBudget(budget, localId);
}

class GetLocalBudgets {
  GetLocalBudgets(this.repository);
  final BudgetRepository repository;

  Future<Either<Failure, List<BudgetEntity>>> call() =>
      repository.getLocalBudgets();
}

class GetLocalBudgetById {
  GetLocalBudgetById(this.repository);
  final BudgetRepository repository;

  Future<Either<Failure, BudgetEntity?>> call(int localId) =>
      repository.getLocalBudgetById(localId);
}

class DeleteLocalBudget {
  DeleteLocalBudget(this.repository);
  final BudgetRepository repository;

  Future<Either<Failure, bool>> call(int localId) =>
      repository.deleteLocalBudget(localId);
}

class SaveLocalItem {
  SaveLocalItem(this.repository);
  final BudgetRepository repository;

  Future<Either<Failure, int>> call(BudgetItemEntity item) =>
      repository.saveLocalItem(item);
}

class UpdateLocalItem {
  UpdateLocalItem(this.repository);
  final BudgetRepository repository;

  Future<Either<Failure, bool>> call(BudgetItemEntity item) =>
      repository.updateLocalItem(item);
}

class GetLocalItems {
  GetLocalItems(this.repository);
  final BudgetRepository repository;

  Future<Either<Failure, List<BudgetItemEntity>>> call(int localBudgetId) =>
      repository.getLocalItems(localBudgetId);
}

class DeleteLocalItem {
  DeleteLocalItem(this.repository);
  final BudgetRepository repository;

  Future<Either<Failure, bool>> call(int itemId) =>
      repository.deleteLocalItem(itemId);
}
