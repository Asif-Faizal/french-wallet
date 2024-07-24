class TransactionModel {
  final String sinnadTransactionId;
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

  TransactionModel({
    required this.sinnadTransactionId,
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

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      sinnadTransactionId: json['sinnad_transaction_id'] ?? '',
      transactionId: json['transaction_id'] ?? '',
      type: json['type'] ?? '',
      status: json['status'] ?? '',
      createdAt: json['created_at'] ?? '',
      approvedAt: json['approved_at'] ?? '',
      description: json['description'] ?? '',
      reason: json['reason'] ?? '',
      amount: json['amount'] ?? '',
      currency: json['currency'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
    );
  }
}
