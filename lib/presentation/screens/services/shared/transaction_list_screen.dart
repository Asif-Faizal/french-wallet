import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/statement/transaction_data_source.dart';
import '../../../../data/statement/transaction_repo_impl.dart';
import '../../../../domain/statement/fetch_transaction.dart';
import '../../../bloc/statement/transaction_bloc.dart';
import '../../../bloc/statement/transaction_event.dart';
import '../../../bloc/statement/transaction_state.dart';

class TransactionListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TransactionBloc(
        fetchTransactions: FetchTransactions(
          repository: TransactionRepositoryImpl(
            dataSource: TransactionDataSource(),
          ),
        ),
      )..add(LoadTransactions()),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Transaction List'),
        ),
        body: BlocBuilder<TransactionBloc, TransactionState>(
          builder: (context, state) {
            if (state is TransactionLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is TransactionLoaded) {
              return ListView.builder(
                physics: BouncingScrollPhysics(),
                itemCount: state.transactions.length,
                itemBuilder: (context, index) {
                  final transaction = state.transactions[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListTile(
                      title:
                          Text('Transaction ID: ${transaction.transactionId}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Type: ${transaction.type}'),
                          Text(
                              'Amount: ${transaction.amount} ${transaction.currency}'),
                          Text('Status: ${transaction.status}'),
                          Text('Date: ${transaction.date}'),
                          Text('Time: ${transaction.time}'),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else if (state is TransactionError) {
              return Center(child: Text(state.message));
            } else {
              return Center(child: Text('Unknown state'));
            }
          },
        ),
      ),
    );
  }
}
