import 'package:flutter/material.dart';
import 'package:budget_autocenter/src/features/budget/domain/entity/autocenter_budget.dart';
import 'package:budget_autocenter/src/features/budget/presentation/page/autocenter_budget_page.dart';
import 'package:budget_autocenter/src/features/budget/presentation/page/budget_overview_page.dart';

// Exercita a interface de edição já aprovada, sem conectá-la aos dados reais.
class TestWorkbench extends StatelessWidget {
  const TestWorkbench({super.key});
  @override
  Widget build(BuildContext context) => BudgetOverviewPage(
    onEdit: (context, budget, step) =>
        Navigator.of(context).push<AutoCenterBudget>(
          MaterialPageRoute(
            builder: (_) => AutoCenterBudgetEditorPage(
              budget: budget.copy(),
              initialStep: step,
            ),
          ),
        ),
  );
}
