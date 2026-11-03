class BudgetListEntry {
  const BudgetListEntry({
    required this.id,
    required this.number,
    required this.customer,
    required this.date,
    required this.totalCents,
    required this.status,
    required this.institutionId,
  });
  final int id, institutionId, totalCents;
  final String number, customer, status;
  final DateTime? date;
  factory BudgetListEntry.fromJson(Map<String, dynamic> j) {
    final amount = num.tryParse('${j['total']}');
    final id = int.tryParse('${j['id']}'),
        institution = int.tryParse('${j['institutionId']}');
    if (id == null || institution == null || amount == null || !amount.isFinite)
      throw const FormatException('Orçamento inválido');
    final raw = '${j['date'] ?? ''}';
    return BudgetListEntry(
      id: id,
      institutionId: institution,
      number: '${j['number'] ?? ''}'.trim(),
      customer: '${j['customerName'] ?? ''}'.trim(),
      date: DateTime.tryParse(raw.length >= 10 ? raw.substring(0, 10) : raw),
      totalCents: (amount * 100).round(),
      status: '${j['status'] ?? ''}'.trim(),
    );
  }
}

class BudgetListPageData {
  const BudgetListPageData(this.rows, this.total, this.offset, this.limit);
  final List<BudgetListEntry> rows;
  final int total, offset, limit;
  bool get hasNext => offset + limit < total;
}
