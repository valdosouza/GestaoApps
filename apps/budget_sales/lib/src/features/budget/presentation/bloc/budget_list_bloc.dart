import 'package:core/shared/helpers/local_storage.dart';
import 'package:budget_sales/src/features/budget/domain/entity/budget_entity.dart';
import 'package:budget_sales/src/features/budget/domain/usecase/budget_usecases.dart';
import 'package:budget_sales/src/features/budget/presentation/bloc/budget_list_event.dart';
import 'package:budget_sales/src/features/budget/presentation/bloc/budget_list_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BudgetListBloc extends Bloc<BudgetListEvent, BudgetListState> {
  BudgetListBloc({
    required this.getBudgets,
    required this.getLocalBudgets,
  }) : super(const BudgetListInitial()) {
    on<BudgetListLoad>(_onLoad);
    on<BudgetListClearFilter>(_onClear);
  }

  final GetBudgets getBudgets;
  final GetLocalBudgets getLocalBudgets;

  Future<void> _onLoad(
      BudgetListLoad event, Emitter<BudgetListState> emit) async {
    emit(const BudgetListLoading());

    // Always load local pending drafts first (works offline)
    final localResult = await getLocalBudgets();
    final pending = localResult.fold(
      (_) => <BudgetEntity>[],
      (list) => list,
    );

    // Load institutionId from local storage
    final institutionValue = await LocalStorageService.instance
        .get(key: 'institution', defaultValue: '');
    final institutionId =
        int.tryParse(institutionValue?.toString() ?? '') ?? 0;

    // Then try remote
    final result = await getBudgets(
      number: event.number,
      dateStart: event.dateStart,
      dateEnd: event.dateEnd,
      customerName: event.customerName,
      institutionId: institutionId > 0 ? institutionId : null,
    );
    result.fold(
      (failure) => emit(BudgetListLoaded(
        budgets: const [],
        pendingBudgets: pending,
      )),
      (budgets) => emit(BudgetListLoaded(
        budgets: budgets,
        pendingBudgets: pending,
      )),
    );
  }

  Future<void> _onClear(
      BudgetListClearFilter event, Emitter<BudgetListState> emit) async {
    add(const BudgetListLoad());
  }
}
