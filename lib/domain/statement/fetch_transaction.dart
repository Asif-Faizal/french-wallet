import 'transaction_entity.dart';
import 'transaction_repo.dart';

class FetchTransactions {
  final TransactionRepository repository;

  FetchTransactions({required this.repository});

  Future<List<Transaction>> call() async {
    return await repository.fetchTransactions();
  }
}
