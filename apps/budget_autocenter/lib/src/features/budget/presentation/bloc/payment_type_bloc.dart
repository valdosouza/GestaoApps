import 'package:budget_autocenter/src/features/budget/domain/entity/payment_type_entity.dart';
import 'package:budget_autocenter/src/features/budget/domain/usecase/budget_usecases.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ── Events ────────────────────────────────────────────────────────────────────

abstract class PaymentTypeEvent extends Equatable {
  const PaymentTypeEvent();
}

class PaymentTypeLoad extends PaymentTypeEvent {
  const PaymentTypeLoad({this.description});

  final String? description;

  @override
  List<Object?> get props => [description];
}

// ── States ────────────────────────────────────────────────────────────────────

abstract class PaymentTypeState extends Equatable {
  const PaymentTypeState();
}

class PaymentTypeInitial extends PaymentTypeState {
  const PaymentTypeInitial();

  @override
  List<Object?> get props => [];
}

class PaymentTypeLoading extends PaymentTypeState {
  const PaymentTypeLoading();

  @override
  List<Object?> get props => [];
}

class PaymentTypeLoaded extends PaymentTypeState {
  const PaymentTypeLoaded({required this.paymentTypes});

  final List<PaymentTypeEntity> paymentTypes;

  @override
  List<Object?> get props => [paymentTypes];
}

class PaymentTypeError extends PaymentTypeState {
  const PaymentTypeError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

// ── Bloc ──────────────────────────────────────────────────────────────────────

class PaymentTypeBloc extends Bloc<PaymentTypeEvent, PaymentTypeState> {
  PaymentTypeBloc({required this.getPaymentTypes})
      : super(const PaymentTypeInitial()) {
    on<PaymentTypeLoad>(_onLoad);
  }

  final GetPaymentTypes getPaymentTypes;

  Future<void> _onLoad(
      PaymentTypeLoad event, Emitter<PaymentTypeState> emit) async {
    emit(const PaymentTypeLoading());
    final result = await getPaymentTypes(description: event.description);
    result.fold(
      (failure) => emit(PaymentTypeError(message: failure.message)),
      (types) => emit(PaymentTypeLoaded(paymentTypes: types)),
    );
  }
}
