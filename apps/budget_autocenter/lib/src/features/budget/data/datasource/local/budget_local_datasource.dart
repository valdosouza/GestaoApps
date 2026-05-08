import 'package:core/database/app_database.dart';
import 'package:budget_autocenter/src/features/budget/data/model/budget_item_model.dart';
import 'package:budget_autocenter/src/features/budget/data/model/budget_model.dart';
import 'package:budget_autocenter/src/features/budget/domain/entity/budget_entity.dart';
import 'package:budget_autocenter/src/features/budget/domain/entity/budget_item_entity.dart';
import 'package:drift/drift.dart';

class BudgetLocalDatasource {
  BudgetLocalDatasource({required this.db});

  final AppDatabase db;

  // ── Budget (header) ──────────────────────────────────────────────────────

  Future<List<BudgetModel>> getAllBudgets() async {
    final rows = await db.getAllBudgets();
    return rows.map(_rowToModel).toList();
  }

  Future<BudgetModel?> getBudgetById(int id) async {
    final row = await db.getBudgetById(id);
    if (row == null) return null;
    return _rowToModel(row);
  }

  Future<int> insertBudget(BudgetEntity budget) {
    return db.insertBudget(TbBudgetCompanion.insert(
      orderId: const Value(0),
      userId: Value(budget.userId),
      date: _parseDate(budget.date),
      customerId: Value(budget.customerId),
      customerName: Value(budget.customerName.isEmpty ? null : budget.customerName),
      paymentTypeId: Value(budget.paymentTypeId > 0 ? budget.paymentTypeId : null),
      paymentTerms: Value(budget.paymentTerms.isEmpty ? null : budget.paymentTerms),
      totalProducts: Value(budget.totalProducts),
      freight: Value(budget.freight),
      discountPercent: Value(budget.discountPercent),
      discountValue: Value(budget.discountValue),
      total: Value(budget.total),
      contact: Value(budget.contact.isEmpty ? null : budget.contact),
      validity: Value(budget.validity.isEmpty ? null : budget.validity),
      deliveryTime:
          Value(budget.deliveryTime.isEmpty ? null : budget.deliveryTime),
      salesmanId: Value(budget.salesmanId > 0 ? budget.salesmanId : null),
      warehouseId: Value(budget.institutionId > 0 ? budget.institutionId : null),
      status: Value(budget.status.isEmpty ? null : budget.status),
    ));
  }

  Future<bool> updateBudget(BudgetEntity budget, int localId) {
    return db.updateBudget(TbBudgetCompanion(
      id: Value(localId),
      userId: Value(budget.userId),
      date: Value(_parseDate(budget.date)),
      customerId: Value(budget.customerId),
      customerName:
          Value(budget.customerName.isEmpty ? null : budget.customerName),
      paymentTypeId:
          Value(budget.paymentTypeId > 0 ? budget.paymentTypeId : null),
      paymentTerms:
          Value(budget.paymentTerms.isEmpty ? null : budget.paymentTerms),
      totalProducts: Value(budget.totalProducts),
      freight: Value(budget.freight),
      discountPercent: Value(budget.discountPercent),
      discountValue: Value(budget.discountValue),
      total: Value(budget.total),
      contact: Value(budget.contact.isEmpty ? null : budget.contact),
      validity: Value(budget.validity.isEmpty ? null : budget.validity),
      deliveryTime:
          Value(budget.deliveryTime.isEmpty ? null : budget.deliveryTime),
      salesmanId: Value(budget.salesmanId > 0 ? budget.salesmanId : null),
      warehouseId: Value(budget.institutionId > 0 ? budget.institutionId : null),
      status: Value(budget.status.isEmpty ? null : budget.status),
    ));
  }

  Future<bool> deleteBudget(int localId) async {
    await db.deleteBudgetWithItems(localId);
    return true;
  }

  // ── Budget Items ──────────────────────────────────────────────────────────

  Future<List<BudgetItemModel>> getItemsByBudgetId(int budgetId) async {
    final rows = await db.getItemsByBudgetId(budgetId);
    return rows.map(_rowToItemModel).toList();
  }

