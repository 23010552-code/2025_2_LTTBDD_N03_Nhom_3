class TransactionItem {
  final int id;
  final String categoryKey;
  final double amount;
  final bool isIncome;
  final String note;
  final DateTime date;

  const TransactionItem({
    required this.id,
    required this.categoryKey,
    required this.amount,
    required this.isIncome,
    required this.note,
    required this.date,
  });
}
