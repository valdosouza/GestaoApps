import 'package:budget_autocenter/src/features/budget/domain/entity/budget_entity.dart';
import 'package:budget_autocenter/src/features/budget/domain/entity/budget_item_entity.dart';
import 'package:equatable/equatable.dart';

abstract class BudgetRegisterEvent extends Equatable {
  const BudgetRegisterEvent();
}

class BudgetRegisterLoadRemote extends BudgetRegisterEvent {
  const BudgetRegisterLoadRemote({required this.budgetId});
  final int budgetId;
  @override
  List<Object?> get props => [budgetId];
}

class BudgetRegisterStartNew extends BudgetRegisterEvent {
  const BudgetRegisterStartNew({required this.userId, required this.salesmanId});
  final int userId;
  final int salesmanId;
  @override
  List<Object?> get props => [userId, salesmanId];
}

class BudgetRegisterLoadLocal extends BudgetRegisterEvent {
  const BudgetRegisterLoadLocal({required this.localId});
  final int localId;
  @override
  List<Object?> get props => [localId];
}

class BudgetRegisterUpdate extends BudgetRegisterEvent {
  const BudgetRegisterUpdate({required this.budget});
  final BudgetEntity budget;
  @override
  List<Object?> get props => [budget];
}

class BudgetRegisterSaveLocal extends BudgetRegisterEvent {
  const BudgetRegisterSaveLocal({required this.budget});
  final BudgetEntity budget;
  @override
  List<Object?> get props => [budget];
}

class BudgetRegisterLoadItems extends BudgetRegisterEvent {
  const BudgetRegisterLoadItems({required this.localBudgetId});
  final int localBudgetId;
  @override
  List<Object?> get props => [localBudgetId];
}

class BudgetRegisterSaveItem extends BudgetRegisterEvent {
  const BudgetRegisterSaveItem({required this.item, this.isNew = true});
  final BudgetItemEntity item;
  final bool isNew;
  @override
  List<Object?> get props => [item, isNew];
}

class BudgetRegisterDeleteItem extends BudgetRegisterEvent {
  const BudgetRegisterDeleteItem({required this.itemId, required this.localBudgetId});
  final int itemId;
  final int localBudgetId;
  @override
  List<Object?> get props => [itemId, localBudgetId];
}

class BudgetRegisterSubmit extends BudgetRegisterEvent {
  const BudgetRegisterSubmit({required this.localBudgetId});
  final int localBudgetId;
  @override
  List<Object?> get props => [localBudgetId];
}