  Future<int> insertItem(BudgetItemEntity item) {
    return db.insertItem(TbBudgetItemCompanion.insert(
      budgetId: Value(item.budgetId > 0 ? item.budgetId : null),
      type: Value(item.type.isEmpty ? null : item.type),
      productId: Value(item.productId > 0 ? item.productId : null),
      description: Value(item.description.isEmpty ? null : item.description),
      quantity: Value(item.quantity),
      unitPrice: Value(item.unitPrice),
      discountValue: Value(item.discountValue),
      discountPercent: Value(item.discountPercent),
      stockId: Value(item.stockId > 0 ? item.stockId : null),
      priceListId: Value(item.priceListId > 0 ? item.priceListId : null),
      sequence: Value(item.sequence > 0 ? item.sequence : null),
    ));
  }

  Future<bool> updateItem(BudgetItemEntity item) {
    return db.updateItem(TbBudgetItemCompanion(
      id: Value(item.id),
      budgetId: Value(item.budgetId > 0 ? item.budgetId : null),
      type: Value(item.type.isEmpty ? null : item.type),
      productId: Value(item.productId > 0 ? item.productId : null),
      description: Value(item.description.isEmpty ? null : item.description),
      quantity: Value(item.quantity),
      unitPrice: Value(item.unitPrice),
      discountValue: Value(item.discountValue),
      discountPercent: Value(item.discountPercent),
      stockId: Value(item.stockId > 0 ? item.stockId : null),
      priceListId: Value(item.priceListId > 0 ? item.priceListId : null),
      sequence: Value(item.sequence > 0 ? item.sequence : null),
    ));
  }

  Future<bool> deleteItem(int itemId) async {
    await db.deleteItem(itemId);
    return true;
  }

  Future<bool> deleteItemsByBudget(int budgetId) async {
    await db.deleteItemsByBudgetId(budgetId);
    return true;
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  DateTime _parseDate(String date) {
    if (date.isEmpty) return DateTime.now();
    // API returns dd/MM/yyyy
    final parts = date.split('/');
    if (parts.length == 3) {
      return DateTime(
        int.tryParse(parts[2]) ?? DateTime.now().year,
        int.tryParse(parts[1]) ?? 1,
        int.tryParse(parts[0]) ?? 1,
      );
    }
    return DateTime.tryParse(date) ?? DateTime.now();
  }

  String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';

  BudgetModel _rowToModel(TbBudgetData row) => BudgetModel(
        id: row.id,
        orderId: row.orderId,
        number: row.number ?? '',
        userId: row.userId,
        date: _formatDate(row.date),
        customerId: row.customerId,
        customerName: row.customerName ?? '',
        paymentTypeId: row.paymentTypeId ?? 0,
        paymentTerms: row.paymentTerms ?? '',
        quantityProducts: row.quantityProducts ?? 0,
        totalProducts: row.totalProducts ?? 0,
        freight: row.freight ?? 0,
        discountPercent: row.discountPercent ?? 0,
        discountValue: row.discountValue ?? 0,
        total: row.total ?? 0,
        contact: row.contact ?? '',
        validity: row.validity ?? '',
        deliveryTime: row.deliveryTime ?? '',
        salesmanId: row.salesmanId ?? 0,
        institutionId: row.warehouseId ?? 0,
        status: row.status ?? 'N',
      );

  BudgetItemModel _rowToItemModel(TbBudgetItemData row) => BudgetItemModel(
        id: row.id,
        budgetId: row.budgetId ?? 0,
        type: row.type ?? 'P',
        productId: row.productId ?? 0,
        description: row.description ?? '',
        quantity: row.quantity ?? 1,
        unitPrice: row.unitPrice ?? 0,
        discountValue: row.discountValue ?? 0,
        discountPercent: row.discountPercent ?? 0,
        stockId: row.stockId ?? 0,
        priceListId: row.priceListId ?? 0,
        sequence: row.sequence ?? 0,
      );
}
