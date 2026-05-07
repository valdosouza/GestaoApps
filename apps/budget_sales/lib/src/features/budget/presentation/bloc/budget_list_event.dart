import 'package:equatable/equatable.dart';

abstract class BudgetListEvent extends Equatable {
  const BudgetListEvent();
}

class BudgetListLoad extends BudgetListEvent {
  const BudgetListLoad({
    this.number,
    this.dateStart,
    this.dateEnd,
    this.customerName,
  });

  final String? number;
  final String? dateStart;
  final String? dateEnd;
  final String? customerName;

  @override
  List<Object?> get props => [number, dateStart, dateEnd, customerName];
}

class BudgetListClearFilter extends BudgetListEvent {
  const BudgetListClearFilter();

  @override
  List<Object?> get props => [];
}
