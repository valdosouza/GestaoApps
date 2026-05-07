import 'package:budget_sales/src/features/budget/domain/entity/budget_entity.dart';
import 'package:equatable/equatable.dart';

abstract class BudgetListState extends Equatable {
  const BudgetListState();
}

class BudgetListInitial extends BudgetListState {
  const BudgetListInitial();

  @override
  List<Object?> get props => [];
}

class BudgetListLoading extends BudgetListState {
  const BudgetListLoading();

  @override
  List<Object?> get props => [];
}

class BudgetListLoaded extends BudgetListState {
  const BudgetListLoaded({
    required this.budgets,
    this.pendingBudgets = const [],
  });

  final List<BudgetEntity> budgets;
  final List<BudgetEntity> pendingBudgets;

  @override
  List<Object?> get props => [budgets, pendingBudgets];
}

class BudgetListError extends BudgetListState {
  const BudgetListError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
