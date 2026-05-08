import 'package:core/shared/helpers/local_storage.dart';
import 'package:budget_sales/src/features/budget/domain/entity/budget_entity.dart';
import 'package:budget_sales/src/features/budget/domain/entity/budget_item_entity.dart';
import 'package:budget_sales/src/features/budget/domain/usecase/budget_usecases.dart';
import 'package:budget_sales/src/features/budget/presentation/bloc/budget_register_event.dart';
import 'package:budget_sales/src/features/budget/presentation/bloc/budget_register_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BudgetRegisterBloc
    extends Bloc<BudgetRegisterEvent, BudgetRegisterState> {
  BudgetRegisterBloc({
    required this.getBudgetById,
    required this.createBudget,
    required this.saveLocalBudget,
    required this.updateLocalBudget,
    required this.getLocalBudgetById,
    required this.deleteLocalBudget,
    required this.getLocalItems,
    required this.saveLocalItem,
    required this.updateLocalItem,
    required this.deleteLocalItem,
    required this.createBudgetRemoteItems,
  }) : super(const BudgetRegisterInitial()) {
    on<BudgetRegisterLoadRemote>(_onLoadRemote);
    on<BudgetRegisterStartNew>(_onStartNew);
    on<BudgetRegisterLoadLocal>(_onLoadLocal);
    on<BudgetRegisterUpdate>(_onUpdate);
    on<BudgetRegisterSaveLocal>(_onSaveLocal);
    on<BudgetRegisterLoadItems>(_onLoadItems);
    on<BudgetRegisterSaveItem>(_onSaveItem);
    on<BudgetRegisterDeleteItem>(_onDeleteItem);
    on<BudgetRegisterSubmit>(_onSubmit);
  }

  final GetBudgetById getBudgetById;
  final CreateBudget createBudget;
  final SaveLocalBudget saveLocalBudget;
  final UpdateLocalBudget updateLocalBudget;
  final GetLocalBudgetById getLocalBudgetById;
  final DeleteLocalBudget deleteLocalBudget;
  final GetLocalItems getLocalItems;
  final SaveLocalItem saveLocalItem;
  final UpdateLocalItem updateLocalItem;
  final DeleteLocalItem deleteLocalItem;
  // Used when submitting: creates items on remote API
  final CreateBudgetItem createBudgetRemoteItems;

  // ── Helpers ──────────────────────────────────────────────────────────────

  /// Calcula o valor total do orçamento a partir dos itens
  double _calculateTotal(List<BudgetItemEntity> items, double freight) {
    double totalProducts = 0;
    double totalDiscount = 0;
    for (final item in items) {
      totalProducts += item.subtotal;
      totalDiscount += item.discountValue;
    }
    final subtotal = totalProducts - totalDiscount;
    return subtotal + freight;
  }

  // ── Handlers ─────────────────────────────────────────────────────────────

  Future<void> _onLoadRemote(
      BudgetRegisterLoadRemote event, Emitter<BudgetRegisterState> emit) async {
    emit(const BudgetRegisterLoading());
    final result = await getBudgetById(event.budgetId);
    await result.fold(
      (failure) async =>
          emit(BudgetRegisterError(message: failure.message)),
      (budget) async {
        // Copy to local storage for editing
        final localResult = await saveLocalBudget(budget);
        await localResult.fold(
          (f) async => emit(BudgetRegisterError(message: f.message)),
          (localId) async {
            emit(BudgetRegisterReady(
              budget: budget,
              items: const [],
              localId: localId,
            ));
          },
        );
      },
    );
  }

  Future<void> _onStartNew(
      BudgetRegisterStartNew event, Emitter<BudgetRegisterState> emit) async {
    emit(const BudgetRegisterLoading());
    final now = DateTime.now();
    final dateStr =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';

    // Get institutionId from saved establishment
    final institutionValue = await LocalStorageService.instance
        .get(key: 'institution', defaultValue: '');

    final institutionId = int.tryParse(institutionValue?.toString() ?? '') ?? 0;

    final newBudget = BudgetEntity.empty().copyWith(
      userId: event.userId,
      salesmanId: event.salesmanId,
      date: dateStr,
      status: 'N',
      institutionId: institutionId,
    );
    final result = await saveLocalBudget(newBudget);
    result.fold(
      (failure) => emit(BudgetRegisterError(message: failure.message)),
      (localId) => emit(BudgetRegisterReady(
        budget: newBudget.copyWith(id: localId),
        items: const [],
        localId: localId,
      )),
    );
  }

  Future<void> _onLoadLocal(
      BudgetRegisterLoadLocal event, Emitter<BudgetRegisterState> emit) async {
    emit(const BudgetRegisterLoading());
    final budgetResult = await getLocalBudgetById(event.localId);
    await budgetResult.fold(
      (f) async => emit(BudgetRegisterError(message: f.message)),
      (budget) async {
        if (budget == null) {
          emit(const BudgetRegisterError(message: 'Orçamento não encontrado.'));
          return;
        }
        final itemsResult = await getLocalItems(event.localId);
        itemsResult.fold(
          (f) => emit(BudgetRegisterReady(
              budget: budget, items: const [], localId: event.localId)),
          (items) => emit(BudgetRegisterReady(
              budget: budget, items: items, localId: event.localId)),
        );
      },
    );
  }

  Future<void> _onUpdate(
      BudgetRegisterUpdate event, Emitter<BudgetRegisterState> emit) {
    final current = state;
    if (current is BudgetRegisterReady) {
      emit(current.copyWith(budget: event.budget));
    }
    return Future.value();
  }

  Future<void> _onSaveLocal(
      BudgetRegisterSaveLocal event, Emitter<BudgetRegisterState> emit) async {
    final current = state;
    if (current is! BudgetRegisterReady) return;
    emit(current.copyWith(isSaving: true));

    final total = _calculateTotal(current.items, event.budget.freight);
    final budgetWithTotal = event.budget.copyWith(total: total);

    final result =
        await updateLocalBudget(budgetWithTotal, current.localId);
    result.fold(
      (f) => emit(BudgetRegisterError(message: f.message)),
      (_) => emit(current.copyWith(budget: budgetWithTotal, isSaving: false)),
    );
  }

  Future<void> _onLoadItems(
      BudgetRegisterLoadItems event, Emitter<BudgetRegisterState> emit) async {
    final current = state;
    if (current is! BudgetRegisterReady) return;
    final result = await getLocalItems(event.localBudgetId);
    await result.fold(
      (f) async => emit(BudgetRegisterError(message: f.message)),
      (items) async {
        final total = _calculateTotal(items, current.budget.freight);
        final updatedBudget = current.budget.copyWith(total: total);
        // Save the updated budget with calculated total to local database
        await updateLocalBudget(updatedBudget, current.localId);
        emit(current.copyWith(items: items, budget: updatedBudget));
      },
    );
  }

  Future<void> _onSaveItem(
      BudgetRegisterSaveItem event, Emitter<BudgetRegisterState> emit) async {
    final current = state;
    if (current is! BudgetRegisterReady) return;
    emit(current.copyWith(isSaving: true));

    if (event.isNew) {
      final result = await saveLocalItem(event.item);
      await result.fold(
        (f) async => emit(BudgetRegisterError(message: f.message)),
        (_) async {
          final itemsResult = await getLocalItems(current.localId);
          await itemsResult.fold(
            (f) async => emit(BudgetRegisterError(message: f.message)),
            (items) async {
              final total = _calculateTotal(items, current.budget.freight);
              final updatedBudget = current.budget.copyWith(total: total);
              // Save the updated budget with calculated total
              await updateLocalBudget(updatedBudget, current.localId);
              emit(current.copyWith(items: items, budget: updatedBudget, isSaving: false));
            },
          );
        },
      );
    } else {
      final result = await updateLocalItem(event.item);
      await result.fold(
        (f) async => emit(BudgetRegisterError(message: f.message)),
        (_) async {
          final itemsResult = await getLocalItems(current.localId);
          await itemsResult.fold(
            (f) async => emit(BudgetRegisterError(message: f.message)),
            (items) async {
              final total = _calculateTotal(items, current.budget.freight);
              final updatedBudget = current.budget.copyWith(total: total);
              // Save the updated budget with calculated total
              await updateLocalBudget(updatedBudget, current.localId);
              emit(current.copyWith(items: items, budget: updatedBudget, isSaving: false));
            },
          );
        },
      );
    }
  }

  Future<void> _onDeleteItem(
      BudgetRegisterDeleteItem event, Emitter<BudgetRegisterState> emit) async {
    final current = state;
    if (current is! BudgetRegisterReady) return;

    final result = await deleteLocalItem(event.itemId);
    await result.fold(
      (f) async => emit(BudgetRegisterError(message: f.message)),
      (_) async {
        final itemsResult = await getLocalItems(event.localBudgetId);
        await itemsResult.fold(
          (f) async => emit(BudgetRegisterError(message: f.message)),
          (items) async {
            final total = _calculateTotal(items, current.budget.freight);
            final updatedBudget = current.budget.copyWith(total: total);
            // Save the updated budget with calculated total
            await updateLocalBudget(updatedBudget, current.localId);
            emit(current.copyWith(items: items, budget: updatedBudget));
          },
        );
      },
    );
  }

  Future<void> _onSubmit(
      BudgetRegisterSubmit event, Emitter<BudgetRegisterState> emit) async {
    final current = state;
    if (current is! BudgetRegisterReady) return;
    emit(current.copyWith(isSaving: true));

    try {
      // Calculate total from items before sending
      final total = _calculateTotal(current.items, current.budget.freight);
      final budgetToSubmit = current.budget.copyWith(total: total);

      debugPrint('Budget data to submit - Date: ${budgetToSubmit.date}, InstitutionId: ${budgetToSubmit.institutionId}, Total: ${budgetToSubmit.total}');

      // 1. Create budget on remote
      final budgetResult = await createBudget(budgetToSubmit);
      await budgetResult.fold(
        (f) async => emit(BudgetRegisterError(message: f.message)),
        (remoteBudget) async {
          // 2. Create each item on remote
          bool hasError = false;
          for (final item in current.items) {
            final itemResult = await createBudgetRemoteItems(
              remoteBudget.id,
              item.copyWith(budgetId: remoteBudget.id),
            );
            itemResult.fold(
              (f) {
                hasError = true;
                debugPrint('Item submit error: ${f.message}');
              },
              (_) {},
            );
            if (hasError) break;
          }

          if (hasError) {
            emit(const BudgetRegisterError(
                message: 'Erro ao enviar itens para o servidor.'));
            return;
          }

          // 3. Clean up local records
          await deleteLocalBudget(event.localBudgetId);

          emit(BudgetRegisterSubmitSuccess(remoteBudget: remoteBudget));
        },
      );
    } catch (e) {
      emit(BudgetRegisterError(message: e.toString()));
    }
  }
}
