import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// Cabeçalho do Orçamento (TB_COTACAO)
class TbBudget extends Table {
  @override
  String get tableName => 'TB_COTACAO';

  IntColumn get id => integer().named('CTC_CODIGO').autoIncrement()();
  IntColumn get orderId => integer().named('CTC_CODPED').withDefault(const Constant(0))();
  TextColumn get number => text().named('CTC_NUMERO').nullable()();
  IntColumn get userId => integer().named('CTC_CODUSU').withDefault(const Constant(0))();
  DateTimeColumn get date => dateTime().named('CTC_DATA')();
  IntColumn get customerId => integer().named('CTC_CODEMP').withDefault(const Constant(0))();
  TextColumn get customerName => text().named('CTC_FANTASIA').nullable()();
  IntColumn get paymentTypeId => integer().named('CTC_CODFPG').nullable()();
  TextColumn get paymentTerms => text().named('CTC_PRAZO').nullable()();
  RealColumn get quantityProducts => real().named('CTC_QT_PRODUTO').nullable()();
  RealColumn get totalProducts => real().named('CTC_VL_PRODUTO').nullable()();
  RealColumn get freight => real().named('CTC_VL_FRETE').nullable()();
  RealColumn get discountPercent => real().named('CTC_ALIQ_DESCONTO').nullable()();
  RealColumn get discountValue => real().named('CTC_VL_DESCONTO').nullable()();
  RealColumn get total => real().named('CTC_VL_COTACAO').nullable()();
  TextColumn get contact => text().named('CTC_CONTATO').nullable()();
  TextColumn get validity => text().named('CTC_VALIDADE').nullable()();
  TextColumn get deliveryTime => text().named('CTC_PRZ_ENTREGA').nullable()();
  IntColumn get salesmanId => integer().named('CTC_CODVDO').nullable()();
  IntColumn get warehouseId => integer().named('CTC_CODMHA').nullable()();
  TextColumn get status => text().named('CTC_STATUS').nullable()();
  IntColumn get remoteId => integer().named('CTC_REMOTE_ID').nullable()();
}

/// Itens do Orçamento (TB_ITENS_CTC)
class TbBudgetItem extends Table {
  @override
  String get tableName => 'TB_ITENS_CTC';

  IntColumn get id => integer().named('ICT_CODIGO').autoIncrement()();
  IntColumn get budgetId => integer().named('ICT_CODCTC').nullable()();
  TextColumn get type => text().named('ICT_TIPO').nullable()();
  IntColumn get productId => integer().named('ICT_CODVCL').nullable()();
  TextColumn get description => text().named('ICT_DESCRICAO').nullable()();
  RealColumn get quantity => real().named('ICT_QTDE').nullable()();
  RealColumn get unitPrice => real().named('ICT_VL_UNIT').nullable()();
  RealColumn get discountValue => real().named('ICT_VL_DESC').nullable()();
  RealColumn get discountPercent => real().named('ICT_AQ_DESC').nullable()();
  IntColumn get stockId => integer().named('ICT_CODEST').nullable()();
  IntColumn get priceListId => integer().named('ICT_CODTPR').nullable()();
  RealColumn get costValue => real().named('ICT_VL_CUSTO').nullable()();
  IntColumn get sequence => integer().named('ICT_SEQUENCIA').nullable()();
}

@DriftDatabase(tables: [TbBudget, TbBudgetItem])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() => driftDatabase(name: 'budget_sales_db');

  // ── Budget (header) ──────────────────────────────────────────────────────

  Future<List<TbBudgetData>> getAllBudgets() => select(tbBudget).get();

  Future<TbBudgetData?> getBudgetById(int id) =>
      (select(tbBudget)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> insertBudget(TbBudgetCompanion entry) =>
      into(tbBudget).insert(entry);

  Future<bool> updateBudget(TbBudgetCompanion entry) =>
      update(tbBudget).replace(entry);

  Future<int> deleteBudget(int id) =>
      (delete(tbBudget)..where((t) => t.id.equals(id))).go();

  Future<void> deleteBudgetWithItems(int id) async {
    await transaction(() async {
      await (delete(tbBudgetItem)..where((t) => t.budgetId.equals(id))).go();
      await (delete(tbBudget)..where((t) => t.id.equals(id))).go();
    });
  }

  // ── Budget Items ──────────────────────────────────────────────────────────

  Future<List<TbBudgetItemData>> getItemsByBudgetId(int budgetId) =>
      (select(tbBudgetItem)..where((t) => t.budgetId.equals(budgetId))).get();

  Future<TbBudgetItemData?> getItemById(int id) =>
      (select(tbBudgetItem)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> insertItem(TbBudgetItemCompanion entry) =>
      into(tbBudgetItem).insert(entry);

  Future<bool> updateItem(TbBudgetItemCompanion entry) =>
      update(tbBudgetItem).replace(entry);

  Future<int> deleteItem(int id) =>
      (delete(tbBudgetItem)..where((t) => t.id.equals(id))).go();

  Future<int> deleteItemsByBudgetId(int budgetId) =>
      (delete(tbBudgetItem)..where((t) => t.budgetId.equals(budgetId))).go();
}
