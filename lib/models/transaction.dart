enum TransactionCategory {
  food,
  transportation,
  shopping,
  entertainment,
  utilities,
  healthcare,
  education,
  travel,
  salary,
  transfer,
  other
}

class Transaction {
  final String id;
  final DateTime dateTime;
  final String description;
  final double amount;
  final TransactionCategory category;
  final String accountId;

  Transaction({
    required this.id,
    required this.dateTime,
    required this.description,
    required this.amount,
    required this.category,
    required this.accountId,
  });

  Transaction copyWith({
    String? id,
    DateTime? dateTime,
    String? description,
    double? amount,
    TransactionCategory? category,
    String? accountId,
  }) {
    return Transaction(
      id: id ?? this.id,
      dateTime: dateTime ?? this.dateTime,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      accountId: accountId ?? this.accountId,
    );
  }

  bool get isIncome => amount > 0;
  bool get isExpense => amount < 0;
}
