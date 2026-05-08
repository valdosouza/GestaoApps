import 'package:budget_autocenter/src/features/budget/domain/entity/customer_entity.dart';
import 'package:budget_autocenter/src/features/budget/domain/usecase/budget_usecases.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ── Events ────────────────────────────────────────────────────────────────────

abstract class CustomerSearchEvent extends Equatable {
  const CustomerSearchEvent();
}

class CustomerSearchLoad extends CustomerSearchEvent {
  const CustomerSearchLoad({this.id, this.name, this.tradeName, this.cnpj});

  final int? id;
  final String? name;
  final String? tradeName;
  final String? cnpj;

  @override
  List<Object?> get props => [id, name, tradeName, cnpj];
}

// ── States ────────────────────────────────────────────────────────────────────

abstract class CustomerSearchState extends Equatable {
  const CustomerSearchState();
}

class CustomerSearchInitial extends CustomerSearchState {
  const CustomerSearchInitial();

  @override
  List<Object?> get props => [];
}

class CustomerSearchLoading extends CustomerSearchState {
  const CustomerSearchLoading();

  @override
  List<Object?> get props => [];
}

class CustomerSearchLoaded extends CustomerSearchState {
  const CustomerSearchLoaded({required this.customers});

  final List<CustomerEntity> customers;

  @override
  List<Object?> get props => [customers];
}

class CustomerSearchError extends CustomerSearchState {
  const CustomerSearchError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

// ── Bloc ──────────────────────────────────────────────────────────────────────

class CustomerSearchBloc
    extends Bloc<CustomerSearchEvent, CustomerSearchState> {
  CustomerSearchBloc({required this.getCustomers})
      : super(const CustomerSearchInitial()) {
    on<CustomerSearchLoad>(_onLoad);
  }

  final GetCustomers getCustomers;

  Future<void> _onLoad(
      CustomerSearchLoad event, Emitter<CustomerSearchState> emit) async {
    emit(const CustomerSearchLoading());
    final result = await getCustomers(
      id: event.id,
      name: event.name,
      tradeName: event.tradeName,
      cnpj: event.cnpj,
    );
    result.fold(
      (failure) => emit(CustomerSearchError(message: failure.message)),
      (customers) => emit(CustomerSearchLoaded(customers: customers)),
    );
  }
}
