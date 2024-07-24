import 'transaction_entity.dart';

abstract class TransactionRepository {
  Future<List<Transaction>> fetchTransactions();
}
