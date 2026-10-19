class Expense {
  final int? id;
  String content; // nội dung chi tiêu
  double amount; // số tiền
  String note; // ghi chú
  String date; // ngày chi (ISO 8601)

  Expense({
    this.id,
    required this.content,
    required this.amount,
    this.note = '',
    String? date,
  }) : date = date ?? DateTime.now().toIso8601String();

  Map<String, dynamic> toMap() => {
        'id': id,
        'content': content,
        'amount': amount,
        'note': note,
        'date': date,
      };

  factory Expense.fromMap(Map<String, dynamic> map) => Expense(
        id: map['id'],
        content: map['content'],
        amount: (map['amount'] as num).toDouble(),
        note: map['note'] ?? '',
        date: map['date'],
      );
}
