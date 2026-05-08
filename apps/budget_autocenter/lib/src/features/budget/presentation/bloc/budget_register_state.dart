import 'package:budget_autocenter/src/features/budget/domain/entity/budget_entity.dart';
import 'package:budget_autocenter/src/features/budget/domain/entity/budget_item_entity.dart';
import 'package:equatable/equatable.dart';

abstract class BudgetRegisterState extends Equatable {
  const BudgetRegisterState();
}

class BudgetRegisterInitial extends BudgetRegisterState {
  const BudgetRegisterInitial();

  @override
  List<Object?> get props => [];
}

class BudgetRegisterLoading extends BudgetRegisterState {
  const BudgetRegisterLoading();

  @override
  List<Object?> get props => [];
}

class BudgetRegisterReady extends BudgetRegisterState {
  const BudgetRegisterReady({
    required this.budget,
    required this.items,
    required this.localId,
    this.isSaving = false,
  });

  final BudgetEntity budget;
  final List<BudgetItemEntity> items;
  final int localId;
  final bool isSaving;

  BudgetRegisterReady copyWith({
    BudgetEntity? budget,
    List<BudgetItemEntity>? items,
    int? localId,
    bool? isSaving,
  }) {
    return BudgetRegisterReady(
      budget: budget ?? this.budget,
      items: items ?? this.items,
      localId: localId ?? this.localId,
      isSaving: isSaving ?? this.isSaving,
    );
  }

  @override
  List<Object?> get props => [budget, items, localId, isSaving];
}

class BudgetRegisterSubmitSuccess extends BudgetRegisterState {
  const BudgetRegisterSubmitSuccess({required this.remoteBudget});

  final BudgetEntity remoteBudget;

  @override
  List<Object?> get props => [remoteBudget];
}

class BudgetRegisterError extends BudgetRegisterState {
  const BudgetRegisterError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
