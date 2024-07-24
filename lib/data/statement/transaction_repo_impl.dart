import '../../domain/statement/transaction_entity.dart';
import '../../domain/statement/transaction_repo.dart';
import 'transaction_data_source.dart';
import 'transaction_model.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionDataSource dataSource;

  TransactionRepositoryImpl({required this.dataSource});

  Future<List<Transaction>> fetchTransactions() async {
    List<TransactionModel> transactionModels =
        await dataSource.fetchTransactions();
    return transactionModels
        .map((model) => Transaction(
              transactionId: model.transactionId,
              type: model.type,
              status: model.status,
              createdAt: model.createdAt,
              approvedAt: model.approvedAt,
              description: model.description,
              reason: model.reason,
              amount: model.amount,
              currency: model.currency,
              date: model.date,
              time: model.time,
            ))
        .toList();
  }
}
