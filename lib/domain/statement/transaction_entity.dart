class Transaction {
  final String transactionId;
  final String type;
  final String status;
  final String createdAt;
  final String approvedAt;
  final String description;
  final String reason;
  final String amount;
  final String currency;
  final String date;
  final String time;

  Transaction({
    required this.transactionId,
    required this.type,
    required this.status,
    required this.createdAt,
    required this.approvedAt,
    required this.description,
    required this.reason,
    required this.amount,
    required this.currency,
    required this.date,
    required this.time,
  });
}