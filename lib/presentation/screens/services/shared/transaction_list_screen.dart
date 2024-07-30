import 'package:ewallet2/presentation/widgets/shared/normal_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../data/statement/transaction_data_source.dart';
import '../../../../data/statement/transaction_repo_impl.dart';
import '../../../../domain/statement/fetch_transaction.dart';
import '../../../bloc/statement/transaction_bloc.dart';
import '../../../bloc/statement/transaction_event.dart';
import '../../../bloc/statement/transaction_state.dart';

class TransactionListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BlocProvider(
      create: (context) => TransactionBloc(
        fetchTransactions: FetchTransactions(
          repository: TransactionRepositoryImpl(
            dataSource: TransactionDataSource(),
          ),
        ),
      )..add(LoadTransactions()),
      child: Scaffold(
        appBar: NormalAppBar(text: 'Statements'),
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

                  DateTime transactionDate = DateTime.parse(transaction.date);

                  final formattedDate =
                      DateFormat('dd MMM yyyy').format(transactionDate);
                  final formattedTime =
                      DateFormat('HH:mm').format(transactionDate);

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListTile(
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      title: SizedBox(
                        height: size.height / 10,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${transaction.amount} ${transaction.currency}',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                SizedBox(height: size.height / 80),
                                Text(
                                  'Type: ${transaction.type}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                Text(
                                  'Transaction ID: ${transaction.transactionId}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(formattedDate,
                                    style:
                                        Theme.of(context).textTheme.bodySmall),
                                Text(formattedTime,
                                    style:
                                        Theme.of(context).textTheme.bodySmall),
                              ],
                            ),
                          ],
                        ),
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
