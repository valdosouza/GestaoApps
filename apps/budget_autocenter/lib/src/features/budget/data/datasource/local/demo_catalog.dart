import '../../../domain/entity/autocenter_budget.dart';

// Catálogo demonstrativo isolado; substituir por datasource real na integração.
final catalog = [
  AutoCenterBudgetItem('Pneu 175/65 R14', 34990),
  AutoCenterBudgetItem('Pastilha de freio dianteira', 15990),
  AutoCenterBudgetItem('Óleo de motor 5W30 · 1 L', 6500),
  AutoCenterBudgetItem('Filtro de óleo', 3990),
  AutoCenterBudgetItem('Alinhamento', 12000, service: true),
  AutoCenterBudgetItem('Balanceamento', 8000, service: true),
  AutoCenterBudgetItem('Troca de óleo', 6000, service: true),
  AutoCenterBudgetItem('Mão de obra · freios', 18000, service: true),
];
